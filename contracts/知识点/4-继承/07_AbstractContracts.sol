// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 抽象合约示例
 * @dev 演示抽象合约的定义和使用
 */

// 抽象形状合约
abstract contract Shape {
    string public name;
    
    constructor(string memory _name) {
        name = _name;
    }
    
    // 抽象函数：必须被子合约实现
    function area() public virtual pure returns (uint256);
    function perimeter() public virtual pure returns (uint256);
    
    // 具体函数：有默认实现
    function description() public view returns (string memory) {
        return string(abi.encodePacked("This is a ", name));
    }
    
    // 虚函数：可以被重写
    function getShapeType() public virtual pure returns (string memory) {
        return "Generic Shape";
    }
    
    // 内部函数：供子合约使用
    function _validateDimensions(uint256 dimension) internal pure returns (bool) {
        return dimension > 0 && dimension < 1000000;
    }
}

// 具体实现：矩形
contract Rectangle is Shape {
    uint256 public width;
    uint256 public height;
    
    constructor(uint256 _width, uint256 _height) Shape("Rectangle") {
        require(_validateDimensions(_width), "Invalid width");
        require(_validateDimensions(_height), "Invalid height");
        width = _width;
        height = _height;
    }
    
    // 实现抽象函数
    function area() public view override returns (uint256) {
        return width * height;
    }
    
    function perimeter() public view override returns (uint256) {
        return 2 * (width + height);
    }
    
    // 重写虚函数
    function getShapeType() public pure override returns (string memory) {
        return "Rectangle";
    }
    
    // 矩形特有的功能
    function isSquare() public view returns (bool) {
        return width == height;
    }
}

// 具体实现：圆形
contract Circle is Shape {
    uint256 public radius;
    
    constructor(uint256 _radius) Shape("Circle") {
        require(_validateDimensions(_radius), "Invalid radius");
        radius = _radius;
    }
    
    // 实现抽象函数（使用简化的 π ≈ 3）
    function area() public view override returns (uint256) {
        return 3 * radius * radius;
    }
    
    function perimeter() public view override returns (uint256) {
        return 6 * radius;
    }
    
    // 重写虚函数
    function getShapeType() public pure override returns (string memory) {
        return "Circle";
    }
    
    // 圆形特有的功能
    function diameter() public view returns (uint256) {
        return 2 * radius;
    }
}

// 抽象动物合约
abstract contract Animal {
    string public species;
    uint256 public age;
    
    event AnimalSound(string sound);
    
    constructor(string memory _species, uint256 _age) {
        species = _species;
        age = _age;
    }
    
    // 抽象函数：每种动物都有不同的叫声
    function makeSound() public virtual returns (string memory);
    
    // 抽象函数：每种动物的移动方式不同
    function move() public virtual pure returns (string memory);
    
    // 具体函数：所有动物都会吃
    function eat(string memory food) public returns (string memory) {
        return string(abi.encodePacked(species, " is eating ", food));
    }
    
    // 虚函数：可以被重写
    function sleep() public virtual pure returns (string memory) {
        return "Animal is sleeping";
    }
    
    // 内部函数：年龄验证
    function _isAdult() internal view returns (bool) {
        return age >= 2;
    }
}

// 具体实现：狗
contract Dog is Animal {
    string public breed;
    
    constructor(string memory _breed, uint256 _age) Animal("Dog", _age) {
        breed = _breed;
    }
    
    // 实现抽象函数
    function makeSound() public override returns (string memory) {
        string memory sound = "Woof!";
        emit AnimalSound(sound);
        return sound;
    }
    
    function move() public pure override returns (string memory) {
        return "Dog is running";
    }
    
    // 重写虚函数
    function sleep() public pure override returns (string memory) {
        return "Dog is sleeping in its bed";
    }
    
    // 狗特有的功能
    function fetch() public pure returns (string memory) {
        return "Dog is fetching the ball";
    }
    
    function canGuard() public view returns (bool) {
        return _isAdult();
    }
}

// 具体实现：鸟
contract Bird is Animal {
    bool public canFly;
    
    constructor(string memory _species, uint256 _age, bool _canFly) Animal(_species, _age) {
        canFly = _canFly;
    }
    
    // 实现抽象函数
    function makeSound() public override returns (string memory) {
        string memory sound = "Tweet!";
        emit AnimalSound(sound);
        return sound;
    }
    
    function move() public view override returns (string memory) {
        if (canFly) {
            return "Bird is flying";
        } else {
            return "Bird is walking";
        }
    }
    
    // 重写虚函数
    function sleep() public pure override returns (string memory) {
        return "Bird is sleeping on a branch";
    }
    
    // 鸟特有的功能
    function buildNest() public view returns (string memory) {
        if (_isAdult()) {
            return "Bird is building a nest";
        } else {
            return "Bird is too young to build a nest";
        }
    }
}

