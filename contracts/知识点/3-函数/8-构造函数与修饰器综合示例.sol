// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * 构造函数与修饰器的综合应用示例
 *
 * 这个文件展示如何在实际项目中同时使用构造函数和修饰器
 * 实现一个完整的去中心化投票系统
 */

contract VotingSystem {
    // ===== 状态变量 =====
    address public chairperson; // 主席（创建者）
    uint public proposalCount; // 提案数量
    uint public voterCount; // 投票者数量
    bool public votingOpen; // 投票是否开放
    uint public votingEndTime; // 投票结束时间

    // 提案结构
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
        bool executed;
    }

    // 投票者结构
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
        uint weight; // 投票权重
    }

    // 存储
    mapping(uint => Proposal) public proposals;
    mapping(address => Voter) public voters;

    // ===== 事件 =====
    event ProposalCreated(uint indexed proposalId, string description);
    event VoterRegistered(address indexed voter, uint weight);
    event VoteCasted(address indexed voter, uint indexed proposalId);
    event VotingStatusChanged(bool isOpen);
    event ProposalExecuted(uint indexed proposalId);

    // ===== 构造函数：初始化投票系统 =====
    constructor(string[] memory _proposalDescriptions, uint _votingDuration) {
        // 设置主席为合约部署者
        chairperson = msg.sender;

        // 给主席注册投票资格，权重为 1
        voters[chairperson].isRegistered = true;
        voters[chairperson].weight = 1;
        voterCount = 1;

        // 创建提案
        require(_proposalDescriptions.length > 0, "Need at least one proposal");
        for (uint i = 0; i < _proposalDescriptions.length; i++) {
            proposalCount++;
            proposals[proposalCount] = Proposal({
                id: proposalCount,
                description: _proposalDescriptions[i],
                voteCount: 0,
                executed: false
            });
            emit ProposalCreated(proposalCount, _proposalDescriptions[i]);
        }

        // 设置投票时间
        votingEndTime = block.timestamp + _votingDuration;
        votingOpen = true;

        emit VotingStatusChanged(true);
    }

    // ===== 修饰器定义 =====

    // 修饰器：只有主席可以调用
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this");
        _;
    }

    // 修饰器：投票必须开放
    modifier votingMustBeOpen() {
        require(votingOpen, "Voting is not open");
        require(block.timestamp < votingEndTime, "Voting period has ended");
        _;
    }

    // 修饰器：投票必须关闭
    modifier votingMustBeClosed() {
        require(
            !votingOpen || block.timestamp >= votingEndTime,
            "Voting is still open"
        );
        _;
    }

    // 修饰器：检查是否已注册
    modifier onlyRegisteredVoter() {
        require(
            voters[msg.sender].isRegistered,
            "You are not registered to vote"
        );
        _;
    }

    // 修饰器：检查是否未投票
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }

    // 修饰器：检查提案是否存在
    modifier proposalExists(uint _proposalId) {
        require(
            _proposalId > 0 && _proposalId <= proposalCount,
            "Proposal does not exist"
        );
        _;
    }

    // 修饰器：检查提案是否未执行
    modifier proposalNotExecuted(uint _proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        _;
    }

    // ===== 功能函数（使用修饰器） =====

    /**
     * 注册投票者
     * 只有主席可以注册新的投票者
     */
    function registerVoter(
        address _voter,
        uint _weight
    ) public onlyChairperson votingMustBeOpen {
        require(!voters[_voter].isRegistered, "Voter already registered");
        require(_voter != address(0), "Invalid address");
        require(_weight > 0, "Weight must be greater than 0");

        voters[_voter].isRegistered = true;
        voters[_voter].weight = _weight;
        voterCount++;

        emit VoterRegistered(_voter, _weight);
    }

    /**
     * 批量注册投票者
     */
    function registerVoters(
        address[] memory _voters,
        uint[] memory _weights
    ) public onlyChairperson votingMustBeOpen {
        require(_voters.length == _weights.length, "Arrays length mismatch");

        for (uint i = 0; i < _voters.length; i++) {
            if (
                !voters[_voters[i]].isRegistered &&
                _voters[i] != address(0) &&
                _weights[i] > 0
            ) {
                voters[_voters[i]].isRegistered = true;
                voters[_voters[i]].weight = _weights[i];
                voterCount++;
                emit VoterRegistered(_voters[i], _weights[i]);
            }
        }
    }

    /**
     * 投票
     * 只有已注册且未投票的用户可以投票
     */
    function vote(
        uint _proposalId
    )
        public
        votingMustBeOpen
        onlyRegisteredVoter
        hasNotVoted
        proposalExists(_proposalId)
    {
        Voter storage sender = voters[msg.sender];
        sender.hasVoted = true;
        sender.votedProposalId = _proposalId;

        // 根据权重增加票数
        proposals[_proposalId].voteCount += sender.weight;

        emit VoteCasted(msg.sender, _proposalId);
    }

    /**
     * 关闭投票
     * 只有主席可以提前关闭投票
     */
    function closeVoting() public onlyChairperson votingMustBeOpen {
        votingOpen = false;
        emit VotingStatusChanged(false);
    }

    /**
     * 获取获胜提案
     * 投票关闭后才能查询
     */
    function getWinningProposal()
        public
        view
        votingMustBeClosed
        returns (
            uint winningProposalId,
            string memory description,
            uint voteCount
        )
    {
        uint winningVoteCount = 0;
        uint winningId = 0;

        for (uint i = 1; i <= proposalCount; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningId = i;
            }
        }

        require(winningId > 0, "No votes cast");

        return (
            winningId,
            proposals[winningId].description,
            proposals[winningId].voteCount
        );
    }

    /**
     * 执行获胜提案
     * 投票关闭后，主席可以执行获胜提案
     */
    function executeWinningProposal()
        public
        onlyChairperson
        votingMustBeClosed
        returns (string memory)
    {
        (uint winningId, string memory description, ) = getWinningProposal();

        require(!proposals[winningId].executed, "Proposal already executed");

        proposals[winningId].executed = true;
        emit ProposalExecuted(winningId);

        return description;
    }

    /**
     * 获取所有提案信息
     */
    function getAllProposals()
        public
        view
        returns (
            uint[] memory ids,
            string[] memory descriptions,
            uint[] memory voteCounts,
            bool[] memory executedStatuses
        )
    {
        ids = new uint[](proposalCount);
        descriptions = new string[](proposalCount);
        voteCounts = new uint[](proposalCount);
        executedStatuses = new bool[](proposalCount);

        for (uint i = 1; i <= proposalCount; i++) {
            ids[i - 1] = proposals[i].id;
            descriptions[i - 1] = proposals[i].description;
            voteCounts[i - 1] = proposals[i].voteCount;
            executedStatuses[i - 1] = proposals[i].executed;
        }

        return (ids, descriptions, voteCounts, executedStatuses);
    }

    /**
     * 获取投票者信息
     */
    function getVoterInfo(
        address _voter
    )
        public
        view
        returns (
            bool isRegistered,
            bool hasVoted,
            uint votedProposalId,
            uint weight
        )
    {
        Voter memory voter = voters[_voter];
        return (
            voter.isRegistered,
            voter.hasVoted,
            voter.votedProposalId,
            voter.weight
        );
    }

    /**
     * 获取投票系统状态
     */
    function getVotingStatus()
        public
        view
        returns (
            bool isOpen,
            uint endTime,
            uint timeRemaining,
            uint totalProposals,
            uint totalVoters
        )
    {
        uint remaining = 0;
        if (block.timestamp < votingEndTime) {
            remaining = votingEndTime - block.timestamp;
        }

        return (
            votingOpen && block.timestamp < votingEndTime,
            votingEndTime,
            remaining,
            proposalCount,
            voterCount
        );
    }
}

// ===== 总结 =====
/**
 * 这个综合示例展示了：
 *
 * 1. 构造函数的使用：
 *    - 初始化主席地址
 *    - 创建初始提案
 *    - 设置投票时间
 *    - 注册主席为投票者
 *
 * 2. 修饰器的使用：
 *    - onlyChairperson: 权限控制
 *    - votingMustBeOpen/Closed: 状态控制
 *    - onlyRegisteredVoter: 身份验证
 *    - hasNotVoted: 防止重复投票
 *    - proposalExists: 输入验证
 *    - proposalNotExecuted: 防止重复执行
 *
 * 3. 最佳实践：
 *    - 使用修饰器提高代码可读性和复用性
 *    - 在构造函数中进行必要的初始化
 *    - 合理组合多个修饰器实现复杂的访问控制
 *    - 使用事件记录重要操作
 *    - 提供查询函数获取合约状态
 */
