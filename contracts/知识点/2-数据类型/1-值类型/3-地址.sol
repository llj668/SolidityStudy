// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract AddressTest{
    // 地址
    // 普通地址 存储一个 20 字节的值（长度为以太坊地址的长度）
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    // 付款地址 比普通地址多了 transfer 和 send两个成员方法，用于接收转账
    // payable address 可以转账、查余额
    address payable public _address1 = payable(_address);

    // 地址成员
    // balance of address
    uint256 public balance = _address1.balance;

}