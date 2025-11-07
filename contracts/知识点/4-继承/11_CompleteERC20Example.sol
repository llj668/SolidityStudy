// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 完整的 ERC20 代币示例
 * @dev 演示继承在实际项目中的综合应用
 */

// 基础所有权控制合约
contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        _transferOwnership(msg.sender);
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// 暂停功能合约
contract Pausable is Ownable {
    bool private _paused;
    
    event Paused(address account);
    event Unpaused(address account);
    
    constructor() {
        _paused = false;
    }
    
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    
    function pause() public virtual onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() public virtual onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// ERC20 接口
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// ERC20 元数据接口
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// 基础 ERC20 实现
contract ERC20 is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        _beforeTokenTransfer(from, to, amount);
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
        
        _afterTokenTransfer(from, to, amount);
    }
    
    function _mint(address to, uint256 amount) internal virtual {
        require(to != address(0), "ERC20: mint to the zero address");
        
        _beforeTokenTransfer(address(0), to, amount);
        
        _totalSupply += amount;
        unchecked {
            _balances[to] += amount;
        }
        emit Transfer(address(0), to, amount);
        
        _afterTokenTransfer(address(0), to, amount);
    }
    
    function _burn(address from, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: burn from the zero address");
        
        _beforeTokenTransfer(from, address(0), amount);
        
        uint256 accountBalance = _balances[from];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[from] = accountBalance - amount;
            _totalSupply -= amount;
        }
        
        emit Transfer(from, address(0), amount);
        
        _afterTokenTransfer(from, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// 可销毁的代币扩展
contract ERC20Burnable is ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }
}

// 可暂停的代币扩展
contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

// 带有快照功能的代币
contract ERC20Snapshot is ERC20 {
    using Arrays for uint256[];
    using Counters for Counters.Counter;
    
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }
    
    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;
    
    Counters.Counter private _currentSnapshotId;
    
    event Snapshot(uint256 id);
    
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();
        
        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }
    
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }
    
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);
        return snapshotted ? value : balanceOf(account);
    }
    
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);
        return snapshotted ? value : totalSupply();
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        
        if (from == address(0)) {
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }
    
    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");
        
        uint256 index = snapshots.ids.findUpperBound(snapshotId);
        
        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }
    
    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }
    
    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }
    
    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }
    
    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

// 辅助库
library Arrays {
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }
        
        uint256 low = 0;
        uint256 high = array.length;
        
        while (low < high) {
            uint256 mid = (low + high) / 2;
            
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        
        return high;
    }
}

library Counters {
    struct Counter {
        uint256 _value;
    }
    
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// 完整的代币合约：组合所有功能
contract MyAdvancedToken is ERC20, ERC20Burnable, ERC20Pausable, ERC20Snapshot {
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18; // 100万代币
    
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public minters;
    
    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    
    modifier onlyMinter() {
        require(minters[msg.sender] || msg.sender == owner(), "Not a minter");
        _;
    }
    
    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Account is blacklisted");
        _;
    }
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        require(initialSupply <= MAX_SUPPLY, "Initial supply exceeds max supply");
        _mint(msg.sender, initialSupply);
        minters[msg.sender] = true;
    }
    
    // 铸币功能
    function mint(address to, uint256 amount) public onlyMinter {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }
    
    // 批量铸币
    function batchMint(address[] memory recipients, uint256[] memory amounts) public onlyMinter {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        require(totalSupply() + totalAmount <= MAX_SUPPLY, "Exceeds max supply");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
        }
    }
    
    // 拍快照
    function snapshot() public onlyOwner returns (uint256) {
        return _snapshot();
    }
    
    // 黑名单管理
    function blacklist(address account) public onlyOwner {
        require(!blacklisted[account], "Account already blacklisted");
        blacklisted[account] = true;
        emit Blacklisted(account);
    }
    
    function unblacklist(address account) public onlyOwner {
        require(blacklisted[account], "Account not blacklisted");
        blacklisted[account] = false;
        emit Unblacklisted(account);
    }
    
    // 铸币者管理
    function addMinter(address account) public onlyOwner {
        require(!minters[account], "Account already a minter");
        minters[account] = true;
        emit MinterAdded(account);
    }
    
    function removeMinter(address account) public onlyOwner {
        require(minters[account], "Account not a minter");
        minters[account] = false;
        emit MinterRemoved(account);
    }
    
    // 重写转账函数，添加黑名单检查
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable, ERC20Snapshot) {
        // 调用所有父合约的 _beforeTokenTransfer
        super._beforeTokenTransfer(from, to, amount);
        
        // 黑名单检查
        require(!blacklisted[from], "Sender is blacklisted");
        require(!blacklisted[to], "Recipient is blacklisted");
    }
    
    // 紧急提取功能
    function emergencyWithdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    
    // 回收错误发送的代币
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        require(tokenAddress != address(this), "Cannot recover own token");
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
    
    // 获取合约信息
    function getContractInfo() public view returns (
        string memory tokenName,
        string memory tokenSymbol,
        uint256 tokenDecimals,
        uint256 currentSupply,
        uint256 maxSupply,
        bool isPaused,
        uint256 currentSnapshotId
    ) {
        return (
            name(),
            symbol(),
            decimals(),
            totalSupply(),
            MAX_SUPPLY,
            paused(),
            _getCurrentSnapshotId()
        );
    }
    
    // 批量查询余额
    function batchBalanceOf(address[] memory accounts) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = balanceOf(accounts[i]);
        }
        return balances;
    }
    
    // 批量查询快照余额
    function batchBalanceOfAt(address[] memory accounts, uint256 snapshotId) 
        public 
        view 
        returns (uint256[] memory) 
    {
        uint256[] memory balances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = balanceOfAt(accounts[i], snapshotId);
        }
        return balances;
    }
}
