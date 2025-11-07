// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 修饰器继承示例
 * @dev 演示修饰器的继承、重写和组合使用
 */

// 基础权限控制合约
contract AccessControl {
    address public admin;
    mapping(address => bool) public operators;
    
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    
    constructor() {
        admin = msg.sender;
        emit AdminChanged(address(0), msg.sender);
    }
    
    // 基础修饰器：仅管理员
    modifier onlyAdmin() virtual {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    // 基础修饰器：仅操作员
    modifier onlyOperator() virtual {
        require(operators[msg.sender], "Only operator can call this function");
        _;
    }
    
    // 基础修饰器：管理员或操作员
    modifier onlyAuthorized() virtual {
        require(msg.sender == admin || operators[msg.sender], "Not authorized");
        _;
    }
    
    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
    
    function addOperator(address operator) public onlyAdmin {
        require(!operators[operator], "Already an operator");
        operators[operator] = true;
        emit OperatorAdded(operator);
    }
    
    function removeOperator(address operator) public onlyAdmin {
        require(operators[operator], "Not an operator");
        operators[operator] = false;
        emit OperatorRemoved(operator);
    }
}

// 时间锁合约：继承并扩展修饰器
contract TimeLocked is AccessControl {
    uint256 public lockDuration = 1 days;
    mapping(bytes32 => uint256) public timelocks;
    
    event ActionScheduled(bytes32 indexed actionId, uint256 executeTime);
    event ActionExecuted(bytes32 indexed actionId);
    
    // 重写管理员修饰器，添加时间锁检查
    modifier onlyAdmin() override {
        super.onlyAdmin(); // 调用父合约的检查
        _;
    }
    
    // 新修饰器：需要时间锁
    modifier withTimelock(bytes32 actionId) {
        require(timelocks[actionId] != 0, "Action not scheduled");
        require(block.timestamp >= timelocks[actionId], "Action still locked");
        _;
        delete timelocks[actionId]; // 执行后删除时间锁
        emit ActionExecuted(actionId);
    }
    
    // 组合修饰器：管理员 + 时间锁
    modifier onlyAdminWithTimelock(bytes32 actionId) {
        onlyAdmin();
        withTimelock(actionId);
        _;
    }
    
    function scheduleAction(bytes32 actionId) public onlyAdmin {
        require(timelocks[actionId] == 0, "Action already scheduled");
        uint256 executeTime = block.timestamp + lockDuration;
        timelocks[actionId] = executeTime;
        emit ActionScheduled(actionId, executeTime);
    }
    
    function setLockDuration(uint256 newDuration) public onlyAdmin {
        require(newDuration >= 1 hours, "Lock duration too short");
        lockDuration = newDuration;
    }
}

// 暂停功能合约：进一步扩展修饰器
contract PausableTimeLocked is TimeLocked {
    bool public paused;
    
    event Paused(address account);
    event Unpaused(address account);
    
    // 重写所有权限修饰器，添加暂停检查
    modifier onlyAdmin() override {
        require(!paused, "Contract is paused");
        super.onlyAdmin();
        _;
    }
    
    modifier onlyOperator() override {
        require(!paused, "Contract is paused");
        super.onlyOperator();
        _;
    }
    
    modifier onlyAuthorized() override {
        require(!paused, "Contract is paused");
        super.onlyAuthorized();
        _;
    }
    
    // 新修饰器：仅在未暂停时
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    // 新修饰器：仅在暂停时
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }
    
    function pause() public onlyAdmin {
        require(!paused, "Already paused");
        paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() public onlyAdmin whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
    
    // 紧急暂停：操作员也可以调用
    function emergencyPause() public onlyAuthorized whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }
}

// 实际应用：代币合约
contract Token is PausableTimeLocked {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => bool) public blacklisted;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
    
    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply * 10**decimals;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    // 修饰器：检查是否被拉黑
    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Account is blacklisted");
        _;
    }
    
    // 组合修饰器：未暂停 + 未拉黑
    modifier validTransfer(address from, address to) {
        whenNotPaused();
        notBlacklisted(from);
        notBlacklisted(to);
        _;
    }
    
    function transfer(address to, uint256 amount) public validTransfer(msg.sender, to) returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) 
        public 
        validTransfer(from, to) 
        returns (bool) 
    {
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");
        require(balances[from] >= amount, "Insufficient balance");
        
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public whenNotPaused returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    // 管理员功能：拉黑账户
    function blacklist(address account) public onlyAdmin {
        require(!blacklisted[account], "Already blacklisted");
        blacklisted[account] = true;
        emit Blacklisted(account);
    }
    
    // 管理员功能：解除拉黑
    function unblacklist(address account) public onlyAdmin {
        require(blacklisted[account], "Not blacklisted");
        blacklisted[account] = false;
        emit Unblacklisted(account);
    }
    
    // 铸币功能：需要时间锁
    function mint(address to, uint256 amount, bytes32 actionId) 
        public 
        onlyAdminWithTimelock(actionId) 
    {
        totalSupply += amount;
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    // 销毁功能：需要时间锁
    function burn(uint256 amount, bytes32 actionId) 
        public 
        onlyAdminWithTimelock(actionId) 
    {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}

// 演示修饰器的多重继承
contract ModifierA {
    modifier modA() virtual {
        require(msg.sender != address(0), "ModA: Invalid sender");
        _;
    }
}

contract ModifierB {
    modifier modB() virtual {
        require(msg.value == 0, "ModB: No ETH allowed");
        _;
    }
}

contract ModifierC is ModifierA, ModifierB {
    uint256 public value;
    
    // 重写修饰器A
    modifier modA() override {
        super.modA(); // 调用父合约的修饰器
        require(msg.sender == tx.origin, "ModC: Only EOA allowed");
        _;
    }
    
    // 重写修饰器B
    modifier modB() override {
        super.modB(); // 调用父合约的修饰器
        require(gasleft() > 10000, "ModC: Insufficient gas");
        _;
    }
    
    // 组合使用多个修饰器
    function setValue(uint256 _value) public modA modB {
        value = _value;
    }
}

// 演示修饰器参数的继承
contract ParameterizedModifiers {
    mapping(address => uint256) public lastAccess;
    
    // 带参数的修饰器
    modifier rateLimited(uint256 interval) virtual {
        require(
            block.timestamp >= lastAccess[msg.sender] + interval,
            "Rate limit exceeded"
        );
        lastAccess[msg.sender] = block.timestamp;
        _;
    }
    
    // 带多个参数的修饰器
    modifier valueRange(uint256 min, uint256 max) virtual {
        require(msg.value >= min && msg.value <= max, "Value out of range");
        _;
    }
}

contract ExtendedParameterizedModifiers is ParameterizedModifiers {
    mapping(address => uint256) public accessCount;
    
    // 重写带参数的修饰器
    modifier rateLimited(uint256 interval) override {
        super.rateLimited(interval);
        accessCount[msg.sender]++;
        _;
    }
    
    // 重写带参数的修饰器，添加额外检查
    modifier valueRange(uint256 min, uint256 max) override {
        super.valueRange(min, max);
        require(accessCount[msg.sender] < 100, "Access limit exceeded");
        _;
    }
    
    function restrictedFunction() 
        public 
        payable 
        rateLimited(60) // 1分钟间隔
        valueRange(0.1 ether, 1 ether) // 值范围限制
    {
        // 函数逻辑
    }
}
