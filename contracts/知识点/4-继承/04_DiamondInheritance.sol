// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 菱形继承示例
 * @dev 演示菱形继承问题的解决方案和 C3 线性化
 */

// 基础合约
contract Base {
    string public baseName = "Base Contract";
    
    function identify() public virtual pure returns (string memory) {
        return "I am Base";
    }
    
    function baseFunction() public pure returns (string memory) {
        return "Function from Base";
    }
    
    // 虚函数，会在菱形继承中产生冲突
    function conflictFunction() public virtual pure returns (string memory) {
        return "Base implementation";
    }
}

// 左分支
contract Left is Base {
    string public leftName = "Left Contract";
    
    function identify() public virtual pure override returns (string memory) {
        return "I am Left";
    }
    
    function leftFunction() public pure returns (string memory) {
        return "Function from Left";
    }
    
    // 重写冲突函数
    function conflictFunction() public virtual pure override returns (string memory) {
        return "Left implementation";
    }
}

// 右分支
contract Right is Base {
    string public rightName = "Right Contract";
    
    function identify() public virtual pure override returns (string memory) {
        return "I am Right";
    }
    
    function rightFunction() public pure returns (string memory) {
        return "Function from Right";
    }
    
    // 重写冲突函数
    function conflictFunction() public virtual pure override returns (string memory) {
        return "Right implementation";
    }
}

// 菱形继承：同时继承 Left 和 Right（它们都继承自 Base）
contract Diamond is Left, Right {
    string public diamondName = "Diamond Contract";
    
    // 必须明确指定重写哪些父合约的函数
    function identify() public pure override(Left, Right) returns (string memory) {
        return "I am Diamond";
    }
    
    // 解决冲突函数的菱形继承问题
    function conflictFunction() public pure override(Left, Right) returns (string memory) {
        return "Diamond implementation";
    }
    
    // 可以调用所有继承链上的函数
    function callAllFunctions() public pure returns (
        string memory,
        string memory,
        string memory,
        string memory
    ) {
        return (
            baseFunction(),
            leftFunction(),
            rightFunction(),
            conflictFunction()
        );
    }
}

// 更复杂的菱形继承示例
contract Animal {
    function makeSound() public virtual pure returns (string memory) {
        return "Some animal sound";
    }
    
    function eat() public virtual pure returns (string memory) {
        return "Animal is eating";
    }
}

contract Mammal is Animal {
    function makeSound() public virtual pure override returns (string memory) {
        return "Mammal sound";
    }
    
    function giveBirth() public pure returns (string memory) {
        return "Giving birth to live young";
    }
    
    function eat() public virtual pure override returns (string memory) {
        return "Mammal is eating";
    }
}

contract Aquatic is Animal {
    function makeSound() public virtual pure override returns (string memory) {
        return "Underwater sound";
    }
    
    function swim() public pure returns (string memory) {
        return "Swimming in water";
    }
    
    function eat() public virtual pure override returns (string memory) {
        return "Aquatic animal is eating underwater";
    }
}

// 海洋哺乳动物：菱形继承
contract MarineMammal is Mammal, Aquatic {
    // 解决菱形继承中的函数冲突
    function makeSound() public pure override(Mammal, Aquatic) returns (string memory) {
        return "Marine mammal sound (like whale song)";
    }
    
    function eat() public pure override(Mammal, Aquatic) returns (string memory) {
        return "Marine mammal is eating fish";
    }
    
    // 组合两个分支的功能
    function getCapabilities() public pure returns (string memory, string memory, string memory) {
        return (giveBirth(), swim(), makeSound());
    }
}

// 演示继承顺序对解决冲突的影响
contract Vehicle {
    function start() public virtual pure returns (string memory) {
        return "Vehicle starting";
    }
    
    function getType() public virtual pure returns (string memory) {
        return "Generic Vehicle";
    }
}

contract LandVehicle is Vehicle {
    function start() public virtual pure override returns (string memory) {
        return "Land vehicle starting on road";
    }
    
    function drive() public pure returns (string memory) {
        return "Driving on land";
    }
    
    function getType() public virtual pure override returns (string memory) {
        return "Land Vehicle";
    }
}

contract WaterVehicle is Vehicle {
    function start() public virtual pure override returns (string memory) {
        return "Water vehicle starting in water";
    }
    
    function sail() public pure returns (string memory) {
        return "Sailing on water";
    }
    
    function getType() public virtual pure override returns (string memory) {
        return "Water Vehicle";
    }
}

// 两栖车辆：继承顺序 LandVehicle, WaterVehicle
contract AmphibiousVehicle1 is LandVehicle, WaterVehicle {
    function start() public pure override(LandVehicle, WaterVehicle) returns (string memory) {
        return "Amphibious vehicle starting (version 1)";
    }
    
    function getType() public pure override(LandVehicle, WaterVehicle) returns (string memory) {
        return "Amphibious Vehicle (Land->Water priority)";
    }
    
    function getAllCapabilities() public pure returns (string memory, string memory, string memory) {
        return (drive(), sail(), start());
    }
}

// 两栖车辆：继承顺序 WaterVehicle, LandVehicle
contract AmphibiousVehicle2 is WaterVehicle, LandVehicle {
    function start() public pure override(WaterVehicle, LandVehicle) returns (string memory) {
        return "Amphibious vehicle starting (version 2)";
    }
    
    function getType() public pure override(WaterVehicle, LandVehicle) returns (string memory) {
        return "Amphibious Vehicle (Water->Land priority)";
    }
    
    function getAllCapabilities() public pure returns (string memory, string memory, string memory) {
        return (sail(), drive(), start());
    }
}

// 演示多层菱形继承
contract A {
    function funcA() public virtual pure returns (string memory) {
        return "A";
    }
}

contract B is A {
    function funcA() public virtual pure override returns (string memory) {
        return "B";
    }
    
    function funcB() public pure returns (string memory) {
        return "B specific";
    }
}

contract C is A {
    function funcA() public virtual pure override returns (string memory) {
        return "C";
    }
    
    function funcC() public pure returns (string memory) {
        return "C specific";
    }
}

contract D is B, C {
    function funcA() public pure override(B, C) returns (string memory) {
        return "D";
    }
    
    function funcD() public pure returns (string memory) {
        return "D specific";
    }
}

contract E is A {
    function funcA() public virtual pure override returns (string memory) {
        return "E";
    }
    
    function funcE() public pure returns (string memory) {
        return "E specific";
    }
}

// 复杂的多层菱形继承
contract ComplexDiamond is D, E {
    function funcA() public pure override(D, E) returns (string memory) {
        return "ComplexDiamond";
    }
    
    // 可以调用所有继承链上的函数
    function callAllSpecificFunctions() public pure returns (
        string memory,
        string memory,
        string memory,
        string memory,
        string memory
    ) {
        return (
            funcA(),
            funcB(),
            funcC(),
            funcD(),
            funcE()
        );
    }
}
