// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * 事件和日志（Events and Logs）详解
 *
 * 1. 什么是事件？
 *    事件是 Solidity 中用于记录合约执行过程中发生的重要操作的机制
 *    事件会被记录到区块链的日志中，但不存储在合约状态中
 *
 * 2. 为什么使用事件？
 *    - 便宜：存储日志比存储状态变量便宜得多（约节省 8 倍 gas）
 *    - 可追踪：前端 DApp 可以监听事件来更新 UI
 *    - 可查询：可以通过事件查询历史操作记录
 *    - 不可篡改：事件一旦记录就无法修改
 *
 * 3. 特点：
 *    - 使用 event 关键字定义
 *    - 使用 emit 关键字触发
 *    - 最多可以有 3 个 indexed 参数（用于过滤和搜索）
 *    - 无法在合约内部读取事件数据
 *    - 事件数据存储在交易日志中
 */

// ===== 示例1：基础事件定义和使用 =====
contract EventBasic {
    // 定义事件
    event LogMessage(string message);
    event LogNumber(uint number);
    event LogAddress(address addr);

    // 触发事件
    function testEvent() public {
        emit LogMessage("Hello, Events!");
        emit LogNumber(42);
        emit LogAddress(msg.sender);
    }
}

contract EventBasic2 {
    // 定义事件
    event LogMessage(string message);

    // 触发事件
    function testEvent() public {
        emit LogMessage("You are the best man!");
    }
}

// ===== 示例2：带多个参数的事件 =====
contract EventWithMultipleParams {
    // 定义带多个参数的事件
    event Transfer(address from, address to, uint amount);
    event Deposit(address user, uint amount, uint timestamp);

    function transfer(address _to, uint _amount) public {
        // 执行转账逻辑...

        // 触发事件
        emit Transfer(msg.sender, _to, _amount);
    }

    function deposit() public payable {
        // 执行存款逻辑...

        // 触发事件，记录时间戳
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
}

// ===== 示例2：带多个参数的事件 + 完整转账功能 =====
contract EventWithMultipleParams2 {
    // ===== 状态变量 =====
    mapping(address => uint) public balanceOf; // 代币余额
    mapping(address => uint) public ethBalance; // ETH 余额（可选，用于演示）

    // ===== 事件定义 =====
    event Transfer(address indexed from, address indexed to, uint amount);
    event Deposit(address indexed user, uint amount, uint timestamp);
    event ETHTransfer(
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp
    );

    // ===== 构造函数：初始化代币余额 =====
    constructor() {
        // 给部署者 1000 个代币
        balanceOf[msg.sender] = 1000;
    }

    // ===== 方式1：ETH 转账（需要 payable）=====
    function transferETH(address payable _to) public payable {
        require(msg.value > 0, "Must send some ETH");
        require(_to != address(0), "Invalid address");
        require(_to != address(this), "Cannot send to contract");

        // 记录 ETH 余额变化（可选）
        ethBalance[msg.sender] -= msg.value;
        ethBalance[_to] += msg.value;

        // 执行 ETH 转账
        (bool success, ) = _to.call{value: msg.value}("");
        require(success, "ETH transfer failed");

        // 触发 ETH 转账事件
        emit ETHTransfer(msg.sender, _to, msg.value, block.timestamp);
    }

    // ===== 方式2：代币转账（不需要 payable）=====
    function transfer(address _to, uint _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        require(_to != address(0), "Invalid address");
        require(_to != address(this), "Cannot send to contract");

        // 执行代币转账逻辑
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        // 触发代币转账事件
        emit Transfer(msg.sender, _to, _amount);
    }

    // ===== 存款功能（接收 ETH）=====
    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");

        // 更新 ETH 余额
        ethBalance[msg.sender] += msg.value;

        // 触发存款事件，记录时间戳
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // ===== 查询功能 =====
    function getTokenBalance(address _user) public view returns (uint) {
        return balanceOf[_user];
    }

    function getETHBalance(address _user) public view returns (uint) {
        return ethBalance[_user];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

// ===== 示例3：索引参数（indexed）=====
contract EventIndexed {
    /**
     * indexed 关键字的作用：
     * 1. 使参数可以被过滤和搜索
     * 2. indexed 参数会作为日志的 topics，非 indexed 参数存储在 data 中
     * 3. 最多可以有 3 个 indexed 参数
     * 4. indexed 参数在事件中以哈希形式存储（除了 value types）
     */

    // 不使用 indexed
    event LogWithoutIndex(address user, uint amount);

    // 使用 indexed（推荐）
    event LogWithIndex(address indexed user, uint indexed amount);

    // 多个 indexed 参数
    event Transfer(
        address indexed from, // 可以按发送者过滤
        address indexed to, // 可以按接收者过滤
        uint amount // 不能过滤，但数据完整存储
    );

    // 最多 3 个 indexed
    event ComplexEvent(
        address indexed user,
        uint indexed tokenId,
        string indexed category, // 注意：string 会被哈希，前端无法直接读取原始值
        uint amount,
        string description
    );

    function testIndexed() public {
        emit LogWithoutIndex(msg.sender, 100);
        emit LogWithIndex(msg.sender, 100);
        emit Transfer(msg.sender, address(this), 100);
    }
}

// ===== 示例4：事件的 Gas 成本 =====
contract EventGasCost {
    uint public storedValue;

    // 定义事件
    event ValueChanged(uint oldValue, uint newValue);

    // 方法1：只使用状态变量存储（昂贵）
    function setValueWithStorage(uint _value) public {
        storedValue = _value;
        // 修改状态变量的 gas 成本：约 5000-20000 gas（首次）
    }

    // 方法2：使用事件记录（便宜）
    function setValueWithEvent(uint _value) public {
        uint oldValue = storedValue;
        storedValue = _value;
        emit ValueChanged(oldValue, _value);
        // 触发事件的额外 gas 成本：约 375-1500 gas
    }

    /**
     * Gas 成本对比：
     * - 存储状态变量：20000 gas（SSTORE 操作）
     * - 触发事件：375 gas（基础）+ 375 gas（每个 topic）+ 8 gas（每字节数据）
     * - 事件成本约为存储成本的 1/8
     */
}

// ===== 示例5：ERC20 代币中的标准事件 =====
contract ERC20Events {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    // ERC20 标准事件
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(uint _totalSupply) {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;

        // 铸造事件：从零地址转账
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid address");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        // 触发转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;

        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(
            allowance[_from][msg.sender] >= _value,
            "Insufficient allowance"
        );
        require(_to != address(0), "Invalid address");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        // 触发转账事件
        emit Transfer(_from, _to, _value);
        return true;
    }

    // 销毁代币
    function burn(uint _value) public {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        // 销毁事件：转账到零地址
        emit Transfer(msg.sender, address(0), _value);
    }
}

// ===== 示例6：事件的实际应用场景 =====
contract EventUseCases {
    address public owner;

    // 1. 权限变更事件
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner,
        uint timestamp
    );

    // 2. 状态变更事件
    event StatusChanged(
        string indexed status,
        address indexed changedBy,
        string reason
    );

    // 3. 操作记录事件
    event ActionPerformed(
        address indexed user,
        string indexed action,
        bytes data,
        bool success
    );

    // 4. 错误/异常事件
    event ErrorOccurred(
        address indexed user,
        string errorMessage,
        uint errorCode
    );

    // 5. 数据更新事件
    event DataUpdated(
        uint indexed id,
        string fieldName,
        string oldValue,
        string newValue
    );

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender, block.timestamp);
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner, "Not owner");
        require(_newOwner != address(0), "Invalid address");

        address oldOwner = owner;
        owner = _newOwner;

        emit OwnershipTransferred(oldOwner, _newOwner, block.timestamp);
    }
}

