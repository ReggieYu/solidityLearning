// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * 拍卖实现合约--支持UUPS可升级
 * 支持ETH和ERC20代币出价
 * 使用chainlink预言机计算美元价
 * 升级由合约owner控制，这里直接由工厂作为owner
 */

contract AuctionImplementation is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    struct Auction {
        address seller; // 卖家
        uint256 duration; // 拍卖持续时间，单位秒
        uint256 startPrice; // 起拍价(以支付代币单位表示：若是ETH，则是wei)
        uint256 startTime; // 拍卖开始时间
        bool ended; // 是否结束
        address highestBidder; // 最高出价者
        uint256 highestBid; // 最高出价（以支付代币单位：若是ETH，则是wei）
        address nftContract; // NFT合约地址
        uint256 tokenId; // NFT ID
        address payTokenAddress; // 出价代币合约地址，0表示ETH，其他表示ERC20
    }

    Auction public auction;

    // 代币地址 => chainlink预言机
    // 如果address是零地址，映射ETH/USD
    // 如果address是其他，映射token/USD
    mapping(address => AggregatorV3Interface) public priceFeeds;

    // CCIP占位配置
    address public ccipRouter;
    bool public ccipEnabled;

    // 手续费配置
    address public feeRecipient; // 收费地址
    uint16 public feeBps; // 手续费基点(万分比), 200对应2%

    event AuctionCreated(
        address indexed seller,
        address indexed nft,
        uint256 indexed tokenId,
        address payToken,
        uint256 startPrice,
        uint256 duration
    );
    event BidPlaced(address indexed bidder, uint256 amount, uint256 amountUsd);
    event AuctionEnded(address indexed winner, uint256 amount);
    event PriceFeedUpdated(address indexed token, address indexed aggregator);
    event FeeConfigUpdated(address indexed recepient, uint16 feeBps);
    event CcipConfigUpdated(address indexed router, bool enabled);
    // Ccip最小可用演示：仅发出请求事件，由外部路由/执行器处理跨链与目标链执行
    event CcipBidRequested(address indexed router, bytes payload);

    // 初始化 --- 由代理调用
    function initialize(
        address owner_,
        address seller,
        address nftContract,
        uint256 tokenId,
        uint256 duration,
        uint256 startPrice,
        address payTokenAddress
    ) public initializer {
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        require(nftContract != address(0), "nftContract address is zero");
        require(duration > 0, "duration is zero");
        require(startPrice > 0, "startPrice must be greater than 0");

        auction = Auction({
            seller: seller,
            duration: duration,
            startPrice: startPrice,
            startTime: block.timestamp,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            nftContract: nftContract,
            tokenId: tokenId,
            payTokenAddress: payTokenAddress
        });

        emit AuctionCreated(
            seller,
            nftContract,
            tokenId,
            payTokenAddress,
            startPrice,
            duration
        );
    }

    // owner 设置预言机地址
    // token => USD 或者 ETH => USD
    function setPriceFeed(
        address token,
        address aggregator
    ) external onlyOwner {
        require(aggregator != address(0), "aggregator address can not be zero");
        priceFeeds[token] = AggregatorV3Interface(aggregator);
        emit PriceFeedUpdated(token, aggregator);
    }

    // 读取最新价格并返回：price，decimals
    function getLatestPrice(
        address token
    ) public view returns (int256 price, uint8 decimals) {
        AggregatorV3Interface feed = priceFeeds[token];
        require(address(feed) != address(0), "feed not set");
        (, int256 answer, , , ) = feed.latestRoundData();
        return (answer, feed.decimals());
    }

    // 设置手续费(仅限owner)；feeBps为万分比，最大2000(20%)
    function setFeeConfig(
        address recepient,
        uint16 feeBps_
    ) external onlyOwner {
        require(recepient != address(0), "recepient address is zero");
        require(feeBps_ < 2000, "feeBp is too high");
        feeRecipient = recepient;
        feeBps = feeBps_;
        emit FeeConfigUpdated(recepient, feeBps_);
    }

    // 设置Ccip路由与开关(占位)
    function setCcipConfig(address router, bool enabled) external onlyOwner {
        ccipRouter = router;
        ccipEnabled = enabled;
        emit CcipConfigUpdated(router, enabled);
    }

    // 最小可用CCIP请求：仅校验开关并非事件，实际跨链发送与目标链执行在链下/路由完成
    function setCrossChainBidRequest(
        bytes calldata payload
    ) external returns (bool) {
        require(ccipEnabled && ccipRouter != address(0), "ccip disabled");
        emit CcipBidRequested(ccipRouter, payload);
        return true;
    }

    // 计算给定出价金额兑换成美元值(返回1e8精度的USD金额)
    function quoteBidInUsd(
        uint256 amount
    ) public view returns (uint256 usdAmountE8) {
        address payToken = auction.payTokenAddress;
        (int256 price, uint pDecimals) = getLatestPrice(payToken);
        require(price > 0, "invalid price");
        uint256 priceC = uint256(price);
        uint256 tokenDecimals = payToken == address(0)
            ? 18
            : IERC20Metadata(payToken).decimals();
        // 归一到1e8（常见的USD标准精度）
        usdAmountE8 = amount * priceC;
        if (tokenDecimals + pDecimals >= 8) {
            usdAmountE8 = usdAmountE8 / (10 ** (tokenDecimals + pDecimals - 8));
        } else {
            usdAmountE8 = usdAmountE8 / (10 ** (8 - tokenDecimals - pDecimals));
        }
    }

    // 出价
    function bid(uint256 amount) external payable nonReentrant {
        require(!auction.ended, "auction has ended");
        require(
            block.timestamp < auction.startTime + auction.duration,
            "auction has ended"
        );

        uint256 payAmount;
        if (auction.payTokenAddress == address(0)) {
            payAmount = msg.value;
            require(payAmount > 0, "invalid ethereum pay amount");
        } else {
            require(amount > 0, "invalid pay amount");
            payAmount = amount;
            IERC20(auction.payTokenAddress).transferFrom(
                msg.sender,
                address(this),
                payAmount
            );
        }

        uint256 minRequired = auction.highestBid == 0
            ? auction.startPrice
            : auction.highestBid + 1;
        require(
            payAmount > minRequired,
            "payAmount must be greater than minRequired"
        );

        // 退款给之前的最高出价者
        if (auction.highestBidder != address(0)) {
            if (auction.payTokenAddress != address(0)) {
                (bool ok, ) = auction.highestBidder.call{
                    value: auction.highestBid
                }("");
                require(ok, "refund failed");
            } else {
                IERC20(auction.payTokenAddress).transfer(
                    auction.highestBidder,
                    auction.highestBid
                );
            }
        }

        auction.highestBid = payAmount;
        auction.highestBidder = msg.sender;

        uint256 usd = quoteBidInUsd(amount);
        emit BidPlaced(msg.sender, payAmount, usd);
    }

    // 结束拍卖：任何人可在过期后调用
    function endAuction() external nonReentrant {
        require(!auction.ended, "auction has ended");
        require(
            block.timestamp >= auction.startTime + auction.duration,
            "auction has ended yet"
        );
        auction.ended = true;

        // 如果没有人出价，NFT归还卖家
        if (auction.highestBidder == address(0)) {
            IERC721(auction.nftContract).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );
            emit AuctionEnded(address(0), 0);
            return;
        }

        // 将NFT转给中标者
        IERC721(auction.nftContract).transferFrom(
            address(this),
            auction.highestBidder,
            auction.tokenId
        );
        // 结算资金：先扣手续费（若配置了手续费）再转给卖家
        uint256 amount = auction.highestBid;
        uint256 fee = feeRecipient != address(0) && feeBps > 0
            ? (amount * feeBps) / 1000
            : 0;
        uint256 toSeller = amount - fee;
        if (auction.payTokenAddress == address(0)) {
            if (fee > 0) {
                (bool okF, ) = payable(feeRecipient).call{value: fee}("");
                require(okF, "pay fee failed");
            }

            (bool okS, ) = payable(auction.seller).call{value: toSeller}("");
            require(okS, "pay seller failed");
        } else {
            if (fee > 0) {
                IERC20(auction.payTokenAddress).transfer(feeRecipient, fee);
            }

            IERC20(auction.payTokenAddress).transfer(auction.seller, toSeller);
        }

        emit AuctionEnded(auction.highestBidder, auction.highestBid);
    }

    // 卖家在无人出价时取消拍卖
    function cancel() external nonReentrant {
        require(
            msg.sender == auction.seller || msg.sender == owner(),
            "only seller or owner can cancel"
        );
        require(!auction.ended, "auction has ended");
        require(auction.highestBidder == address(0), "already has bid");
        auction.ended = true;

        IERC721(auction.nftContract).transferFrom(
            address(this),
            auction.seller,
            auction.tokenId
        );
    }

    // 预留: 跨链拍卖接口(仅占位)
    function sendCrossChainBid(
        bytes calldata /*paylod*/
    ) external view returns (bool) {
        // 兼容就测试：返回当前是否开启ccip以及是否设置ccip路由
        return ccipEnabled && ccipRouter != address(0);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    // 仅限owner触发的升级入口，便于通过工厂代理升级(避免接口签名/兼容性问题)
    // 移除占位升级方法，采用工厂直接调用UUPS upgradeTo()

    // 接收ETH
    receive() external payable {}
}
