// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//将两个有序数组合并为一个有序数组
contract MergeSortedArrays {
    /**
     * @dev 合并两个有序数组
     * @param a 第一个有序数组
     * @param b 第二个有序数组
     * @return 合并后的有序数组
     */
    function merge(uint[] memory a, uint[] memory b) public pure returns (uint[] memory) {
        uint[] memory result = new uint[](a.length + b.length);
        uint i = 0;
        uint j = 0;
        uint k = 0;
        
        // 合并两个数组直到其中一个遍历完
        while (i < a.length && j < b.length) {
            if (a[i] < b[j]) {
                result[k++] = a[i++];
            } else {
                result[k++] = b[j++];
            }
        }
        
        // 将剩余元素添加到结果数组
        while (i < a.length) {
            result[k++] = a[i++];
        }
        
        while (j < b.length) {
            result[k++] = b[j++];
        }
        
        return result;
    }
}