// ===== 示例7：复杂的事件系统 - 订单管理 =====
contract OrderManagement {
    enum OrderStatus {
        Created,
        Paid,
        Shipped,
        Delivered,
        Cancelled
    }

    struct Order {
        uint id;
        address buyer;
        address seller;
        uint amount;
        OrderStatus status;
        uint createdAt;
    }

    mapping(uint => Order) public orders;
    uint public orderCount;

    // 事件：订单创建
    event OrderCreated(
        uint indexed orderId,
        address indexed buyer,
        address indexed seller,
        uint amount,
        uint timestamp
    );

    // 事件：订单状态变更
    event OrderStatusChanged(
        uint indexed orderId,
        OrderStatus indexed oldStatus,
        OrderStatus indexed newStatus,
        address changedBy,
        uint timestamp
    );

    // 事件：订单取消
    event OrderCancelled(
        uint indexed orderId,
        address indexed cancelledBy,
        string reason,
        uint timestamp
    );

    // 事件：退款
    event RefundIssued(
        uint indexed orderId,
        address indexed buyer,
        uint amount,
        uint timestamp
    );

    // 创建订单
    function createOrder(address _seller, uint _amount) public returns (uint) {
        orderCount++;

        orders[orderCount] = Order({
            id: orderCount,
            buyer: msg.sender,
            seller: _seller,
            amount: _amount,
            status: OrderStatus.Created,
            createdAt: block.timestamp
        });

        emit OrderCreated(
            orderCount,
            msg.sender,
            _seller,
            _amount,
            block.timestamp
        );

        return orderCount;
    }

    // 更新订单状态
    function updateOrderStatus(uint _orderId, OrderStatus _newStatus) public {
        Order storage order = orders[_orderId];
        require(order.id != 0, "Order not found");

        OrderStatus oldStatus = order.status;
        order.status = _newStatus;

        emit OrderStatusChanged(
            _orderId,
            oldStatus,
            _newStatus,
            msg.sender,
            block.timestamp
        );
    }

    // 取消订单
    function cancelOrder(uint _orderId, string memory _reason) public {
        Order storage order = orders[_orderId];
        require(order.id != 0, "Order not found");
        require(
            msg.sender == order.buyer || msg.sender == order.seller,
            "Not authorized"
        );

        OrderStatus oldStatus = order.status;
        order.status = OrderStatus.Cancelled;

        emit OrderStatusChanged(
            _orderId,
            oldStatus,
            OrderStatus.Cancelled,
            msg.sender,
            block.timestamp
        );

        emit OrderCancelled(_orderId, msg.sender, _reason, block.timestamp);

        // 如果已支付，触发退款事件
        if (oldStatus == OrderStatus.Paid) {
            emit RefundIssued(
                _orderId,
                order.buyer,
                order.amount,
                block.timestamp
            );
        }
    }
}

