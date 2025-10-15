// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ReturnExample {
    // 未命名单一返回值
    function getSingleValue() public pure returns(uint) {
        return 100;
    }

    // 命名单一返回值
    function getNamedValue() public pure returns (uint value) {
        value = 200; //直接赋值，不用返回
    }

    // 未命名单多返回值
    function getMultipleValues() public pure returns (uint, uint) {
        return (100, 200);
    }

    // 命名单多返回值
    function getNamedValues() public pure returns (uint value1, uint value2) {
        value1 = 100;
        value2 = 300;
    }

    // 调用
    function callDemo() public pure returns (uint){
        (uint a,uint b) = getNamedValues();
        return a + b;
    }

}
