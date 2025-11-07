// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 函数重写示例
 * @dev 演示 virtual 和 override 关键字的使用
 */

// 基础形状合约
contract Shape {
    string public name;
    
    constructor(string memory _name) {
        name = _name;
    }
    
    // 虚函数 - 必须被子合约实现
    function area() public virtual pure returns (uint256) {
        return 0; // 默认实现
    }
    
    // 虚函数 - 可以被重写
    function perimeter() public virtual pure returns (uint256) {
        return 0; // 默认实现
    }
    
    // 普通函数 - 不能被重写
    function getShapeType() public pure returns (string memory) {
        return "Generic Shape";
    }
    
    // 虚函数 - 返回形状描述
    function describe() public view virtual returns (string memory) {
        return string(abi.encodePacked("This is a ", name));
    }
}

// 矩形合约
contract Rectangle is Shape {
    uint256 public width;
    uint256 public height;
    
    constructor(uint256 _width, uint256 _height) Shape("Rectangle") {
        width = _width;
        height = _height;
    }
    
    // 重写面积计算
    function area() public view override returns (uint256) {
        return width * height;
    }
    
    // 重写周长计算
    function perimeter() public view override returns (uint256) {
        return 2 * (width + height);
    }
    
    // 重写描述函数
    function describe() public view override returns (string memory) {
        return string(abi.encodePacked(
            "Rectangle with width ", 
            uintToString(width), 
            " and height ", 
            uintToString(height)
        ));
    }
    
    // 辅助函数：将 uint 转换为 string
    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint256 j = v;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (v != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(v - v / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            v /= 10;
        }
        return string(bstr);
    }
}

// 圆形合约
contract Circle is Shape {
    uint256 public radius;
    
    constructor(uint256 _radius) Shape("Circle") {
        radius = _radius;
    }
    
    // 重写面积计算 (使用简化的 π ≈ 3)
    function area() public view override returns (uint256) {
        return 3 * radius * radius;
    }
    
    // 重写周长计算 (使用简化的 π ≈ 3)
    function perimeter() public view override returns (uint256) {
        return 6 * radius;
    }
    
    // 重写描述函数
    function describe() public view override returns (string memory) {
        return string(abi.encodePacked(
            "Circle with radius ", 
            uintToString(radius)
        ));
    }
    
    // 圆形特有的方法
    function diameter() public view returns (uint256) {
        return 2 * radius;
    }
    
    // 辅助函数：将 uint 转换为 string
    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint256 j = v;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (v != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(v - v / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            v /= 10;
        }
        return string(bstr);
    }
}

// 三角形合约
contract Triangle is Shape {
    uint256 public side1;
    uint256 public side2;
    uint256 public side3;
    
    constructor(uint256 _side1, uint256 _side2, uint256 _side3) Shape("Triangle") {
        require(_side1 + _side2 > _side3, "Invalid triangle");
        require(_side1 + _side3 > _side2, "Invalid triangle");
        require(_side2 + _side3 > _side1, "Invalid triangle");
        
        side1 = _side1;
        side2 = _side2;
        side3 = _side3;
    }
    
    // 重写周长计算
    function perimeter() public view override returns (uint256) {
        return side1 + side2 + side3;
    }
    
    // 使用海伦公式计算面积（简化版本）
    function area() public view override returns (uint256) {
        uint256 s = perimeter() / 2;
        // 简化计算，实际应该使用平方根
        return s * (s - side1) * (s - side2) * (s - side3) / 1000;
    }
    
    // 重写描述函数
    function describe() public view override returns (string memory) {
        return string(abi.encodePacked(
            "Triangle with sides ", 
            uintToString(side1), ", ",
            uintToString(side2), ", ",
            uintToString(side3)
        ));
    }
    
    // 检查是否为等边三角形
    function isEquilateral() public view returns (bool) {
        return side1 == side2 && side2 == side3;
    }
    
    // 辅助函数：将 uint 转换为 string
    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint256 j = v;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (v != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(v - v / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            v /= 10;
        }
        return string(bstr);
    }
}
