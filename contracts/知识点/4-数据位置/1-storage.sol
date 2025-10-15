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

}



// storage：合约里的状态变量默认都是 storage，存储在链上。