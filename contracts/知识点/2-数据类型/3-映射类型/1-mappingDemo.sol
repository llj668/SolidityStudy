// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MappingExample{
    // 将地址映射到一个 uint 类型的余额
    // 就像一个账本，每个地址对应一个余额
    mapping(address => uint) public balances;

    // 将一个 ID (uint) 映射到一个字符串 (string) 类型的用户名
    mapping(uint => string) public userNames;

    // 将地址映射到一个布尔值，用于记录该地址是否被允许
    mapping(address => bool) public isAllowed;


}