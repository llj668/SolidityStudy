// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ByteTest{
    bytes32 public  _byte32 = "MiniSolidity";
    bytes1 public _byte = _byte32[0];


}

// 定 长 字 节 数 组： 属 于 值 类 型， 根 据 每 个 元 素 存 储 数 据 的 大 小 分 为
// bytes1、bytes2、…、bytes32 等一系列类型。每个元素最多存储 32 字节的数据。数组长度在声明之后不能改变。


// 不定长字节数组：属于引用类型，数组长度在声明之后可以改变，包括 bytes 等，后面会详细介绍。