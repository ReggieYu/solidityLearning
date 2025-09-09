// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//实现整数转罗马数字
contract IntegerToRoman {
    // 定义罗马数字字符
    string[] private thousands = ["", "M", "MM", "MMM"];
    string[] private hundreds = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"];
    string[] private tens = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"];
    string[] private ones = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];

    function intToRoman(uint256 num) public view returns (string memory) {
        require(num > 0 && num < 4000, "Number out of range (1-3999)");
        
        string memory roman;
        
        // 处理千位
        roman = string(abi.encodePacked(roman, thousands[num / 1000]));
        num %= 1000;
        
        // 处理百位
        roman = string(abi.encodePacked(roman, hundreds[num / 100]));
        num %= 100;
        
        // 处理十位
        roman = string(abi.encodePacked(roman, tens[num / 10]));
        num %= 10;
        
        // 处理个位
        roman = string(abi.encodePacked(roman, ones[num]));
        
        return roman;
    }
}