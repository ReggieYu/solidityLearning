// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 在一个有序数组中查找目标值 用二分查找法
contract BinarySearch {
    /**
     * @dev 在有序数组中进行二分查找
     * @param arr 已排序的uint数组（升序）
     * @param target 要查找的目标值
     * @return 目标值的索引（未找到返回type(uint).max）
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
        
        return type(uint).max; // 返回最大值表示未找到
    }
}