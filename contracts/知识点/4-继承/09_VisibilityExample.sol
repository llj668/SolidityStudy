// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 可见性示例
 * @dev 演示不同可见性修饰符在继承中的行为
 */

// 父合约：演示各种可见性
contract Parent {
    // 状态变量的可见性
    uint256 public publicVar = 100;        // 任何人都可以访问
    uint256 internal internalVar = 200;    // 当前合约和子合约可以访问
    uint256 private privateVar = 300;      // 只有当前合约可以访问
    
    // 事件
    event PublicEvent(string message);
    event InternalEvent(string message);
    
    constructor() {
        // 在构造函数中可以访问所有变量
        publicVar = 101;
        internalVar = 201;
        privateVar = 301;
    }
    
    // public 函数：任何人都可以调用
    function publicFunction() public pure returns (string memory) {
        return "This is a public function";
    }
    
    // external 函数：只能从外部调用（不能在合约内部直接调用）
    function externalFunction() external pure returns (string memory) {
        return "This is an external function";
    }
    
    // internal 函数：当前合约和子合约可以调用
    function internalFunction() internal pure returns (string memory) {
        return "This is an internal function";
    }
    
    // private 函数：只有当前合约可以调用
    function privateFunction() private pure returns (string memory) {
        return "This is a private function";
    }
    
    // 演示在合约内部调用不同可见性的函数
    function callInternalFunctions() public returns (string memory) {
        // 可以调用 public 函数
        string memory pub = publicFunction();
        
        // 可以调用 internal 函数
        string memory intern = internalFunction();
        
        // 可以调用 private 函数
        string memory priv = privateFunction();
        
        // 不能直接调用 external 函数，需要使用 this
        // string memory ext = externalFunction(); // 这会报错
        string memory ext = this.externalFunction(); // 正确的方式
        
        emit PublicEvent("Called internal functions");
        
        return string(abi.encodePacked(pub, " | ", intern, " | ", priv, " | ", ext));
    }
    
    // 访问不同可见性的状态变量
    function accessStateVariables() public view returns (uint256, uint256, uint256) {
        return (publicVar, internalVar, privateVar);
    }
    
    // virtual 函数：可以被子合约重写
    function virtualPublicFunction() public virtual pure returns (string memory) {
        return "Parent virtual public function";
    }
    
    function virtualInternalFunction() internal virtual pure returns (string memory) {
        return "Parent virtual internal function";
    }
    
    // 修饰器的可见性
    modifier publicModifier() {
        require(msg.sender != address(0), "Invalid sender");
        _;
    }
    
    modifier internalModifier() {
        _;
        emit InternalEvent("Internal modifier executed");
    }
    
    modifier privateModifier() {
        require(block.timestamp > 0, "Invalid timestamp");
        _;
    }
    
    function useModifiers() public publicModifier internalModifier privateModifier returns (string memory) {
        return "All modifiers executed";
    }
}

// 子合约：演示继承中的可见性
contract Child is Parent {
    uint256 public childVar = 400;
    
    constructor() {
        // 可以访问 public 和 internal 变量
        publicVar = 102;
        internalVar = 202;
        // privateVar = 302; // 错误：不能访问父合约的 private 变量
        
        childVar = 401;
    }
    
    // 重写父合约的 virtual 函数
    function virtualPublicFunction() public pure override returns (string memory) {
        return "Child virtual public function";
    }
    
    function virtualInternalFunction() internal pure override returns (string memory) {
        return "Child virtual internal function";
    }
    
    // 子合约中访问父合约的函数
    function accessParentFunctions() public returns (string memory) {
        // 可以调用父合约的 public 函数
        string memory pub = publicFunction();
        
        // 可以调用父合约的 internal 函数
        string memory intern = internalFunction();
        
        // 不能调用父合约的 private 函数
        // string memory priv = privateFunction(); // 错误
        
        // 可以调用父合约的 external 函数（通过 this）
        string memory ext = this.externalFunction();
        
        return string(abi.encodePacked("Child accessing parent: ", pub, " | ", intern, " | ", ext));
    }
    
    // 子合约中访问父合约的状态变量
    function accessParentVariables() public view returns (uint256, uint256) {
        // 可以访问 public 和 internal 变量
        return (publicVar, internalVar);
        // return privateVar; // 错误：不能访问父合约的 private 变量
    }
    
    // 使用父合约的修饰器
    function useParentModifiers() public publicModifier internalModifier returns (string memory) {
        // 可以使用 public 和 internal 修饰器
        // privateModifier 不能被子合约使用
        return "Child using parent modifiers";
    }
    
    // 调用重写的虚函数
    function callVirtualFunctions() public pure returns (string memory, string memory) {
        return (virtualPublicFunction(), virtualInternalFunction());
    }
    
    // 子合约特有的函数
    function childSpecificFunction() public pure returns (string memory) {
        return "This is a child-specific function";
    }
}

// 孙子合约：演示多层继承中的可见性
contract GrandChild is Child {
    uint256 public grandChildVar = 500;
    
    constructor() {
        // 可以访问祖父合约的 public 和 internal 变量
        publicVar = 103;
        internalVar = 203;
        
        // 可以访问父合约的 public 变量
        childVar = 402;
        
        grandChildVar = 501;
    }
    
    // 进一步重写虚函数
    function virtualPublicFunction() public pure override returns (string memory) {
        return "GrandChild virtual public function";
    }
    
    function virtualInternalFunction() internal pure override returns (string memory) {
        return "GrandChild virtual internal function";
    }
    
    // 访问多层继承链中的函数
    function accessInheritanceChain() public returns (string memory) {
        // 可以调用祖父合约的函数
        string memory grandParentPub = publicFunction();
        string memory grandParentInt = internalFunction();
        
        // 可以调用父合约的函数
        string memory parentFunc = childSpecificFunction();
        
        // 调用自己重写的函数
        string memory ownFunc = virtualPublicFunction();
        
        return string(abi.encodePacked(
            "GrandChild accessing: ",
            grandParentPub, " | ",
            grandParentInt, " | ",
            parentFunc, " | ",
            ownFunc
        ));
    }
}

