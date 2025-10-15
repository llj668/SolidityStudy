// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ArrayInitial{
    // 初始化为 [1, 2, 3]
    uint[3] fixedArray = [1,2,4];
    // 动态数组初始化为空长度 2 的数组
    uint[] dynamicArray = new uint[](2);
    // 直接赋值为 [1, 2, 3]
    uint[] dynamicArray2 = [1,2,3];
    uint[] dynamicArray3;

    function example() public returns (uint value1){
         uint[] memory memArray = new uint[](5); // 动态数组在内存中初始化长度为 5
         memArray[0] = 1;
         memArray[1] = 2;
         memArray[2] = 3;

        // 访问
         uint value = memArray[2]; // 读取值为 3
        // 长度
        uint len = memArray.length;

        dynamicArray3.push(1);
        value1 = dynamicArray3[0];

    }

}


// 初始化：
//   - 默认值：数组元素默认为零值（例如 uint 为 0，地址为 0x0）。
//   - 直接初始化：在声明时使用花括号 {}。