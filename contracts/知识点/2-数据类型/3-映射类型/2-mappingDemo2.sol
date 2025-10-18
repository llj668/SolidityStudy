// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract WriteMapping{
    mapping(address => uint) public balance;

    function deposit() public payable{
        // msg.sender 是调用此函数的地址
        // msg.value是随交易发送的以太币数量 （单位是wei）
        balance[msg.sender] += msg.value;
    }

    function updateBalance(address _user, uint _newBalance) public {
        // 直接用键来赋值
        balance[_user] = _newBalance;
    }
}