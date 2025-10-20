// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./AuctionImplementation.sol";

/**
 * V2 实现
 * 在V1基础上增加一个只读函数version(), 验证升级生效
 * 保持存储布局不变(通过继承V1)
 */
contract AuctionImplementationV2 is AuctionImplementation {
    function version() external pure returns (string memory) {
        return "V2";
    }
}
