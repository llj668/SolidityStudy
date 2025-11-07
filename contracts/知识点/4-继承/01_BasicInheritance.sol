// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 基础继承示例
 * @dev 演示 Solidity 中最基本的继承用法
 */

// 父合约 - 动物
contract Animal {
    string public name;
    uint256 public age;
    
    // 事件
    event AnimalCreated(string name, uint256 age);
    
    constructor(string memory _name, uint256 _age) {
        name = _name;
        age = _age;
        emit AnimalCreated(_name, _age);
    }
    
    // 虚函数 - 可以被子合约重写
    function eat() public virtual returns (string memory) {
        return string(abi.encodePacked(name, " is eating"));
    }
    
    function sleep() public virtual returns (string memory) {
        return string(abi.encodePacked(name, " is sleeping"));
    }
    
    // 获取动物信息
    function getInfo() public view returns (string memory, uint256) {
        return (name, age);
    }
}

// 子合约 - 狗
contract Dog is Animal {
    string public breed; // 品种
    
    // 调用父合约构造函数
    constructor(string memory _name, uint256 _age, string memory _breed) 
        Animal(_name, _age) {
        breed = _breed;
    }
    
    // 狗特有的方法
    function bark() public pure returns (string memory) {
        return "Woof! Woof!";
    }
    
    // 重写父合约的 eat 方法
    function eat() public view override returns (string memory) {
        return string(abi.encodePacked(name, " the dog is eating dog food"));
    }
    
    // 获取完整信息（包括品种）
    function getFullInfo() public view returns (string memory, uint256, string memory) {
        return (name, age, breed);
    }
}

// 子合约 - 猫
contract Cat is Animal {
    bool public isIndoor; // 是否为室内猫
    
    constructor(string memory _name, uint256 _age, bool _isIndoor) 
        Animal(_name, _age) {
        isIndoor = _isIndoor;
    }
    
    // 猫特有的方法
    function meow() public pure returns (string memory) {
        return "Meow! Meow!";
    }
    
    // 重写父合约的 eat 方法
    function eat() public view override returns (string memory) {
        return string(abi.encodePacked(name, " the cat is eating cat food"));
    }
    
    // 重写父合约的 sleep 方法
    function sleep() public view override returns (string memory) {
        if (isIndoor) {
            return string(abi.encodePacked(name, " is sleeping on the sofa"));
        } else {
            return string(abi.encodePacked(name, " is sleeping outside"));
        }
    }
}
