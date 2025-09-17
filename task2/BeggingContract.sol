// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//使用Solidity编写一个合约，允许用户向合约地址发送以太币
//记录每个捐赠者的地址和捐赠金额
//允许合约所有者提取所有捐赠的资金

//一、任务步骤
//1、编写合约
//创建一个名为BeggingContract的合约
//合约应包含以下功能：
//一个mapping来记录每个捐赠者的捐赠金额
//一个donate函数，允许用户向合约发送以太币，并记录捐赠信息
//一个withdraw函数，允许合约所有者提取所有资金
//一个getDonation函数，允许查询某个地址的捐赠金额
//使用payable修饰符和address.transfer实现支付和提款

//2、部署合约
//在Remix IDE中编译合约
//部署合约到Sepolia测试网

//3、测试合约
//使用MetaMask向合约发送以太币，测试donate功能
//调用withdraw函数，测试合约所有者是否可以提取资金
//调用getDonation函数，查询某个地址的捐赠金额

//二、任务要求
//1、合约代码：
//使用mapping记录捐赠者的地址和金额
//使用payable修饰符实现donate和withdraw函数
//使用onlyOwner修饰符限制withdraw函数只能由合约所有者调用

//2、测试网部署：
//合约必须部署到Sepolia测试网
//功能测试：确保donate、withdraw和getDonation函数正常工作

//3、提交内容
//合约代码：提交Solidity合约文件（如 BeggingContract.sol）
//合约地址：提交部署到测试网的合约地址
//测试截图：提交在Remix或Etherscan上测试合约的截图

//4、其他功能
//捐赠事件：添加Donation事件，记录每次捐赠的地址和金额
//捐赠排行榜：实现一个功能，显示捐赠金额最多的前3个地址
//时间限制：添加一个时间限制，只有在特定时间段内才能捐赠

contract BeggingContract {
    // contract owner
    address public owner;

    // record every donor's amount
    mapping(address => uint256) public donations;

    // donation event
    event Donation(address indexed donor, uint256 amount, uint256 timestamp);

    // donate starttime(Unix timestamp)
    uint256 public startTime;

    // donate endtime
    uint256 public endTime;

    // top donors
    address[3] private topDonors;
    uint256[3] private topAmounts;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call");
        _;
    }

    modifier duringDonationInterval() {
        if (startTime > 0 && endTime > 0) {
            require(block.timestamp >= startTime, "donation not start yet");
            require(block.timestamp <= endTime, "donation ended");
        }
        _;
    }

    constructor(uint256 _startTime, uint256 _endTime) {
        startTime = _startTime;
        endTime = _endTime;
        owner = msg.sender;
        require(
            _startTime > 0 && _endTime > _startTime,
            "invalid time interval"
        );
    }

    receive() external payable {
        _donate();
    }

    fallback() external payable {
        if (msg.value > 0) {
            _donate();
        }
    }

    function donate() external payable duringDonationInterval {
        _donate();
    }

    // get top three donor
    function getTopDonorList()
        external
        view
        returns (uint256[3] memory, address[3] memory)
    {
        return (topAmounts, topDonors);
    }

    // set time window(limit to owner)
    function setWindowInterval(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        require(
            _endTime != 0 && _startTime != 9 && _endTime > _startTime,
            "invalid time setting"
        );
        startTime = _startTime;
        endTime = _endTime;
    }

    // donate function(payable + time limit)
    function _donate() internal duringDonationInterval {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "not during the donation interval"
        );
        require(msg.value > 0, "donation amount must be greater than zero");

        address donor = msg.sender;
        uint256 oldAmount = donations[donor];
        uint256 newAmount = oldAmount + msg.value;
        donations[msg.sender] = newAmount;

        _updateTopDonor(donor, newAmount);

        emit Donation(msg.sender, msg.value, block.timestamp);
    }

    function _updateTopDonor(address donor, uint256 newAmount) private {
        // check if the donor is in the topDonors list or not
        for (uint256 i = 0; i < 3; i++) {
            if (topDonors[i] == donor) {
                topAmounts[i] = newAmount;
                _refreshTopDonorList();
                return;
            }
        }

        // if not in the list then check whether the donor can be qualified to be in the top donor list
        for (uint256 i = 0; i < 3; i++) {
            // if the new amount is greater than any item of the top donor list, then insert
            // the new donr and shift down the item behind the new item
            if (newAmount > topAmounts[i]) {
                // 1、first shift down the item behind the target position
                // shift down from the last item
                for (uint256 j = 2; j > i; j--) {
                    topDonors[j] = topDonors[j - 1];
                    topAmounts[j] = topAmounts[j - 1];
                }

                topDonors[i] = donor;
                topAmounts[i] = newAmount;
                return;
            }
        }
    }

    function _refreshTopDonorList() private {
        for (uint i = 0; i < 2; i++) {
            for (uint256 j = i + 1; j < 3; j++) {
                if (topAmounts[i] < topAmounts[j]) {
                    (topAmounts[i], topAmounts[j]) = (
                        topAmounts[j],
                        topAmounts[i]
                    );
                    (topDonors[i], topDonors[j]) = (topDonors[j], topDonors[i]);
                }
            }
        }
    }

    // limit to the owner
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "no funds to withdraw");
        payable(owner).transfer(balance);
    }

    // get target address's donation
    function getDonation(address donor) public view returns (uint256) {
        return donations[donor];
    }
}
