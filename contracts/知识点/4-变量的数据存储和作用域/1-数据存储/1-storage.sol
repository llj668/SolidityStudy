// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StorageExample{
    // userBalances 和 owner 都是状态变量，它们被永久存储在storage中。
    mapping(address=>uint256) public userBalances;
    address public owner;

    constructor(){
        owner = msg.sender; // 写入 storage
    }

    function deposit() public payable {
        // 修改 storage (先 SLOAD 读取旧值，再 SSTORE 写入新值)
        userBalances[msg.sender] += msg.value;
    }

    // `storage` 指针的例子
    // 尽管 _user 是一个局部变量，但它是一个指向 storage 的指针。
    // 修改 _user 就等于直接修改 storage 中的状态变量。
    function doubleBalance(address user) public{
        //这里没有创建新变量，而是获取了 userBalances[user] 在 storage 中的地址引用
        uint256 storage _balance = userBalances[user];
        // 这行代码直接修改了 userBalances[user] 的值
        _balance *= 2;

    }
}



// storage：合约里的状态变量默认都是 storage，存储在链上。