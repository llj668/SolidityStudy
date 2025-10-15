// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract payableFunc{
    uint public number = 5;

    function minus() internal{
        number = number - 1;
    }

    function minusCall() external {
        minus();
    }

    // payable: 递钱，能给合约支付eth的函数
    function minusPayable() external payable returns(uint256 balance) {
        minus();    
        balance = address(this).balance;
    }
}