// 演示接口中的可见性
interface IVisibilityDemo {
    // 接口中的函数必须是 external
    function interfaceFunction() external view returns (string memory);
    
    // 接口中不能有 public、internal 或 private 函数
    // function publicFunction() public view returns (string memory); // 错误
}

// 实现接口
contract InterfaceImplementation is IVisibilityDemo {
    function interfaceFunction() external pure override returns (string memory) {
        return "Interface function implemented";
    }
    
    // 可以有其他可见性的函数
    function publicFunction() public pure returns (string memory) {
        return "Public function in implementation";
    }
    
    function internalFunction() internal pure returns (string memory) {
        return "Internal function in implementation";
    }
}

// 演示库中的可见性
library VisibilityLibrary {
    // 库中的函数通常是 internal
    function internalLibFunction(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    
    // 库中也可以有 public 函数
    function publicLibFunction(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }
    
    // 库中不能有 external 函数
    // function externalLibFunction(uint256 a) external pure returns (uint256); // 错误
}

// 使用库
contract LibraryUser {
    using VisibilityLibrary for uint256;
    
    function useLibrary(uint256 a, uint256 b) public pure returns (uint256, uint256) {
        // 使用 internal 库函数
        uint256 sum = VisibilityLibrary.internalLibFunction(a, b);
        
        // 使用 public 库函数
        uint256 product = VisibilityLibrary.publicLibFunction(a, b);
        
        // 或者使用 using for 语法
        uint256 sumWithUsing = a.internalLibFunction(b);
        
        return (sum, product);
    }
}

// 演示抽象合约中的可见性
abstract contract AbstractVisibility {
    uint256 public abstractPublicVar = 600;
    uint256 internal abstractInternalVar = 700;
    uint256 private abstractPrivateVar = 800;
    
    // 抽象函数可以有不同的可见性
    function abstractPublicFunction() public virtual pure returns (string memory);
    function abstractInternalFunction() internal virtual pure returns (string memory);
    
    // 抽象合约中的具体函数
    function concreteFunction() public view returns (uint256, uint256) {
        return (abstractPublicVar, abstractInternalVar);
        // return abstractPrivateVar; // 可以访问自己的 private 变量
    }
}

// 实现抽象合约
contract ConcreteVisibility is AbstractVisibility {
    constructor() {
        // 可以访问抽象合约的 public 和 internal 变量
        abstractPublicVar = 601;
        abstractInternalVar = 701;
        // abstractPrivateVar = 801; // 错误：不能访问抽象合约的 private 变量
    }
    
    // 实现抽象函数
    function abstractPublicFunction() public pure override returns (string memory) {
        return "Implemented abstract public function";
    }
    
    function abstractInternalFunction() internal pure override returns (string memory) {
        return "Implemented abstract internal function";
    }
    
    // 使用实现的函数
    function useImplementedFunctions() public pure returns (string memory, string memory) {
        return (abstractPublicFunction(), abstractInternalFunction());
    }
}

// 演示错误的可见性使用
contract VisibilityErrors {
    uint256 private errorVar = 900;
    
    function demonstrateErrors() public view returns (string memory) {
        // 以下是一些常见的可见性错误示例（注释掉以避免编译错误）
        
        // 1. 尝试从外部访问 private 变量
        // return errorVar; // 这在外部调用时是可以的，因为函数是 public
        
        // 2. 在接口中使用错误的可见性
        // interface BadInterface {
        //     function badFunction() public returns (uint256); // 错误：接口中必须是 external
        // }
        
        // 3. 重写函数时改变可见性
        // function publicFunction() private override returns (string memory) { // 错误：不能降低可见性
        //     return "Error";
        // }
        
        return "Demonstrating visibility concepts";
    }
}

// 最佳实践示例
contract VisibilityBestPractices {
    // 状态变量：根据需要选择合适的可见性
    uint256 public totalSupply;           // 需要外部访问的数据
    uint256 internal baseRate;            // 子合约可能需要的数据
    uint256 private secretKey;            // 敏感数据，只有当前合约使用
    
    // 函数：根据使用场景选择可见性
    function publicAPI() public pure returns (string memory) {
        // 对外提供的 API
        return "Public API function";
    }
    
    function externalAPI() external pure returns (string memory) {
        // 只从外部调用的 API（节省 gas）
        return "External API function";
    }
    
    function internalHelper() internal pure returns (string memory) {
        // 内部辅助函数，可能被子合约使用
        return "Internal helper function";
    }
    
    function privateHelper() private pure returns (string memory) {
        // 私有辅助函数，只在当前合约使用
        return "Private helper function";
    }
    
    // 修饰器：根据使用范围选择可见性
    modifier publicModifier() {
        // 可能被子合约使用的修饰器
        require(msg.sender != address(0), "Invalid sender");
        _;
    }
    
    modifier internalModifier() {
        // 只在继承链中使用的修饰器
        _;
    }
    
    // 组合使用
    function bestPracticeExample() 
        public 
        publicModifier 
        internalModifier 
        returns (string memory) 
    {
        string memory internal_result = internalHelper();
        string memory private_result = privateHelper();
        
        return string(abi.encodePacked(internal_result, " | ", private_result));
    }
}
