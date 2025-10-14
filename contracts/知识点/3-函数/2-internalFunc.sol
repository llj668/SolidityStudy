// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Parent {
    uint public value = 10;

    function _increment() internal {
        value++;
    }

    // 没有写状态可变性，默认为nonpayable,不可转账，但可以访问和修改状态变量
    function doSomethingInternal() public {
        _increment(); //可以调用内部函数
    }
}

contract Child is Parent {
    function incrementFromChild() public {
        // 子合约可以调用父合约的internal函数
        _increment();
    }
}

// internal 函数
// 定义: internal 函数只能在当前合约内部被调用，或者被继承自当前合约的派生合约调用。它不能被外部账户或合约直接调用。
// 访问范围:
// 当前合约内的其他函数。
// 从当前合约继承的派生合约中的函数。
// 特点:
// 类似于面向对象编程中的 protected 成员。
// 调用 internal 函数时，参数会直接放在内存中，而不是通过 ABI（Application Binary Interface）进行编码。
// 何时使用:
// 当你希望一个函数作为辅助函数，只供合约内部逻辑使用，但不希望被外部直接触发时。
// 在继承链中，你希望子合约能够访问和重写（override）父合约的某些逻辑时。
