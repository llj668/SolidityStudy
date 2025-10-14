// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ExternalFunc {
    uint public count = 0;

    function incrementExternal() external {
        count++;
    }

    function getCount() external view returns (uint) {
        return count;
    }

    // 尝试在合约内部直接调用 external 函数会导致编译器错误
    // function tryToCallExternalInternally() public {
    //     incrementExternal(); // 错误：External function cannot be called from the same contract.
    // }

    // 如果想在内部触发 external 函数，需要通过 'this.' 语法，这会发起一次新的外部调用
    function callExternalViaThis() public {
        this.incrementExternal(); // 这会发起一个内部的外部调用
    }
}
