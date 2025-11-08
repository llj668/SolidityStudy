// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ModifierBasic {
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    // 定义修饰器：检查调用者是否是合约所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _; //下划线表示被修饰函数的代码会在这里执行
    }

    // 使用修饰器
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    // 任何人都可以调用
    function publicFunction() public pure returns (string memory) {
        return "Anyone can call this";
    }
}
