// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "./interface/IBoxCampaign.sol";
import "./interface/IBoxItemCampaignNFT721.sol";

contract InZBoxCampaign is IBoxCampaign, ERC721Upgradeable {
    event MintBox(address _to, uint256 _tokenId, uint256 _price);
    event SetCampaign721(address _old, address _new);
    event OpenBox(address _boxCampaign, uint256 _boxId, uint8 _nftType);
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

    // OPTION: Fixed, auto-increase tokenId or not
    bool isAutoIncreasedId;

    // Duration of the campaign
    uint256 private campaignStartTime;
    uint256 private campaignEndTime;

    /// @notice Initialize new box campaign
    /// @dev Initialize new box campaign
    /// @param _feeAddress address received fee pay to mint
    /// @param _tokenUri uri of NFT box
    /// @param _payToken currency of transaction
    /// @param _name name of NFT box
    /// @param _symbol symbol of NFT box
    /// @param _price price of each mint acton
    /// @param _startTime start time of campaign can make mint
    /// @param _endTime end time of campaign can make mint
    function initialize(
        string memory _tokenUri,
        address _payToken,
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _endTime,
        bool _isAutoIncreaseId,
        uint256 _price,
        address _feeAddress
    ) public initializer {
        __ERC721_init(_name, _symbol);
        feeAddress = _feeAddress;
        payToken = IERC20(_payToken);
        tokenUri = _tokenUri;
        isAutoIncreasedId = _isAutoIncreaseId;

        totalMinted = 0;
        // calculate by sum all amount of nft type
        totalSupply = 0;

        price = _price;
        campaignStartTime = _startTime;
        campaignEndTime = _endTime;
    }

    /// @notice Initialize type for new box campaign
    /// @dev Initialize type for new box campaign
    /// @param _nftTypes list type available of NFT items
    /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
    function initializeAmountForEachType(
        uint8[] calldata _nftTypes,
        uint256[] calldata _amountOfEachNFTType
    ) public {
        require(
            _nftTypes.length == _amountOfEachNFTType.length,
            "Not enough supply for each type"
        );
        nftTypes = _nftTypes;
        for (uint i = 0; i < _amountOfEachNFTType.length; i++) {
            amountOfEachType[_nftTypes[i]] = _amountOfEachNFTType[i];
            totalSupply += _amountOfEachNFTType[i];
        }
    }

    function setItemCampaign721(address _itemCampaignTypeNFT721) public {
        address old = itemCampaignTypeNFT721;
        itemCampaignTypeNFT721 = _itemCampaignTypeNFT721;
        emit SetCampaign721(old, _itemCampaignTypeNFT721);
    }

    /// @notice buy a box
    /// @dev mint a NFT box to an address
    /// @param _tokenId token id need to mint when auto increase if off
    function mintBox(uint256 _tokenId) external payable {
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
        if (!isAutoIncreasedId) {
            require(!_exists(_tokenId), "Mint Box: tokenId's already existed");
            id = _tokenId;
        }
        _mint(msg.sender, id);
        isOpened[id] = false;
        totalMinted++;
        ownerBoxes[msg.sender].push(id);

        if (isAutoIncreasedId) {
            Counters.increment(tokenIdCounter);
        }

        emit MintBox(msg.sender, id, price);
    }

    /// @notice open a box bought
    /// @dev mint a NFT item when open a box
    /// @param _boxId token id of minted box
    function openBox(uint256 _boxId) external {
        require(!isOpened[_boxId], "Box is already opened");
        uint8 nftType = getRandomType();
        amountOfEachType[nftType]--;
        isOpened[_boxId] = true;
        IBoxItemCampaignNFT721(itemCampaignTypeNFT721).mintFromBox(
            _boxId,
            _ownerOf(_boxId),
            nftType
        );
        emit OpenBox(address(this), _boxId, nftType);
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
    function withdrawAll() public {
        payable(feeAddress).transfer(address(this).balance);
    }
}
