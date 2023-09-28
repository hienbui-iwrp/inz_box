// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interface/IBoxCampaign.sol";
import "./interface/IBoxItemCampaignNFT721.sol";

contract InZBoxCampaign is
    IBoxCampaign,
    ERC721Upgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable
{
    ///
    ///         Event Definitions
    ///

    /// @param _to Owner of box NFT
    /// @param _tokenId token id of box
    /// @param _price price used for minting
    event MintBox(address _to, uint256 _tokenId, uint256 _price);
    /// @param _type list type valid
    /// @param _amount amount available for each type
    event SetAmountForEachType(uint8[] _type, uint256[] _amount);
    /// @param _old old address
    /// @param _new new address have been changed
    event SetCampaign721(address _old, address _new);
    /// @param _boxOwner owner of box
    /// @param _boxId id of box opened
    /// @param _nftType typed of item received
    event OpenBox(address _boxOwner, uint256 _boxId, uint8 _nftType);

    ///
    ///             STORAGE DATA DECLARATIONS
    ///
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant UPGRATE_ROLE = keccak256("UPGRATE_ROLE");
    bytes32 internal constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    ///
    ///             EXTERNAL USING
    ///
    using Counters for Counters.Counter;
    // Address will receive fee from mint
    address private feeAddress;
    IERC20 payToken;
    // tokenURI of box
    string private tokenUri;
    // Counter for tokenId
    Counters.Counter internal tokenIdCounter;

    // address of campaign type nft 721 to use its function
    address private itemCampaignTypeNFT721;

    // map box id to bool
    mapping(uint256 => bool) private isOpened;
    // list boxes of each owner
    mapping(address => uint256[]) private ownerBoxes;
    // nft type can be opened from box
    uint8[] private nftTypes;
    // amount nft can be opened of each type
    mapping(uint8 => uint256) private amountOfEachType;
    // total supply of this box campaign
    uint256 private totalSupply;
    // total box have minted
    uint256 private totalMinted;
    // price of each box
    uint256 private price;

    // Duration of the campaign
    uint256 private campaignStartTime;
    uint256 private campaignEndTime;

    /// @notice Initialize new box campaign
    /// @dev Initialize new box campaign
    /// @param _itemCampaign campaign use for minting item
    /// @param _feeAddress address received fee pay to mint
    /// @param _tokenUri uri of NFT box
    /// @param _payToken currency of transaction
    /// @param _name name of NFT box
    /// @param _symbol symbol of NFT box
    /// @param _price price of each mint acton
    /// @param _startTime start time of campaign can make mint
    /// @param _endTime end time of campaign can make mint

    function initialize(
        address _itemCampaign,
        string memory _tokenUri,
        address _payToken,
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price,
        address _feeAddress
    ) public initializer {
        __ERC721_init(_name, _symbol);
        itemCampaignTypeNFT721 = _itemCampaign;
        feeAddress = _feeAddress;
        payToken = IERC20(_payToken);
        tokenUri = _tokenUri;

        totalMinted = 0;
        // calculate by sum all amount of nft type
        totalSupply = 0;

        price = _price;
        campaignStartTime = _startTime;
        campaignEndTime = _endTime;

        __AccessControl_init();
        _transferOwnership(tx.origin);

        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(ADMIN_ROLE, tx.origin);
        _setupRole(UPGRATE_ROLE, tx.origin);
        _setupRole(UPGRATE_ROLE, msg.sender);
        _setupRole(WITHDRAW_ROLE, tx.origin);
    }

    /// @notice Initialize type for new box campaign
    /// @dev Initialize type for new box campaign
    /// @param _nftTypes list type available of NFT items
    /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
    function setAmountForEachType(
        uint8[] calldata _nftTypes,
        uint256[] calldata _amountOfEachNFTType
    ) public onlyRole(UPGRATE_ROLE) {
        require(
            _nftTypes.length == _amountOfEachNFTType.length,
            "Not enough supply for each type"
        );
        nftTypes = _nftTypes;
        for (uint i = 0; i < _amountOfEachNFTType.length; i++) {
            amountOfEachType[_nftTypes[i]] = _amountOfEachNFTType[i];
            totalSupply += _amountOfEachNFTType[i];
        }

        emit SetAmountForEachType(_nftTypes, _amountOfEachNFTType);
    }

    /// @notice Set new item collection
    /// @dev Initialize type for new box campaign
    /// @param _itemCampaignTypeNFT721 item collection address
    function setItemCampaign721(
        address _itemCampaignTypeNFT721
    ) public onlyRole(UPGRATE_ROLE) {
        address old = itemCampaignTypeNFT721;
        itemCampaignTypeNFT721 = _itemCampaignTypeNFT721;
        emit SetCampaign721(old, _itemCampaignTypeNFT721);
    }

    /// @notice buy a box
    /// @dev mint a NFT box to an address
    function mintBox() external payable {
        require(true, "Not enough supply for");
        require(
            campaignStartTime <= block.timestamp,
            "The campain's not started yet"
        );
        require(
            campaignEndTime >= block.timestamp,
            "The campaign's already ended"
        );
        require(totalMinted < totalSupply, "Boxes are out of stock");

        if (address(payToken) == address(0x0)) {
            require(msg.value >= price, "Not enough native coin to mint");
            payable(feeAddress).transfer(price);
        } else {
            payToken.transferFrom(msg.sender, feeAddress, price);
        }

        uint id = Counters.current(tokenIdCounter);

        _mint(msg.sender, id);
        isOpened[id] = false;
        totalMinted++;
        ownerBoxes[msg.sender].push(id);

        Counters.increment(tokenIdCounter);

        emit MintBox(msg.sender, id, price);
    }

    /// @notice open a box bought
    /// @dev mint a NFT item when open a box
    /// @param _boxId token id of minted box
    function openBox(uint256 _boxId) external {
        require(!isOpened[_boxId], "Box is already opened");
        require(_ownerOf(_boxId) == msg.sender, "Sender is not onwer");

        uint8 nftType = getRandomType();
        amountOfEachType[nftType]--;
        isOpened[_boxId] = true;
        IBoxItemCampaignNFT721(itemCampaignTypeNFT721).mintFromBox(
            _ownerOf(_boxId),
            nftType
        );
        emit OpenBox(_ownerOf(_boxId), _boxId, nftType);
    }

    /// @notice get type of item when open box
    /// @dev ramdom available in nftType when mint new NFT item
    /// @return type of item available in nftType
    function getRandomType() internal view returns (uint8) {
        uint256 remainSupply = totalSupply - totalMinted;
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number),
                    block.timestamp,
                    msg.sender,
                    remainSupply
                )
            )
        ) % remainSupply;

        uint256 accumulation = 0;
        for (uint8 i = 0; i < nftTypes.length; i++) {
            accumulation += amountOfEachType[nftTypes[i]];
            if (randomNumber < accumulation) return nftTypes[i];
        }

        return nftTypes[0];
    }

    /// @notice withdraw the remaining native coins in current campign
    function withdrawAll() public onlyRole(WITHDRAW_ROLE) {
        payable(feeAddress).transfer(address(this).balance);
    }

    /// @notice supportsInterface from AccessControlUpgradeable
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
