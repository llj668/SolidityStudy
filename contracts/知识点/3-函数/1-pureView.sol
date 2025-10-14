// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StateExample {
    uint public myStateVar = 10;

    // view 函数：读取装入爱变量 myStateVar
    function getState() public view returns (uint) {
        return myStateVar;
    }

    // pure函数：值进行计算，不读不写状态
    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }

    // 另一个 view 函数：可以访问全局变量
    // msg.sender: 这是一个全局变量，表示当前调用此函数的外部账户或合约的地址。
    // address(this).balance: address(this) 表示当前合约自身的地址，.balance 则获取该地址所持有的以太币数量（以 Wei 为单位），类型是 uint。
    function getSenderAndBalance() public view returns (address, uint) {
        return (msg.sender, address(this).balance);
    }

    // 尝试在 pure 函数中读取状态变量，编译器会报错
    // function invalidPure() public pure returns (uint) {
    //     return myStateVar; // 错误：纯函数不能读取状态
    // }
}
