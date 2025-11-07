// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * 事件的高级应用和技巧
 *
 * 本文件涵盖：
 * 1. 事件的 Gas 优化技巧
 * 2. 事件与数据存储的权衡
 * 3. 事件的链下数据聚合
 * 4. 事件的安全考虑
 * 5. 事件的测试和调试
 */

// ===== 1. Gas 优化技巧 =====
contract EventGasOptimization {
    /**
     * 技巧1：使用 indexed 参数进行过滤，但要适度
     * 每个 indexed 参数会增加约 375 gas
     */

    // 不好：所有参数都 indexed（浪费 gas）
    event TransferBad(
        address indexed from,
        address indexed to,
        uint indexed amount, // amount 通常不需要过滤
        uint indexed timestamp // timestamp 通常不需要过滤
    );

    // 好：只有需要过滤的参数 indexed
    event TransferGood(
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp
    );

    /**
     * 技巧2：使用较小的数据类型
     */

    // 不好：使用 uint256（8 字节数据）
    event SmallNumberBad(uint256 value);

    // 好：如果值不大，使用 uint8（1 字节数据）
    event SmallNumberGood(uint8 value);

    /**
     * 技巧3：批量操作时，使用单个事件而不是多个事件
     */

    // 不好：每次操作都触发事件
    function batchTransferBad(
        address[] memory _recipients,
        uint[] memory _amounts
    ) public {
        for (uint i = 0; i < _recipients.length; i++) {
            // 每次循环都触发事件，浪费 gas
            emit TransferGood(
                msg.sender,
                _recipients[i],
                _amounts[i],
                block.timestamp
            );
        }
    }

    // 好：使用批量事件
    event BatchTransfer(
        address indexed from,
        address[] recipients,
        uint[] amounts,
        uint timestamp
    );

    function batchTransferGood(
        address[] memory _recipients,
        uint[] memory _amounts
    ) public {
        // 只触发一次事件
        emit BatchTransfer(msg.sender, _recipients, _amounts, block.timestamp);
    }

    /**
     * 技巧4：避免在事件中存储冗余数据
     */

    // 不好：存储可以从其他地方获取的数据
    event UserActionBad(
        address indexed user,
        string username, // 可以从用户信息中获取
        uint balance, // 可以从状态变量中获取
        uint action,
        uint timestamp
    );

    // 好：只存储必要的数据
    event UserActionGood(address indexed user, uint action, uint timestamp);
}

// ===== 2. 事件 vs 状态变量：何时使用何者 =====
contract EventVsStorage {
    // 场景：记录交易历史

    // 方法1：使用数组存储（昂贵）
    struct Transaction {
        address from;
        address to;
        uint amount;
        uint timestamp;
    }
    Transaction[] public transactions; // 存储成本高

    // 方法2：只使用事件（便宜）
    event TransactionExecuted(
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp
    );

    /**
     * 决策指南：
     *
     * 使用状态变量（Storage）当：
     * - 需要在合约内部读取数据
     * - 需要修改历史数据
     * - 数据对合约逻辑至关重要
     * - 数据量较小
     *
     * 使用事件（Events）当：
     * - 只需要记录历史（不需要在合约中读取）
     * - 数据主要供前端使用
     * - 数据量很大
     * - 需要节省 gas
     */

    // 混合方案：关键数据存储，详细数据使用事件
    uint public transactionCount;
    mapping(address => uint) public totalSent;

    function sendMixed(address _to, uint _amount) public {
        // 更新关键状态
        transactionCount++;
        totalSent[msg.sender] += _amount;

        // 详细信息使用事件
        emit TransactionExecuted(msg.sender, _to, _amount, block.timestamp);
    }
}

// ===== 3. 使用事件进行链下数据聚合 =====
contract OffchainDataAggregation {
    /**
     * 场景：游戏中的玩家行为统计
     * 在链上存储所有数据会非常昂贵
     * 解决方案：使用事件记录，链下聚合统计
     */

    enum ActionType {
        Move,
        Attack,
        Collect,
        Trade
    }

    // 只存储必要的游戏状态
    mapping(address => uint) public playerLevel;
    mapping(address => uint) public playerScore;

    // 详细的行为数据通过事件记录
    event PlayerAction(
        address indexed player,
        ActionType indexed actionType,
        uint value,
        uint timestamp
    );

    event ItemCollected(
        address indexed player,
        uint indexed itemId,
        uint quantity,
        uint timestamp
    );

    event PlayerTraded(
        address indexed player1,
        address indexed player2,
        uint itemId,
        uint amount,
        uint timestamp
    );

    function performAction(ActionType _action, uint _value) public {
        // 更新核心状态
        playerScore[msg.sender] += _value;

        // 记录详细事件供链下分析
        emit PlayerAction(msg.sender, _action, _value, block.timestamp);
    }

    /**
     * 链下服务可以：
     * 1. 监听所有 PlayerAction 事件
     * 2. 聚合统计数据（每日活跃用户、最常见操作等）
     * 3. 生成排行榜
     * 4. 分析玩家行为模式
     *
     * 这样既节省了链上存储成本，又能获得丰富的数据分析
     */
}

