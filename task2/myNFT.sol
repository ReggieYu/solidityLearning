// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    // 铸造NFT(仅所有者可调用) 并设置tokenURI
    function mintNFT(
        address recepient,
        string memory tokenURI
    ) public onlyOwner returns (uint256) {
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();

        _safeMint(recepient, newTokenId);
        _tokenURIs[newTokenId] = tokenURI;

        return newTokenId;
    }

    // 重写tokenURI函数, 返回元数据链接
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "nonexistent token");
        return _tokenURIs[tokenId];
    }
}
