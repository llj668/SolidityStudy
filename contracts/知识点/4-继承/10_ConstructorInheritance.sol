// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 构造函数继承示例
 * @dev 演示构造函数在继承中的各种用法
 */

// 基础合约：简单构造函数
contract SimpleBase {
    string public name;
    uint256 public value;
    
    event BaseConstructed(string name, uint256 value);
    
    constructor(string memory _name, uint256 _value) {
        name = _name;
        value = _value;
        emit BaseConstructed(_name, _value);
    }
    
    function getInfo() public view returns (string memory, uint256) {
        return (name, value);
    }
}

// 方式1：在继承声明中直接传递参数
contract DirectInheritance is SimpleBase("DirectChild", 100) {
    string public childName;
    
    event ChildConstructed(string childName);
    
    constructor(string memory _childName) {
        childName = _childName;
        emit ChildConstructed(_childName);
    }
    
    function getFullInfo() public view returns (string memory, uint256, string memory) {
        return (name, value, childName);
    }
}

// 方式2：在构造函数中动态传递参数
contract DynamicInheritance is SimpleBase {
    string public childName;
    uint256 public childValue;
    
    event ChildConstructed(string childName, uint256 childValue);
    
    constructor(
        string memory _name,
        uint256 _value,
        string memory _childName,
        uint256 _childValue
    ) SimpleBase(_name, _value) {
        childName = _childName;
        childValue = _childValue;
        emit ChildConstructed(_childName, _childValue);
    }
    
    function getFullInfo() public view returns (
        string memory,
        uint256,
        string memory,
        uint256
    ) {
        return (name, value, childName, childValue);
    }
}

// 多层继承的构造函数
contract MiddleLayer is SimpleBase {
    string public middleName;
    
    event MiddleConstructed(string middleName);
    
    constructor(
        string memory _name,
        uint256 _value,
        string memory _middleName
    ) SimpleBase(_name, _value) {
        middleName = _middleName;
        emit MiddleConstructed(_middleName);
    }
}

contract DeepInheritance is MiddleLayer {
    string public deepName;
    
    event DeepConstructed(string deepName);
    
    constructor(
        string memory _name,
        uint256 _value,
        string memory _middleName,
        string memory _deepName
    ) MiddleLayer(_name, _value, _middleName) {
        deepName = _deepName;
        emit DeepConstructed(_deepName);
    }
    
    function getAllInfo() public view returns (
        string memory,
        uint256,
        string memory,
        string memory
    ) {
        return (name, value, middleName, deepName);
    }
}

// 多重继承的构造函数
contract BaseA {
    string public nameA;
    
    event BaseAConstructed(string nameA);
    
    constructor(string memory _nameA) {
        nameA = _nameA;
        emit BaseAConstructed(_nameA);
    }
}

contract BaseB {
    string public nameB;
    
    event BaseBConstructed(string nameB);
    
    constructor(string memory _nameB) {
        nameB = _nameB;
        emit BaseBConstructed(_nameB);
    }
}

// 多重继承：需要调用所有父合约的构造函数
contract MultipleInheritanceConstructor is BaseA, BaseB {
    string public ownName;
    
    event OwnConstructed(string ownName);
    
    constructor(
        string memory _nameA,
        string memory _nameB,
        string memory _ownName
    ) BaseA(_nameA) BaseB(_nameB) {
        ownName = _ownName;
        emit OwnConstructed(_ownName);
    }
    
    function getAllNames() public view returns (
        string memory,
        string memory,
        string memory
    ) {
        return (nameA, nameB, ownName);
    }
}

// 复杂的多重继承构造函数
contract ComplexBase {
    uint256 public baseId;
    string public baseDescription;
    
    event ComplexBaseConstructed(uint256 id, string description);
    
    constructor(uint256 _id, string memory _description) {
        baseId = _id;
        baseDescription = _description;
        emit ComplexBaseConstructed(_id, _description);
    }
}

