// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "./interface/IBoxCampaign.sol";
import "./interface/ICampaignTypeNFT721.sol";

contract InzBoxCampaign is IBoxCampaign, ERC721Upgradeable {
    event MintBox(address _to, uint256 _tokenId, uint256 _price);
    event SetCampaign721(address _old, address _new);
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
    address private campaignTypeNFT721;

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
    /// @param _name name of NFT box
    /// @param _symbol symbol of NFT box
    /// @param _feeAddress address received fee pay to mint
    /// @param _payToken currency of transaction
    /// @param _tokenUri uri of NFT box
    /// @param _campaignTypeNFT721 address of items collection
    /// @param _nftTypes list type available of NFT items
    /// @param _amountOfEachType supply for each NFT type follow to _nftTypes
    /// @param _price price of each mint acton
    /// @param _startTime start time of campaign can make mint
    /// @param _endTime end time of campaign can make mint
    function initialize(
        string memory _name,
        string memory _symbol,
        address _feeAddress,
        address _payToken,
        string memory _tokenUri,
        address _campaignTypeNFT721,
        uint8[] memory _nftTypes,
        uint256[] memory _amountOfEachType,
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        require(
            _nftTypes.length == _amountOfEachType.length,
            "Not enough supply for each type"
        );
        __ERC721_init(_name, _symbol);
        feeAddress = _feeAddress;
        payToken = IERC20(_payToken);
        tokenUri = _tokenUri;
        campaignTypeNFT721 = _campaignTypeNFT721;
        nftTypes = _nftTypes;

        totalMinted = 0;
        totalSupply = 0;
        for (uint i = 0; i < _amountOfEachType.length; i++) {
            amountOfEachType[_nftTypes[i]] = _amountOfEachType[i];
            totalSupply += _amountOfEachType[i];
        }

        price = _price;
        campaignStartTime = _startTime;
        campaignEndTime = _endTime;
    }

    function setCampaign721(address _campaignTypeNFT721) public {
        address old = _campaignTypeNFT721;
        campaignTypeNFT721 = _campaignTypeNFT721;
        emit SetCampaign721(old, _campaignTypeNFT721);
    }

    /// @notice buy a box
    /// @dev mint a NFT box to an address
    /// @param _to address is used to owner new NFT box
    function mintBox(address _to) external payable {
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
        _mint(_to, id);
        isOpened[id] = false;
        totalMinted++;
        ownerBoxes[_to].push(id);
        Counters.increment(tokenIdCounter);

        emit MintBox(_to, id, price);
    }

    /// @notice open a box bought
    /// @dev mint a NFT item when open a box
    /// @param _boxId token id of minted box
    function openBox(uint256 _boxId) external {
        require(!isOpened[_boxId], "box is already opened");
        uint8 nftType = getRandomType();
        amountOfEachType[nftType]--;
        isOpened[_boxId] = true;
        ICampaignTypeNFT721(campaignTypeNFT721).mintFromBox();
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