// ===== 4. 事件的安全考虑 =====
contract EventSecurity {
    address public owner;

    event AdminAction(address indexed admin, string action, bool success);

    event SensitiveOperation(address indexed user, uint amount);
    // 注意：不要在事件中记录敏感信息！
    // 错误示例：私钥、密码、未加密的个人信息

    /**
     * 安全考虑1：事件数据是公开的
     */

    // 不好：记录了敏感信息
    event UserRegisteredBad(
        address indexed user,
        string email, // 个人信息
        string passwordHash, // 即使是哈希也不应该公开
        string privateKey // 绝对不要！
    );

    // 好：只记录必要的公开信息
    event UserRegisteredGood(address indexed user, uint registeredAt);

    /**
     * 安全考虑2：事件可以被伪造（在测试环境）
     */

    // 不要仅依赖事件来验证操作
    mapping(address => bool) public verified; // 使用状态变量

    event UserVerified(address indexed user);

    function verifyUser(address _user) public {
        require(msg.sender == owner, "Not owner");

        // 错误：只触发事件，不更新状态
        // emit UserVerified(_user);

        // 正确：更新状态变量
        verified[_user] = true;
        emit UserVerified(_user);
    }

    function checkVerified(address _user) public view returns (bool) {
        // 正确：检查状态变量，而不是假设事件存在
        return verified[_user];
    }

    /**
     * 安全考虑3：事件监听可能失败
     */

    uint public criticalCounter;
    event CounterIncremented(uint newValue);

    function incrementCounter() public {
        criticalCounter++;

        // 事件触发失败不会回滚交易
        // 所以关键数据必须存储在状态变量中
        emit CounterIncremented(criticalCounter);
    }
}

// ===== 5. 事件的条件触发和优化 =====
contract ConditionalEvents {
    uint public threshold = 1000;

    event SmallTransfer(address indexed from, address indexed to, uint amount);
    event LargeTransfer(address indexed from, address indexed to, uint amount);
    event CriticalTransfer(
        address indexed from,
        address indexed to,
        uint amount,
        string reason
    );

    /**
     * 技巧：根据条件触发不同的事件
     * 这样可以更方便地过滤和监听特定类型的交易
     */
    function transfer(address _to, uint _amount) public {
        // 执行转账逻辑...

        // 根据金额触发不同的事件
        if (_amount < threshold) {
            emit SmallTransfer(msg.sender, _to, _amount);
        } else if (_amount < threshold * 10) {
            emit LargeTransfer(msg.sender, _to, _amount);
        } else {
            emit CriticalTransfer(
                msg.sender,
                _to,
                _amount,
                "Exceeds critical threshold"
            );
        }
    }
}

// ===== 6. 事件在多合约系统中的应用 =====
contract EventCommunication {
    /**
     * 场景：多个合约之间通过事件进行"通信"
     * 虽然合约本身不能直接监听事件，但链下服务可以
     */

    // 合约 A：代币合约
    event TokensTransferred(
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp
    );

    // 合约 B：奖励合约（由链下服务监听 TokensTransferred 事件）
    event RewardClaimed(
        address indexed user,
        uint rewardAmount,
        uint basedOnTransfer
    );

    /**
     * 工作流程：
     * 1. 用户在合约 A 进行转账
     * 2. 合约 A 触发 TokensTransferred 事件
     * 3. 链下服务监听到事件
     * 4. 链下服务调用合约 B 的函数
     * 5. 合约 B 给用户发放奖励并触发 RewardClaimed 事件
     */
}

// ===== 7. 事件的版本控制 =====
contract EventVersioning {
    /**
     * 场景：合约升级时，事件结构可能需要变化
     * 最佳实践：使用版本化的事件名称
     */

    // V1：初始版本
    event TransferV1(address indexed from, address indexed to, uint amount);

    // V2：添加了时间戳
    event TransferV2(
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp
    );

    // V3：添加了交易类型
    event TransferV3(
        address indexed from,
        address indexed to,
        uint amount,
        uint timestamp,
        string transferType
    );

    uint public contractVersion = 3;

    function transfer(address _to, uint _amount, string memory _type) public {
        // 根据版本触发不同的事件
        if (contractVersion == 1) {
            emit TransferV1(msg.sender, _to, _amount);
        } else if (contractVersion == 2) {
            emit TransferV2(msg.sender, _to, _amount, block.timestamp);
        } else {
            emit TransferV3(msg.sender, _to, _amount, block.timestamp, _type);
        }
    }
}