contract FeatureA is ComplexBase {
    bool public featureAEnabled;
    
    event FeatureAConstructed(bool enabled);
    
    constructor(
        uint256 _id,
        string memory _description,
        bool _enabled
    ) ComplexBase(_id, _description) {
        featureAEnabled = _enabled;
        emit FeatureAConstructed(_enabled);
    }
}

contract FeatureB is ComplexBase {
    uint256 public featureBValue;
    
    event FeatureBConstructed(uint256 value);
    
    constructor(
        uint256 _id,
        string memory _description,
        uint256 _value
    ) ComplexBase(_id, _description) {
        featureBValue = _value;
        emit FeatureBConstructed(_value);
    }
}

// 菱形继承的构造函数处理
contract DiamondInheritanceConstructor is FeatureA, FeatureB {
    string public finalName;
    
    event FinalConstructed(string finalName);
    
    // 注意：只需要调用直接父合约的构造函数
    // ComplexBase 的构造函数会被自动调用一次
    constructor(
        uint256 _id,
        string memory _description,
        bool _enabledA,
        uint256 _valueB,
        string memory _finalName
    ) 
        FeatureA(_id, _description, _enabledA)
        FeatureB(_id, _description, _valueB)
    {
        finalName = _finalName;
        emit FinalConstructed(_finalName);
    }
    
    function getCompleteInfo() public view returns (
        uint256,
        string memory,
        bool,
        uint256,
        string memory
    ) {
        return (baseId, baseDescription, featureAEnabled, featureBValue, finalName);
    }
}

// 带有默认参数的构造函数模拟
contract DefaultParametersBase {
    string public name;
    uint256 public value;
    bool public flag;
    
    event DefaultBaseConstructed(string name, uint256 value, bool flag);
    
    constructor(string memory _name, uint256 _value, bool _flag) {
        name = _name;
        value = _value;
        flag = _flag;
        emit DefaultBaseConstructed(_name, _value, _flag);
    }
}

// 提供多个构造函数选项的子合约
contract FlexibleConstructor is DefaultParametersBase {
    string public extra;
    
    event FlexibleConstructed(string extra);
    
    // 构造函数1：提供所有参数
    constructor(
        string memory _name,
        uint256 _value,
        bool _flag,
        string memory _extra
    ) DefaultParametersBase(_name, _value, _flag) {
        extra = _extra;
        emit FlexibleConstructed(_extra);
    }
}

// 另一个构造函数选项
contract SimpleFlexibleConstructor is DefaultParametersBase {
    // 构造函数2：使用默认值
    constructor(string memory _name) 
        DefaultParametersBase(_name, 0, false) 
    {
        // 使用默认值初始化父合约
    }
}

// 构造函数中的复杂逻辑
contract ComplexConstructorLogic {
    address public owner;
    uint256 public creationTime;
    string public contractType;
    mapping(address => bool) public authorizedUsers;
    
    event ContractInitialized(
        address owner,
        uint256 creationTime,
        string contractType,
        address[] authorizedUsers
    );
    
    constructor(
        string memory _contractType,
        address[] memory _authorizedUsers
    ) {
        owner = msg.sender;
        creationTime = block.timestamp;
        contractType = _contractType;
        
        // 初始化授权用户
        for (uint256 i = 0; i < _authorizedUsers.length; i++) {
            require(_authorizedUsers[i] != address(0), "Invalid authorized user");
            authorizedUsers[_authorizedUsers[i]] = true;
        }
        
        // 确保部署者也是授权用户
        authorizedUsers[msg.sender] = true;
        
        emit ContractInitialized(owner, creationTime, contractType, _authorizedUsers);
    }
    
    modifier onlyAuthorized() {
        require(authorizedUsers[msg.sender], "Not authorized");
        _;
    }
    
    function isAuthorized(address user) public view returns (bool) {
        return authorizedUsers[user];
    }
}

