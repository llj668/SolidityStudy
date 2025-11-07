// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Super 关键字使用示例
 * @dev 演示如何使用 super 调用父合约的函数
 */

// 基础合约
contract Logger {
    event LogMessage(string message, address sender);
    
    function log(string memory message) public virtual {
        emit LogMessage(message, msg.sender);
    }
    
    function processData(uint256 data) public virtual returns (uint256) {
        log("Processing data in Logger");
        return data * 2;
    }
}

// 中间合约
contract Validator is Logger {
    function log(string memory message) public virtual override {
        // 调用父合约的 log 函数
        super.log(string(abi.encodePacked("[VALIDATOR] ", message)));
    }
    
    function processData(uint256 data) public virtual override returns (uint256) {
        require(data > 0, "Data must be positive");
        log("Validating data");
        
        // 调用父合约的 processData 函数
        uint256 result = super.processData(data);
        
        log("Data validated and processed");
        return result;
    }
    
    function validate(uint256 value) public pure returns (bool) {
        return value > 0 && value < 1000000;
    }
}

// 最终合约
contract Processor is Validator {
    uint256 public processedCount;
    
    function log(string memory message) public override {
        // 调用父合约的 log 函数（会一直向上调用到 Logger）
        super.log(string(abi.encodePacked("[PROCESSOR] ", message)));
    }
    
    function processData(uint256 data) public override returns (uint256) {
        log("Starting data processing");
        
        // 调用父合约的 processData 函数
        uint256 result = super.processData(data);
        
        processedCount++;
        log("Processing completed");
        
        return result + 10; // 额外处理
    }
    
    function getProcessedCount() public view returns (uint256) {
        return processedCount;
    }
}

// 演示多重继承中的 super 使用
contract A {
    event CallA(string message);
    
    function doSomething() public virtual {
        emit CallA("A.doSomething called");
    }
    
    function calculate(uint256 x) public virtual pure returns (uint256) {
        return x + 1;
    }
}

contract B is A {
    event CallB(string message);
    
    function doSomething() public virtual override {
        emit CallB("B.doSomething called");
        super.doSomething(); // 调用 A.doSomething
    }
    
    function calculate(uint256 x) public virtual pure override returns (uint256) {
        return super.calculate(x) * 2; // 调用 A.calculate 然后乘以2
    }
}

contract C is A {
    event CallC(string message);
    
    function doSomething() public virtual override {
        emit CallC("C.doSomething called");
        super.doSomething(); // 调用 A.doSomething
    }
    
    function calculate(uint256 x) public virtual pure override returns (uint256) {
        return super.calculate(x) + 5; // 调用 A.calculate 然后加5
    }
}

// 多重继承：B 和 C 都继承自 A
contract MultipleInheritanceSuper is B, C {
    event CallMultiple(string message);
    
    // 在多重继承中，super 按照 C3 线性化顺序调用
    // 顺序：MultipleInheritanceSuper -> C -> B -> A
    function doSomething() public override(B, C) {
        emit CallMultiple("MultipleInheritanceSuper.doSomething called");
        super.doSomething(); // 会按顺序调用 C -> B -> A
    }
    
    function calculate(uint256 x) public pure override(B, C) returns (uint256) {
        // super.calculate 会调用 C.calculate
        // C.calculate 会调用 super.calculate (即 B.calculate)
        // B.calculate 会调用 super.calculate (即 A.calculate)
        return super.calculate(x) * 3;
    }
}

// 实际应用示例：权限管理系统
contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Pausable is Ownable {
    bool public paused;
    
    event Paused(address account);
    event Unpaused(address account);
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }
    
    // 重写 onlyOwner 修饰器，添加暂停检查
    modifier onlyOwner() override {
        super.onlyOwner(); // 调用父合约的 onlyOwner 检查
        require(!paused, "Cannot perform owner actions when paused");
        _;
    }
    
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() public whenPaused {
        require(msg.sender == owner, "Only owner can unpause");
        paused = false;
        emit Unpaused(msg.sender);
    }
    
    // 重写 transferOwnership，添加额外的安全检查
    function transferOwnership(address newOwner) public override onlyOwner {
        require(!paused, "Cannot transfer ownership when paused");
        super.transferOwnership(newOwner); // 调用父合约的实现
    }
}

contract SecureContract is Pausable {
    mapping(address => uint256) public balances;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    function deposit() public payable whenNotPaused {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) public whenNotPaused {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    // 重写 transferOwnership，添加更多安全检查
    function transferOwnership(address newOwner) public override {
        require(address(this).balance == 0, "Contract must have zero balance");
        super.transferOwnership(newOwner); // 调用 Pausable.transferOwnership
    }
    
    // 紧急提取函数（仅限所有者）
    function emergencyWithdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
    }
}

// 演示构造函数中的 super 使用
contract BaseConstructor {
    string public baseName;
    uint256 public baseValue;
    
    event BaseConstructed(string name, uint256 value);
    
    constructor(string memory _name, uint256 _value) {
        baseName = _name;
        baseValue = _value;
        emit BaseConstructed(_name, _value);
    }
}

contract MiddleConstructor is BaseConstructor {
    string public middleName;
    
    event MiddleConstructed(string name);
    
    constructor(string memory _baseName, uint256 _baseValue, string memory _middleName) 
        BaseConstructor(_baseName, _baseValue) {
        middleName = _middleName;
        emit MiddleConstructed(_middleName);
    }
}

contract FinalConstructor is MiddleConstructor {
    string public finalName;
    
    event FinalConstructed(string name);
    
    constructor(
        string memory _baseName,
        uint256 _baseValue,
        string memory _middleName,
        string memory _finalName
    ) MiddleConstructor(_baseName, _baseValue, _middleName) {
        finalName = _finalName;
        emit FinalConstructed(_finalName);
    }
    
    function getAllNames() public view returns (string memory, string memory, string memory) {
        return (baseName, middleName, finalName);
    }
}