// ===== 8. 事件的测试和调试 =====
contract EventTesting {
    event DebugLog(string message, uint value);
    event FunctionCalled(string functionName, address caller, uint timestamp);
    event StateChanged(string variableName, uint oldValue, uint newValue);

    uint public counter;

    function incrementWithDebug() public {
        // 记录函数调用
        emit FunctionCalled("incrementWithDebug", msg.sender, block.timestamp);

        uint oldValue = counter;
        counter++;

        // 记录状态变化
        emit StateChanged("counter", oldValue, counter);

        // 调试信息
        emit DebugLog("Counter incremented successfully", counter);
    }

    /**
     * 测试时可以：
     * 1. 检查事件是否被触发
     * 2. 验证事件参数的正确性
     * 3. 追踪函数执行流程
     *
     * Hardhat 测试示例：
     * ```javascript
     * it("Should emit StateChanged event", async () => {
     *   await expect(contract.incrementWithDebug())
     *     .to.emit(contract, "StateChanged")
     *     .withArgs("counter", 0, 1);
     * });
     * ```
     */
}

// ===== 9. 复杂事件结构 =====
contract ComplexEventStructures {
    struct User {
        string name;
        uint age;
        address wallet;
    }

    struct Transaction {
        address from;
        address to;
        uint amount;
    }

    /**
     * 注意：事件不能直接接收 struct 类型
     * 需要将 struct 拆解为基本类型
     */

    // 错误：不能使用 struct
    // event UserRegistered(User user);

    // 正确：拆解 struct
    event UserRegistered(string name, uint age, address indexed wallet);

    // 对于复杂数据，可以使用数组
    event BatchUpdate(uint[] ids, address[] users, uint[] amounts);

    // 或者使用 bytes 存储序列化数据
    event ComplexData(
        bytes data // 可以存储任意编码的数据
    );

    function registerUser(string memory _name, uint _age) public {
        emit UserRegistered(_name, _age, msg.sender);
    }

    function updateBatch(
        uint[] memory _ids,
        address[] memory _users,
        uint[] memory _amounts
    ) public {
        emit BatchUpdate(_ids, _users, _amounts);
    }

    function storeComplexData(bytes memory _data) public {
        // 前端可以使用 ethers.js 编码/解码
        emit ComplexData(_data);
    }
}

// ===== 10. 事件的实际应用模式 =====
contract EventPatterns {
    /**
     * 模式1：状态机模式
     */
    enum State {
        Created,
        Active,
        Paused,
        Completed,
        Cancelled
    }
    State public currentState;

    event StateTransition(
        State indexed fromState,
        State indexed toState,
        address indexed triggeredBy,
        uint timestamp
    );

    function changeState(State _newState) internal {
        State oldState = currentState;
        currentState = _newState;
        emit StateTransition(oldState, _newState, msg.sender, block.timestamp);
    }

    /**
     * 模式2：审计日志模式
     */
    event AuditLog(
        address indexed actor,
        string indexed action,
        bytes32 indexed resourceId,
        bool success,
        string details,
        uint timestamp
    );

    function auditedAction(bytes32 _resourceId) public {
        bool success = true;
        // 执行操作...

        emit AuditLog(
            msg.sender,
            "ResourceModified",
            _resourceId,
            success,
            "Resource updated successfully",
            block.timestamp
        );
    }

    /**
     * 模式3：通知模式
     */
    event Notification(
        address indexed recipient,
        string indexed notificationType,
        string message,
        uint priority, // 1=low, 2=medium, 3=high
        uint timestamp
    );

    function sendNotification(
        address _user,
        string memory _message,
        uint _priority
    ) internal {
        emit Notification(_user, "Alert", _message, _priority, block.timestamp);
    }
}

// ===== 总结：事件使用最佳实践 =====
/**
 * 1. 命名规范：
 *    - 使用 PascalCase
 *    - 动词过去式（Transfer, Created, Updated）
 *    - 清晰描述发生了什么
 *
 * 2. 参数设计：
 *    - 最多 3 个 indexed 参数
 *    - indexed 用于需要过滤的参数
 *    - 地址和 ID 通常应该 indexed
 *    - 大型数据（string, bytes）indexed 后会被哈希
 *
 * 3. Gas 优化：
 *    - 避免不必要的 indexed
 *    - 使用适当的数据类型
 *    - 批量操作使用批量事件
 *    - 避免冗余数据
 *
 * 4. 安全考虑：
 *    - 不记录敏感信息
 *    - 不能用事件代替状态变量
 *    - 事件是公开的且不可变的
 *
 * 5. 可维护性：
 *    - 提供足够的上下文信息
 *    - 使用版本化（如需要）
 *    - 详细的注释说明事件用途
 *    - 保持事件结构的向后兼容性
 *
 * 6. 前端集成：
 *    - 设计易于过滤的事件结构
 *    - 包含时间戳便于排序
 *    - 考虑前端的数据需求
 *
 * 7. 测试：
 *    - 测试事件是否被触发
 *    - 验证事件参数
 *    - 测试事件过滤功能
 */