// ===== 示例8：匿名事件 =====
contract AnonymousEvents {
    /**
     * 匿名事件（anonymous）：
     * 1. 使用 anonymous 关键字
     * 2. 不包含事件签名作为 topic
     * 3. 可以有 4 个 indexed 参数（而不是 3 个）
     * 4. 节省 gas，但更难过滤
     * 5. 较少使用
     */

    // 普通事件（有事件签名）
    event NormalEvent(address indexed user, uint amount);

    // 匿名事件（无事件签名）
    event AnonymousEvent(address indexed user, uint indexed amount) anonymous;

    function triggerEvents() public {
        emit NormalEvent(msg.sender, 100);
        emit AnonymousEvent(msg.sender, 100);
    }
}

// ===== 示例9：事件继承 =====
contract BaseContract {
    // 父合约定义的事件
    event BaseEvent(string message);

    function triggerBaseEvent() public {
        emit BaseEvent("From base contract");
    }
}

contract DerivedContract is BaseContract {
    // 子合约定义的事件
    event DerivedEvent(string message);

    function triggerDerivedEvent() public {
        emit DerivedEvent("From derived contract");
    }

    function triggerBothEvents() public {
        // 子合约可以触发父合约的事件
        emit BaseEvent("Base event from derived");
        emit DerivedEvent("Derived event");
    }
}

// ===== 示例10：使用事件进行调试和审计 =====
contract AuditTrail {
    struct Transaction {
        address from;
        address to;
        uint amount;
        uint timestamp;
    }

    Transaction[] public transactions;

    // 详细的审计事件
    event TransactionExecuted(
        uint indexed transactionId,
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp,
        uint gasUsed,
        bytes32 transactionHash
    );

    // 调试事件
    event Debug(string message, uint value, address addr);

    function executeTransaction(address _to, uint _amount) public {
        uint gasBefore = gasleft();

        // 执行交易逻辑
        transactions.push(
            Transaction({
                from: msg.sender,
                to: _to,
                amount: _amount,
                timestamp: block.timestamp
            })
        );

        uint gasUsed = gasBefore - gasleft();

        // 记录完整的审计信息
        emit TransactionExecuted(
            transactions.length - 1,
            msg.sender,
            _to,
            _amount,
            block.timestamp,
            gasUsed,
            blockhash(block.number - 1)
        );

        // 调试信息
        emit Debug("Transaction completed", _amount, _to);
    }
}

// ===== 最佳实践总结 =====
/**
 * 1. 命名规范：
 *    - 事件名使用 PascalCase（首字母大写）
 *    - 事件名应该是动词的过去式，如 Transfer, Approval, Created
 *
 * 2. indexed 参数使用：
 *    - 需要过滤的参数使用 indexed
 *    - 地址类型通常使用 indexed
 *    - ID 类型通常使用 indexed
 *    - 大型数据（string, bytes, array）使用 indexed 会被哈希
 *    - 最多 3 个 indexed 参数
 *
 * 3. 何时使用事件：
 *    - 状态变更（转账、授权、所有权变更等）
 *    - 重要操作记录（创建、更新、删除）
 *    - 错误和异常追踪
 *    - 前端需要实时更新的数据
 *
 * 4. Gas 优化：
 *    - 对于只需要记录不需要查询的数据，使用事件而非状态变量
 *    - 合理使用 indexed，过多会增加 gas 成本
 *    - 考虑数据的重要性和访问频率
 *
 * 5. 安全考虑：
 *    - 事件不能用于合约逻辑判断
 *    - 事件数据是公开的，不要记录敏感信息
 *    - 事件可以被伪造（在测试环境），不要作为唯一的数据来源
 *
 * 6. 前端监听事件（Web3.js 示例）：
 *    ```javascript
 *    // 监听特定事件
 *    contract.events.Transfer({
 *        filter: {from: userAddress},  // 过滤 indexed 参数
 *        fromBlock: 0
 *    })
 *    .on('data', event => {
 *        console.log(event.returnValues);
 *    })
 *    .on('error', console.error);
 *
 *    // 查询历史事件
 *    const events = await contract.getPastEvents('Transfer', {
 *        filter: {from: userAddress},
 *        fromBlock: 0,
 *        toBlock: 'latest'
 *    });
 *    ```
 */
