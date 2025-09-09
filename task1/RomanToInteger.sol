// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//实现罗马数字转数整数, 用solidity实现
contract RomanToInteger {
    // 罗马字符到数字的映射
    mapping(bytes1 => uint256) private romanValues;
    
    constructor() {
        // 初始化罗马数字映射
        romanValues['I'] = 1;
        romanValues['V'] = 5;
        romanValues['X'] = 10;
        romanValues['L'] = 50;
        romanValues['C'] = 100;
        romanValues['D'] = 500;
        romanValues['M'] = 1000;
    }
    
    function romanToInt(string memory s) public view returns (uint256) {
        uint256 total = 0;
        uint256 prevValue = 0;
        
        // 将字符串转换为bytes以便遍历
        bytes memory roman = bytes(s);
        
        // 从右向左遍历罗马数字
        for (uint256 i = roman.length; i > 0; i--) {
            uint256 currentValue = romanValues[roman[i-1]];
            
            // 如果当前值小于前一个值，则减去当前值
            if (currentValue < prevValue) {
                total -= currentValue;
            } else {
                total += currentValue;
            }
            
            prevValue = currentValue;
        }
        
        // 验证结果是否在有效范围内
        require(total > 0 && total < 4000, "Invalid Roman numeral");
        
        return total;
    }
}