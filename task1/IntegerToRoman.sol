// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//ʵ������ת��������
contract IntegerToRoman {
    // �������������ַ�
    string[] private thousands = ["", "M", "MM", "MMM"];
    string[] private hundreds = ["", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"];
    string[] private tens = ["", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"];
    string[] private ones = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];

    function intToRoman(uint256 num) public view returns (string memory) {
        require(num > 0 && num < 4000, "Number out of range (1-3999)");
        
        string memory roman;
        
        // ����ǧλ
        roman = string(abi.encodePacked(roman, thousands[num / 1000]));
        num %= 1000;
        
        // �����λ
        roman = string(abi.encodePacked(roman, hundreds[num / 100]));
        num %= 100;
        
        // ����ʮλ
        roman = string(abi.encodePacked(roman, tens[num / 10]));
        num %= 10;
        
        // �����λ
        roman = string(abi.encodePacked(roman, ones[num]));
        
        return roman;
    }
}