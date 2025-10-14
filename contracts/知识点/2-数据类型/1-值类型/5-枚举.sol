// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract EnumTest {
    // 用 enum 将 uint 0， 1， 2 表示为 GoLeft， GoRight， GoUp， GoDown
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoUp,
        GoDown
    }
    ActionChoices public choice = ActionChoices.GoLeft;
    ActionChoices public choice1 = ActionChoices.GoRight;

    // enum可以和uint 显示地转换
    function enumToUint(ActionChoices _choice) external pure returns (uint) {
        return uint(_choice);
    }
}
// 枚举（enum）是 Solidity 中用户定义的数据类型。它主要用于为 uint 类型的值分配名称，使程序易于阅读和维护
// 它与 C 语言中的 enum 类型类似，使用名称来代表一系列从 0 开始的 uint 类型的值：
