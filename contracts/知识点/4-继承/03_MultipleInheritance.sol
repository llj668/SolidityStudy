// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 多重继承示例
 * @dev 演示 Solidity 中的多重继承和 C3 线性化
 */

// 基础合约 A
contract A {
    string public nameA = "Contract A";
    
    function whoAmI() public virtual pure returns (string memory) {
        return "I am A";
    }
    
    function functionA() public pure returns (string memory) {
        return "Function from A";
    }
}

// 基础合约 B
contract B {
    string public nameB = "Contract B";
    
    function whoAmI() public virtual pure returns (string memory) {
        return "I am B";
    }
    
    function functionB() public pure returns (string memory) {
        return "Function from B";
    }
}

// 基础合约 C
contract C {
    string public nameC = "Contract C";
    
    function whoAmI() public virtual pure returns (string memory) {
        return "I am C";
    }
    
    function functionC() public pure returns (string memory) {
        return "Function from C";
    }
}

// 多重继承：继承 A 和 B
contract MultipleInheritanceAB is A, B {
    // 必须重写冲突的函数
    function whoAmI() public pure override(A, B) returns (string memory) {
        return "I am MultipleInheritanceAB";
    }
    
    // 可以调用父合约的所有函数
    function callParentFunctions() public pure returns (string memory, string memory) {
        return (functionA(), functionB());
    }
}

// 多重继承：继承 A、B 和 C
contract MultipleInheritanceABC is A, B, C {
    // 必须重写冲突的函数，并指定所有父合约
    function whoAmI() public pure override(A, B, C) returns (string memory) {
        return "I am MultipleInheritanceABC";
    }
    
    // 可以调用所有父合约的函数
    function callAllParentFunctions() public pure returns (string memory, string memory, string memory) {
        return (functionA(), functionB(), functionC());
    }
}

// 演示继承顺序的重要性
contract Vehicle {
    string public vehicleType = "Generic Vehicle";
    
    function start() public virtual pure returns (string memory) {
        return "Vehicle starting";
    }
    
    function getType() public view virtual returns (string memory) {
        return vehicleType;
    }
}

contract Car is Vehicle {
    constructor() {
        vehicleType = "Car";
    }
    
    function start() public pure override returns (string memory) {
        return "Car engine starting";
    }
    
    function honk() public pure returns (string memory) {
        return "Beep beep!";
    }
}

contract Electric {
    uint256 public batteryLevel = 100;
    
    function charge() public pure returns (string memory) {
        return "Charging battery";
    }
    
    function start() public virtual pure returns (string memory) {
        return "Electric motor starting silently";
    }
}

// 继承顺序：Vehicle -> Car -> Electric
// 最右边的合约 (Electric) 在继承链中优先级最高
contract ElectricCar is Car, Electric {
    constructor() {
        vehicleType = "Electric Car";
    }
    
    // 重写 start 函数，Electric 的版本会被优先考虑
    function start() public pure override(Car, Electric) returns (string memory) {
        return "Electric car starting silently";
    }
    
    // 组合功能
    function getFullInfo() public view returns (string memory, uint256, string memory, string memory) {
        return (vehicleType, batteryLevel, honk(), charge());
    }
}

// 演示不同继承顺序的效果
contract HybridCar is Electric, Car {
    constructor() {
        vehicleType = "Hybrid Car";
    }
    
    // 这里 Car 在右边，所以 Car 的 start 函数优先级更高
    function start() public pure override(Electric, Car) returns (string memory) {
        return "Hybrid car starting with both engine and motor";
    }
}

// 更复杂的多重继承示例
contract Flyable {
    function fly() public virtual pure returns (string memory) {
        return "Flying in the sky";
    }
    
    function getAltitude() public virtual pure returns (uint256) {
        return 1000; // 默认高度
    }
}

contract Swimmable {
    function swim() public virtual pure returns (string memory) {
        return "Swimming in water";
    }
    
    function getDepth() public virtual pure returns (uint256) {
        return 10; // 默认深度
    }
}

contract Walkable {
    function walk() public virtual pure returns (string memory) {
        return "Walking on ground";
    }
    
    function getSpeed() public virtual pure returns (uint256) {
        return 5; // 默认速度 km/h
    }
}

// 鸭子：可以飞、游泳、走路
contract Duck is Flyable, Swimmable, Walkable {
    function fly() public pure override returns (string memory) {
        return "Duck flying with wings";
    }
    
    function swim() public pure override returns (string memory) {
        return "Duck swimming with webbed feet";
    }
    
    function walk() public pure override returns (string memory) {
        return "Duck waddling on ground";
    }
    
    // 鸭子特有的功能
    function quack() public pure returns (string memory) {
        return "Quack quack!";
    }
    
    // 展示所有能力
    function showAllAbilities() public pure returns (string memory, string memory, string memory, string memory) {
        return (fly(), swim(), walk(), quack());
    }
}