// 继承复杂构造函数逻辑
contract ExtendedComplexContract is ComplexConstructorLogic {
    uint256 public maxUsers;
    string public version;
    
    event ExtendedInitialized(uint256 maxUsers, string version);
    
    constructor(
        string memory _contractType,
        address[] memory _authorizedUsers,
        uint256 _maxUsers,
        string memory _version
    ) ComplexConstructorLogic(_contractType, _authorizedUsers) {
        require(_maxUsers > 0, "Max users must be positive");
        require(_authorizedUsers.length <= _maxUsers, "Too many initial users");
        
        maxUsers = _maxUsers;
        version = _version;
        
        emit ExtendedInitialized(_maxUsers, _version);
    }
    
    function getExtendedInfo() public view returns (
        address,
        uint256,
        string memory,
        uint256,
        string memory
    ) {
        return (owner, creationTime, contractType, maxUsers, version);
    }
}

// 抽象合约的构造函数
abstract contract AbstractWithConstructor {
    string public abstractName;
    uint256 public abstractValue;
    
    event AbstractConstructed(string name, uint256 value);
    
    constructor(string memory _name, uint256 _value) {
        abstractName = _name;
        abstractValue = _value;
        emit AbstractConstructed(_name, _value);
    }
    
    // 抽象函数
    function abstractFunction() public virtual pure returns (string memory);
}

// 实现抽象合约
contract ConcreteFromAbstract is AbstractWithConstructor {
    string public concreteName;
    
    event ConcreteConstructed(string concreteName);
    
    constructor(
        string memory _abstractName,
        uint256 _abstractValue,
        string memory _concreteName
    ) AbstractWithConstructor(_abstractName, _abstractValue) {
        concreteName = _concreteName;
        emit ConcreteConstructed(_concreteName);
    }
    
    // 实现抽象函数
    function abstractFunction() public pure override returns (string memory) {
        return "Concrete implementation of abstract function";
    }
    
    function getConcreteInfo() public view returns (
        string memory,
        uint256,
        string memory,
        string memory
    ) {
        return (abstractName, abstractValue, concreteName, abstractFunction());
    }
}

// 构造函数执行顺序演示
contract OrderDemo1 {
    string public order;
    
    constructor() {
        order = "1";
    }
}

contract OrderDemo2 is OrderDemo1 {
    constructor() {
        order = string(abi.encodePacked(order, "->2"));
    }
}

contract OrderDemo3 is OrderDemo2 {
    constructor() {
        order = string(abi.encodePacked(order, "->3"));
    }
}

// 多重继承的构造函数执行顺序
contract OrderA {
    string public orderA;
    
    constructor() {
        orderA = "A";
    }
}

contract OrderB {
    string public orderB;
    
    constructor() {
        orderB = "B";
    }
}

contract OrderC is OrderA, OrderB {
    string public orderC;
    string public finalOrder;
    
    constructor() {
        orderC = "C";
        // 构造函数执行顺序：OrderA -> OrderB -> OrderC
        finalOrder = string(abi.encodePacked(orderA, "->", orderB, "->", orderC));
    }
    
    function getExecutionOrder() public view returns (string memory) {
        return finalOrder;
    }
}

// 构造函数中的错误处理
contract ConstructorErrorHandling {
    address public validatedAddress;
    uint256 public validatedValue;
    string public validatedString;
    
    event ConstructorValidationPassed(address addr, uint256 value, string str);
    
    constructor(
        address _address,
        uint256 _value,
        string memory _string
    ) {
        // 地址验证
        require(_address != address(0), "Address cannot be zero");
        
        // 数值验证
        require(_value > 0 && _value <= 1000000, "Value must be between 1 and 1000000");
        
        // 字符串验证
        require(bytes(_string).length > 0, "String cannot be empty");
        require(bytes(_string).length <= 100, "String too long");
        
        validatedAddress = _address;
        validatedValue = _value;
        validatedString = _string;
        
        emit ConstructorValidationPassed(_address, _value, _string);
    }
    
    function getValidatedData() public view returns (
        address,
        uint256,
        string memory
    ) {
        return (validatedAddress, validatedValue, validatedString);
    }
}
