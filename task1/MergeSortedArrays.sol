// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//��������������ϲ�Ϊһ����������
contract MergeSortedArrays {
    /**
     * @dev �ϲ�������������
     * @param a ��һ����������
     * @param b �ڶ�����������
     * @return �ϲ������������
     */
    function merge(uint[] memory a, uint[] memory b) public pure returns (uint[] memory) {
        uint[] memory result = new uint[](a.length + b.length);
        uint i = 0;
        uint j = 0;
        uint k = 0;
        
        // �ϲ���������ֱ������һ��������
        while (i < a.length && j < b.length) {
            if (a[i] < b[j]) {
                result[k++] = a[i++];
            } else {
                result[k++] = b[j++];
            }
        }
        
        // ��ʣ��Ԫ����ӵ��������
        while (i < a.length) {
            result[k++] = a[i++];
        }
        
        while (j < b.length) {
            result[k++] = b[j++];
        }
        
        return result;
    }
}