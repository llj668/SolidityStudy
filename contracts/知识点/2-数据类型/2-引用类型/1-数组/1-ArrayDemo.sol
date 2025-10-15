// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ArrayTest{
    // 数组的声明
    // 状态变量（Storage）：type[fixedSize] name; 或 type[] name;
    uint[3] fixedArray; // 固定大小，默认为 [0, 0, 0]
    uint[] dynamicArray; // 动态大小，默认为空 []

    function example() public pure{
        // 局部变量（Memory）：需指定 memory 关键字，且固定大小数组必须初始化长度。
        uint[] memory memArray = new uint[](5); // 动态数组在内存中初始化长度为5
    }

}