// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * 事件的综合实战案例：NFT 交易市场
 *
 * 这个案例展示了如何在实际项目中使用事件来追踪：
 * - NFT 的创建和转移
 * - 上架和下架
 * - 购买和出售
 * - 价格变更
 * - 版税支付
 */

contract NFTMarketplace {
    // ===== 数据结构 =====

    struct NFT {
        uint tokenId;
        address creator; // 创作者
        address owner; // 当前所有者
        string metadata; // 元数据 URI
        uint royaltyPercent; // 版税百分比（基于 1000，如 50 = 5%）
        uint createdAt;
    }

    struct Listing {
        uint tokenId;
        address seller;
        uint price;
        bool isActive;
        uint listedAt;
    }

    struct Offer {
        uint offerId;
        uint tokenId;
        address buyer;
        uint price;
        bool isActive;
        uint createdAt;
    }

    // ===== 状态变量 =====

    address public owner;
    uint public platformFeePercent = 25; // 2.5% 平台费（基于 1000）
    uint public tokenIdCounter;
    uint public offerIdCounter;

    mapping(uint => NFT) public nfts;
    mapping(uint => Listing) public listings;
    mapping(uint => Offer) public offers;
    mapping(address => uint) public balances; // 卖家余额

    // ===== 事件定义 =====

    // NFT 生命周期事件
    event NFTMinted(
        uint indexed tokenId,
        address indexed creator,
        string metadata,
        uint royaltyPercent,
        uint timestamp
    );

    event NFTTransferred(
        uint indexed tokenId,
        address indexed from,
        address indexed to,
        uint timestamp
    );

    event NFTBurned(
        uint indexed tokenId,
        address indexed owner,
        uint timestamp
    );

    // 市场交易事件
    event NFTListed(
        uint indexed tokenId,
        address indexed seller,
        uint price,
        uint timestamp
    );

    event NFTUnlisted(
        uint indexed tokenId,
        address indexed seller,
        uint timestamp
    );

    event NFTPriceChanged(
        uint indexed tokenId,
        address indexed seller,
        uint oldPrice,
        uint newPrice,
        uint timestamp
    );

    event NFTSold(
        uint indexed tokenId,
        address indexed seller,
        address indexed buyer,
        uint price,
        uint platformFee,
        uint royaltyFee,
        uint timestamp
    );

    // 报价事件
    event OfferCreated(
        uint indexed offerId,
        uint indexed tokenId,
        address indexed buyer,
        uint price,
        uint timestamp
    );

    event OfferCancelled(
        uint indexed offerId,
        uint indexed tokenId,
        address indexed buyer,
        uint timestamp
    );

    event OfferAccepted(
        uint indexed offerId,
        uint indexed tokenId,
        address indexed seller,
        address buyer,
        uint price,
        uint timestamp
    );

    // 资金事件
    event FundsDeposited(address indexed user, uint amount, uint timestamp);

    event FundsWithdrawn(address indexed user, uint amount, uint timestamp);

    event RoyaltyPaid(
        uint indexed tokenId,
        address indexed creator,
        uint amount,
        uint timestamp
    );

    event PlatformFeePaid(uint indexed tokenId, uint amount, uint timestamp);

    // 管理事件
    event PlatformFeeChanged(
        uint oldFee,
        uint newFee,
        address indexed changedBy,
        uint timestamp
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner,
        uint timestamp
    );

    // ===== 修饰器 =====

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyNFTOwner(uint _tokenId) {
        require(nfts[_tokenId].owner == msg.sender, "Not NFT owner");
        _;
    }

    modifier nftExists(uint _tokenId) {
        require(
            _tokenId > 0 && _tokenId <= tokenIdCounter,
            "NFT does not exist"
        );
        _;
    }

    // ===== 构造函数 =====

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender, block.timestamp);
    }

    // ===== NFT 基础功能 =====

    /**
     * 铸造 NFT
     */
    function mintNFT(
        string memory _metadata,
        uint _royaltyPercent
    ) public returns (uint) {
        require(_royaltyPercent <= 1000, "Royalty too high"); // 最高 100%

        tokenIdCounter++;
        uint newTokenId = tokenIdCounter;

        nfts[newTokenId] = NFT({
            tokenId: newTokenId,
            creator: msg.sender,
            owner: msg.sender,
            metadata: _metadata,
            royaltyPercent: _royaltyPercent,
            createdAt: block.timestamp
        });

        // 触发铸造事件
        emit NFTMinted(
            newTokenId,
            msg.sender,
            _metadata,
            _royaltyPercent,
            block.timestamp
        );

        return newTokenId;
    }

    /**
     * 转移 NFT
     */
    function transferNFT(
        uint _tokenId,
        address _to
    ) public nftExists(_tokenId) onlyNFTOwner(_tokenId) {
        require(_to != address(0), "Invalid address");
        require(!listings[_tokenId].isActive, "NFT is listed");

        address from = nfts[_tokenId].owner;
        nfts[_tokenId].owner = _to;

        // 触发转移事件
        emit NFTTransferred(_tokenId, from, _to, block.timestamp);
    }

    /**
     * 销毁 NFT
     */
    function burnNFT(
        uint _tokenId
    ) public nftExists(_tokenId) onlyNFTOwner(_tokenId) {
        require(!listings[_tokenId].isActive, "NFT is listed");

        address nftOwner = nfts[_tokenId].owner;
        delete nfts[_tokenId];

        // 触发销毁事件
        emit NFTBurned(_tokenId, nftOwner, block.timestamp);
    }

    // ===== 市场功能 =====

    /**
     * 上架 NFT
     */
    function listNFT(
        uint _tokenId,
        uint _price
    ) public nftExists(_tokenId) onlyNFTOwner(_tokenId) {
        require(_price > 0, "Price must be greater than 0");
        require(!listings[_tokenId].isActive, "Already listed");

        listings[_tokenId] = Listing({
            tokenId: _tokenId,
            seller: msg.sender,
            price: _price,
            isActive: true,
            listedAt: block.timestamp
        });

        // 触发上架事件
        emit NFTListed(_tokenId, msg.sender, _price, block.timestamp);
    }

    /**
     * 下架 NFT
     */
    function unlistNFT(
        uint _tokenId
    ) public nftExists(_tokenId) onlyNFTOwner(_tokenId) {
        require(listings[_tokenId].isActive, "Not listed");

        listings[_tokenId].isActive = false;

        // 触发下架事件
        emit NFTUnlisted(_tokenId, msg.sender, block.timestamp);
    }

    /**
     * 修改价格
     */
    function changePrice(
        uint _tokenId,
        uint _newPrice
    ) public nftExists(_tokenId) onlyNFTOwner(_tokenId) {
        require(listings[_tokenId].isActive, "Not listed");
        require(_newPrice > 0, "Price must be greater than 0");

        uint oldPrice = listings[_tokenId].price;
        listings[_tokenId].price = _newPrice;

        // 触发价格变更事件
        emit NFTPriceChanged(
            _tokenId,
            msg.sender,
            oldPrice,
            _newPrice,
            block.timestamp
        );
    }

    /**
     * 购买 NFT
     */
    function buyNFT(uint _tokenId) public payable nftExists(_tokenId) {
        Listing storage listing = listings[_tokenId];
        require(listing.isActive, "NFT not for sale");
        require(msg.value >= listing.price, "Insufficient payment");
        require(msg.sender != listing.seller, "Cannot buy your own NFT");

        NFT storage nft = nfts[_tokenId];
        address seller = listing.seller;
        uint price = listing.price;

        // 计算费用
        uint platformFee = (price * platformFeePercent) / 1000;
        uint royaltyFee = 0;

        // 如果不是创作者在卖，支付版税
        if (seller != nft.creator) {
            royaltyFee = (price * nft.royaltyPercent) / 1000;
        }

        uint sellerAmount = price - platformFee - royaltyFee;

        // 转移 NFT 所有权
        nft.owner = msg.sender;
        listing.isActive = false;

        // 分配资金
        balances[seller] += sellerAmount;
        balances[owner] += platformFee;

        if (royaltyFee > 0) {
            balances[nft.creator] += royaltyFee;
            // 触发版税支付事件
            emit RoyaltyPaid(
                _tokenId,
                nft.creator,
                royaltyFee,
                block.timestamp
            );
        }

        // 触发平台费用事件
        emit PlatformFeePaid(_tokenId, platformFee, block.timestamp);

        // 触发出售事件
        emit NFTSold(
            _tokenId,
            seller,
            msg.sender,
            price,
            platformFee,
            royaltyFee,
            block.timestamp
        );

        // 触发转移事件
        emit NFTTransferred(_tokenId, seller, msg.sender, block.timestamp);

        // 退还多余的款项
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    // ===== 报价功能 =====

    /**
     * 创建报价
     */
    function createOffer(uint _tokenId) public payable nftExists(_tokenId) {
        require(msg.value > 0, "Offer must be greater than 0");
        require(
            nfts[_tokenId].owner != msg.sender,
            "Cannot offer on your own NFT"
        );

        offerIdCounter++;
        uint newOfferId = offerIdCounter;

        offers[newOfferId] = Offer({
            offerId: newOfferId,
            tokenId: _tokenId,
            buyer: msg.sender,
            price: msg.value,
            isActive: true,
            createdAt: block.timestamp
        });

        // 触发报价创建事件
        emit OfferCreated(
            newOfferId,
            _tokenId,
            msg.sender,
            msg.value,
            block.timestamp
        );
    }

    /**
     * 取消报价
     */
    function cancelOffer(uint _offerId) public {
        Offer storage offer = offers[_offerId];
        require(offer.isActive, "Offer not active");
        require(offer.buyer == msg.sender, "Not your offer");

        uint tokenId = offer.tokenId;
        uint refundAmount = offer.price;

        offer.isActive = false;

        // 退款
        payable(msg.sender).transfer(refundAmount);

        // 触发报价取消事件
        emit OfferCancelled(_offerId, tokenId, msg.sender, block.timestamp);
    }

    /**
     * 接受报价
     */
    function acceptOffer(
        uint _offerId
    ) public nftExists(offers[_offerId].tokenId) {
        Offer storage offer = offers[_offerId];
        require(offer.isActive, "Offer not active");

        uint tokenId = offer.tokenId;
        require(nfts[tokenId].owner == msg.sender, "Not NFT owner");

        NFT storage nft = nfts[tokenId];
        uint price = offer.price;
        address buyer = offer.buyer;

        // 计算费用
        uint platformFee = (price * platformFeePercent) / 1000;
        uint royaltyFee = 0;

        if (msg.sender != nft.creator) {
            royaltyFee = (price * nft.royaltyPercent) / 1000;
        }

        uint sellerAmount = price - platformFee - royaltyFee;

        // 转移所有权
        address seller = nft.owner;
        nft.owner = buyer;
        offer.isActive = false;

        // 如果有上架，取消上架
        if (listings[tokenId].isActive) {
            listings[tokenId].isActive = false;
            emit NFTUnlisted(tokenId, seller, block.timestamp);
        }

        // 分配资金
        balances[seller] += sellerAmount;
        balances[owner] += platformFee;

        if (royaltyFee > 0) {
            balances[nft.creator] += royaltyFee;
            emit RoyaltyPaid(tokenId, nft.creator, royaltyFee, block.timestamp);
        }

        emit PlatformFeePaid(tokenId, platformFee, block.timestamp);

        // 触发报价接受事件
        emit OfferAccepted(
            _offerId,
            tokenId,
            seller,
            buyer,
            price,
            block.timestamp
        );

        // 触发出售事件
        emit NFTSold(
            tokenId,
            seller,
            buyer,
            price,
            platformFee,
            royaltyFee,
            block.timestamp
        );

        // 触发转移事件
        emit NFTTransferred(tokenId, seller, buyer, block.timestamp);
    }

    // ===== 资金管理 =====

    /**
     * 提取余额
     */
    function withdraw() public {
        uint amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        // 触发提取事件
        emit FundsWithdrawn(msg.sender, amount, block.timestamp);
    }

    /**
     * 存入资金（用于报价等）
     */
    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");

        balances[msg.sender] += msg.value;

        // 触发存款事件
        emit FundsDeposited(msg.sender, msg.value, block.timestamp);
    }

    // ===== 管理功能 =====

    /**
     * 修改平台费用
     */
    function setPlatformFee(uint _newFee) public onlyOwner {
        require(_newFee <= 100, "Fee too high"); // 最高 10%

        uint oldFee = platformFeePercent;
        platformFeePercent = _newFee;

        // 触发费用变更事件
        emit PlatformFeeChanged(oldFee, _newFee, msg.sender, block.timestamp);
    }

    /**
     * 转移所有权
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");

        address oldOwner = owner;
        owner = _newOwner;

        // 触发所有权转移事件
        emit OwnershipTransferred(oldOwner, _newOwner, block.timestamp);
    }

    // ===== 查询功能 =====

    /**
     * 获取 NFT 信息
     */
    function getNFTInfo(
        uint _tokenId
    )
        public
        view
        nftExists(_tokenId)
        returns (
            address creator,
            address currentOwner,
            string memory metadata,
            uint royaltyPercent,
            bool isListed,
            uint price
        )
    {
        NFT memory nft = nfts[_tokenId];
        Listing memory listing = listings[_tokenId];

        return (
            nft.creator,
            nft.owner,
            nft.metadata,
            nft.royaltyPercent,
            listing.isActive,
            listing.price
        );
    }
}

// ===== 如何使用这些事件（前端 JavaScript 示例）=====
/**
 * // 监听 NFT 铸造事件
 * contract.events.NFTMinted({
 *     fromBlock: 'latest'
 * })
 * .on('data', (event) => {
 *     console.log('New NFT minted:', event.returnValues);
 *     // 更新 UI，显示新铸造的 NFT
 * });
 *
 * // 监听特定用户的购买事件
 * contract.events.NFTSold({
 *     filter: { buyer: userAddress },
 *     fromBlock: 0
 * })
 * .on('data', (event) => {
 *     console.log('You bought NFT:', event.returnValues);
 * });
 *
 * // 查询历史交易记录
 * const sales = await contract.getPastEvents('NFTSold', {
 *     filter: { tokenId: 123 },
 *     fromBlock: 0,
 *     toBlock: 'latest'
 * });
 *
 * // 监听价格变更
 * contract.events.NFTPriceChanged({
 *     filter: { tokenId: 123 },
 *     fromBlock: 'latest'
 * })
 * .on('data', (event) => {
 *     const { oldPrice, newPrice } = event.returnValues;
 *     console.log(`Price changed from ${oldPrice} to ${newPrice}`);
 * });
 */
