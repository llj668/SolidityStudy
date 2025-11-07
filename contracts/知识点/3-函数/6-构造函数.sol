// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * 构造函数（Constructor）详解
 *
 * 1. 什么是构造函数？
 *    构造函数是一个特殊的函数，在合约部署时自动执行一次，且只执行一次
 *    用于初始化合约的状态变量
 *
 * 2. 特点：
 *    - 使用 constructor 关键字定义
 *    - 每个合约只能有一个构造函数
 *    - 部署时自动调用，之后无法再次调用
 *    - 可以接收参数
 *    - 可以设置可见性（通常不写，默认public）
 */

// ===== 示例1：基础构造函数 =====
contract ConstructorBasic {
    address public owner;
    uint public createdTime;
    string public contractName;

    // 构造函数：在合约部署时执行
    constructor() {
        owner = msg.sender; // 设置合约所有者为部署者
        createdTime = block.timestamp; // 记录创建时间
        contractName = "BasicContract";
    }
}

// ===== 示例2：带参数的构造函数 =====
contract ConstructorWithParams {
    address public owner;
    uint public initialSupply;
    string public tokenName;
    string public tokenSymbol;

    // 带参数的构造函数
    // 部署时需要传入 _initialSupply, _name, _symbol 三个参数
    constructor(
        uint _initialSupply,
        string memory _name,
        string memory _symbol
    ) {
        owner = msg.sender;
        initialSupply = _initialSupply;
        tokenName = _name;
        tokenSymbol = _symbol;
    }
}

// ===== 示例3：构造函数与继承 =====
// 父合约
contract ParentContract {
    string public parentName;

    constructor(string memory _name) {
        parentName = _name;
    }
}

// 子合约方式1：在继承时直接传递参数
contract ChildContract1 is ParentContract("FixedParentName") {
    string public childName;

    constructor(string memory _childName) {
        childName = _childName;
    }
}

// 子合约方式2：在构造函数中传递参数（更灵活）
contract ChildContract2 is ParentContract {
    string public childName;

    constructor(
        string memory _parentName,
        string memory _childName
    )
        ParentContract(_parentName) // 调用父合约构造函数
    {
        childName = _childName;
    }
}

// ===== 示例4：多重继承的构造函数 =====
contract Base1 {
    uint public value1;
    constructor(uint _value1) {
        value1 = _value1;
    }
}

contract Base2 {
    uint public value2;
    constructor(uint _value2) {
        value2 = _value2;
    }
}

// 多重继承：需要调用所有父合约的构造函数
contract Derived is Base1, Base2 {
    uint public value3;

    // 方式1：在继承列表中指定
    // contract Derived is Base1(100), Base2(200) { }

    // 方式2：在构造函数修饰器列表中指定（推荐）
    constructor(uint _v1, uint _v2, uint _v3) Base1(_v1) Base2(_v2) {
        value3 = _v3;
    }
}

// ===== 示例5：构造函数的实际应用 =====
contract TokenContract {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    address public owner;

    mapping(address => uint) public balanceOf;

    // 事件
    event Transfer(address indexed from, address indexed to, uint value);

    // 构造函数初始化代币信息
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint(_decimals);
        owner = msg.sender;

        // 将所有代币分配给部署者
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}

// ===== 注意事项 =====
/**
 * 1. 构造函数不能是 view 或 pure
 * 2. 构造函数不能返回值
 * 3. 在 Solidity 0.4.22 之前，构造函数使用与合约同名的函数定义
 *    例如：function MyContract() { }  // 旧版本（已弃用）
 * 4. 如果父合约有带参数的构造函数，子合约必须调用它
 * 5. 构造函数执行完成后才会部署合约代码
 */