// 抽象车辆合约
abstract contract Vehicle {
    string public brand;
    string public model;
    uint256 public year;
    
    event VehicleStarted(string vehicleInfo);
    event VehicleStopped(string vehicleInfo);
    
    constructor(string memory _brand, string memory _model, uint256 _year) {
        brand = _brand;
        model = _model;
        year = _year;
    }
    
    // 抽象函数：不同车辆的启动方式不同
    function start() public virtual returns (string memory);
    
    // 抽象函数：不同车辆的燃料类型不同
    function getFuelType() public virtual pure returns (string memory);
    
    // 抽象函数：最大速度
    function getMaxSpeed() public virtual pure returns (uint256);
    
    // 具体函数：所有车辆都可以停止
    function stop() public returns (string memory) {
        string memory info = getVehicleInfo();
        emit VehicleStopped(info);
        return string(abi.encodePacked(info, " has stopped"));
    }
    
    // 虚函数：可以被重写
    function getVehicleInfo() public view virtual returns (string memory) {
        return string(abi.encodePacked(brand, " ", model, " (", uintToString(year), ")"));
    }
    
    // 内部辅助函数
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

// 具体实现：汽车
contract Car is Vehicle {
    uint256 public engineSize; // 引擎排量
    
    constructor(
        string memory _brand,
        string memory _model,
        uint256 _year,
        uint256 _engineSize
    ) Vehicle(_brand, _model, _year) {
        engineSize = _engineSize;
    }
    
    // 实现抽象函数
    function start() public override returns (string memory) {
        string memory info = getVehicleInfo();
        emit VehicleStarted(info);
        return string(abi.encodePacked(info, " engine started"));
    }
    
    function getFuelType() public pure override returns (string memory) {
        return "Gasoline";
    }
    
    function getMaxSpeed() public view override returns (uint256) {
        // 根据引擎排量计算最大速度
        return 100 + (engineSize / 100);
    }
    
    // 重写虚函数
    function getVehicleInfo() public view override returns (string memory) {
        return string(abi.encodePacked(
            super.getVehicleInfo(),
            " - Engine: ",
            uintToString(engineSize),
            "cc"
        ));
    }
    
    // 汽车特有功能
    function honk() public pure returns (string memory) {
        return "Beep beep!";
    }
}

// 具体实现：电动车
contract ElectricCar is Vehicle {
    uint256 public batteryCapacity; // 电池容量 (kWh)
    
    constructor(
        string memory _brand,
        string memory _model,
        uint256 _year,
        uint256 _batteryCapacity
    ) Vehicle(_brand, _model, _year) {
        batteryCapacity = _batteryCapacity;
    }
    
    // 实现抽象函数
    function start() public override returns (string memory) {
        string memory info = getVehicleInfo();
        emit VehicleStarted(info);
        return string(abi.encodePacked(info, " electric motor started silently"));
    }
    
    function getFuelType() public pure override returns (string memory) {
        return "Electricity";
    }
    
    function getMaxSpeed() public view override returns (uint256) {
        // 根据电池容量计算最大速度
        return 80 + (batteryCapacity * 2);
    }
    
    // 重写虚函数
    function getVehicleInfo() public view override returns (string memory) {
        return string(abi.encodePacked(
            super.getVehicleInfo(),
            " - Battery: ",
            uintToString(batteryCapacity),
            "kWh"
        ));
    }
    
    // 电动车特有功能
    function charge() public pure returns (string memory) {
        return "Electric car is charging";
    }
    
    function getRange() public view returns (uint256) {
        // 根据电池容量计算续航里程
        return batteryCapacity * 5; // 简化计算：每kWh续航5km
    }
}

// 抽象工厂模式示例
abstract contract ShapeFactory {
    // 抽象函数：创建形状
    function createShape(uint256[] memory dimensions) public virtual returns (address);
    
    // 具体函数：验证形状
    function validateShape(address shapeAddress) public view returns (bool) {
        // 检查是否实现了 Shape 接口
        try Shape(shapeAddress).area() returns (uint256) {
            return true;
        } catch {
            return false;
        }
    }
}

// 具体工厂：矩形工厂
contract RectangleFactory is ShapeFactory {
    address[] public createdRectangles;
    
    function createShape(uint256[] memory dimensions) public override returns (address) {
        require(dimensions.length == 2, "Rectangle requires 2 dimensions");
        
        Rectangle newRectangle = new Rectangle(dimensions[0], dimensions[1]);
        address rectangleAddress = address(newRectangle);
        
        createdRectangles.push(rectangleAddress);
        return rectangleAddress;
    }
    
    function getCreatedRectangles() public view returns (address[] memory) {
        return createdRectangles;
    }
}

// 具体工厂：圆形工厂
contract CircleFactory is ShapeFactory {
    address[] public createdCircles;
    
    function createShape(uint256[] memory dimensions) public override returns (address) {
        require(dimensions.length == 1, "Circle requires 1 dimension");
        
        Circle newCircle = new Circle(dimensions[0]);
        address circleAddress = address(newCircle);
        
        createdCircles.push(circleAddress);
        return circleAddress;
    }
    
    function getCreatedCircles() public view returns (address[] memory) {
        return createdCircles;
    }
}
