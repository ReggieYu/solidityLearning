// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//ʵ����������ת������, ��solidityʵ��
contract RomanToInteger {
    // �����ַ������ֵ�ӳ��
    mapping(bytes1 => uint256) private romanValues;
    
    constructor() {
        // ��ʼ����������ӳ��
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
        
        // ���ַ���ת��Ϊbytes�Ա����
        bytes memory roman = bytes(s);
        
        // �������������������
        for (uint256 i = roman.length; i > 0; i--) {
            uint256 currentValue = romanValues[roman[i-1]];
            
            // �����ǰֵС��ǰһ��ֵ�����ȥ��ǰֵ
            if (currentValue < prevValue) {
                total -= currentValue;
            } else {
                total += currentValue;
            }
            
            prevValue = currentValue;
        }
        
        // ��֤����Ƿ�����Ч��Χ��
        require(total > 0 && total < 4000, "Invalid Roman numeral");
        
        return total;
    }
}