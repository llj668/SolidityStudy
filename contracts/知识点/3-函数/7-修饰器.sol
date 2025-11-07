// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * 修饰器（Modifier）详解
 *
 * 1. 什么是修饰器？
 *    修饰器是一种可复用的代码片段，用于在函数执行前后添加额外的逻辑
 *    主要用于权限控制、输入验证、防止重入攻击等
 *
 * 2. 特点：
 *    - 使用 modifier 关键字定义
 *    - 使用 _; 符号表示被修饰函数的执行位置
 *    - 可以接收参数
 *    - 可以链式使用多个修饰器
 *    - 减少代码重复，提高可读性
 */

// ===== 示例1：基础修饰器 - 权限控制 =====
contract ModifierBasic {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 定义修饰器：检查调用者是否是合约所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _; // 下划线表示被修饰函数的代码会在这里执行
    }

    // 使用修饰器
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    // 任何人都可以调用
    function publicFunction() public pure returns (string memory) {
        return "Anyone can call this";
    }
}

// ===== 示例2：带参数的修饰器 =====
contract ModifierWithParams {
    mapping(address => uint) public balances;

    constructor() {
        balances[msg.sender] = 1000;
    }

    // 带参数的修饰器：检查余额是否足够
    modifier hasEnoughBalance(uint _amount) {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        _;
    }

    // 使用带参数的修饰器
    function withdraw(uint _amount) public hasEnoughBalance(_amount) {
        balances[msg.sender] -= _amount;
        // 实际转账逻辑...
    }
}

// ===== 示例3：修饰器中 _ 的位置 =====
contract ModifierUnderscorePosition {
    uint public counter;

    // _; 在前面：函数代码先执行，修饰器逻辑后执行
    modifier incrementAfter() {
        _; // 函数代码在这里执行
        counter++; // 函数执行后 counter 增加
    }

    // _; 在后面：修饰器逻辑先执行，函数代码后执行
    modifier incrementBefore() {
        counter++; // 函数执行前 counter 增加
        _; // 函数代码在这里执行
    }

    // _; 在中间：可以在函数执行前后都添加逻辑
    modifier logExecution() {
        // 前置逻辑
        counter++;
        _; // 函数代码在这里执行
        // 后置逻辑
        counter++;
    }

    function testAfter() public incrementAfter {
        // counter 在函数执行后增加
    }

    function testBefore() public incrementBefore {
        // counter 在函数执行前增加
    }

    function testMiddle() public logExecution {
        // counter 在函数执行前后各增加一次
    }
}

// ===== 示例4：多个修饰器链式使用 =====
contract MultipleModifiers {
    address public owner;
    bool public paused;

    constructor() {
        owner = msg.sender;
        paused = false;
    }

    // 修饰器1：只有所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // 修饰器2：合约未暂停时才能调用
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    // 修饰器3：检查地址有效性
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    // 使用多个修饰器（执行顺序：从左到右）
    function transferOwnership(
        address _newOwner
    )
        public
        onlyOwner // 先检查是否是所有者
        whenNotPaused // 再检查合约是否暂停
        validAddress(_newOwner) // 最后检查地址有效性
    {
        owner = _newOwner;
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }
}

// ===== 示例5：防重入攻击修饰器 =====
contract ReentrancyGuard {
    bool private locked;

    // 防重入修饰器
    modifier noReentrancy() {
        require(!locked, "Reentrancy detected");
        locked = true; // 设置锁
        _; // 执行函数
        locked = false; // 释放锁
    }

    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // 使用防重入修饰器保护提款函数
    function withdraw(uint _amount) public noReentrancy {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;

        // 外部调用（可能触发重入攻击）
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }
}

// ===== 示例6：修饰器的高级应用 - 角色权限管理 =====
contract AccessControl {
    // 定义角色
    mapping(address => bool) public admins;
    mapping(address => bool) public moderators;
    mapping(address => bool) public users;

    address public owner;

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    // 只有所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // 只有管理员
    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admin");
        _;
    }

    // 只有版主
    modifier onlyModerator() {
        require(moderators[msg.sender], "Only moderator");
        _;
    }

    // 管理员或版主
    modifier onlyAdminOrModerator() {
        require(
            admins[msg.sender] || moderators[msg.sender],
            "Only admin or moderator"
        );
        _;
    }

    // 已注册用户
    modifier onlyRegisteredUser() {
        require(users[msg.sender], "Not registered");
        _;
    }

    // 权限管理函数
    function addAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
    }

    function addModerator(address _moderator) public onlyAdmin {
        moderators[_moderator] = true;
    }

    function registerUser(address _user) public onlyAdminOrModerator {
        users[_user] = true;
    }

    function deleteContent(uint _contentId) public onlyAdminOrModerator {
        // 删除内容的逻辑
    }
}

// ===== 示例7：修饰器与继承 =====
contract BaseContract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // 基础修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

// 子合约可以继承和使用父合约的修饰器
contract ChildContract is BaseContract {
    uint public value;

    // 使用继承的修饰器
    function setValue(uint _value) public onlyOwner {
        value = _value;
    }

    // 可以重写修饰器
    modifier onlyOwner() override {
        require(msg.sender == owner, "Not owner in child");
        _;
    }
}

// ===== 示例8：修饰器的实际应用 - ERC20 代币 =====
contract SimpleToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    address public owner;
    bool public paused;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        totalSupply = _totalSupply;
        owner = msg.sender;
        balanceOf[msg.sender] = _totalSupply;
    }

    // 修饰器：只有所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // 修饰器：未暂停
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }

    // 修饰器：验证地址
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        require(_addr != address(this), "Cannot send to contract");
        _;
    }

    // 修饰器：检查余额
    modifier hasBalance(address _from, uint _value) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        _;
    }

    // 使用多个修饰器的转账函数
    function transfer(
        address _to,
        uint _value
    )
        public
        whenNotPaused
        validAddress(_to)
        hasBalance(msg.sender, _value)
        returns (bool)
    {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 暂停/恢复合约
    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }
}

// ===== 注意事项和最佳实践 =====
/**
 * 1. 修饰器中的 _ 符号非常重要，它代表被修饰函数的执行位置
 * 2. 修饰器可以有多个 _ 符号，但要谨慎使用，可能导致函数执行多次
 * 3. 多个修饰器的执行顺序是从左到右、由外到内
 * 4. 修饰器中的 return 不会影响被修饰函数的执行
 * 5. 修饰器中使用 require/revert 可以阻止函数执行
 * 6. 过度使用修饰器可能增加 gas 成本
 * 7. 修饰器主要用于：权限控制、输入验证、状态检查、防重入等
 * 8. 修饰器可以继承和重写
 */
