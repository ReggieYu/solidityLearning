// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ��һ�����������в���Ŀ��ֵ �ö��ֲ��ҷ�
contract BinarySearch {
    /**
     * @dev �����������н��ж��ֲ���
     * @param arr �������uint���飨����
     * @param target Ҫ���ҵ�Ŀ��ֵ
     * @return Ŀ��ֵ��������δ�ҵ�����type(uint).max��
     */
    function search(uint[] memory arr, uint target) public pure returns (uint) {
        uint left = 0;
        uint right = arr.length;
        
        while (left < right) {
            uint mid = left + (right - left) / 2;
            
            if (arr[mid] == target) {
                return mid;
            } else if (arr[mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        
        return type(uint).max; // �������ֵ��ʾδ�ҵ�
    }
}