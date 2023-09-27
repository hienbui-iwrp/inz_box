// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IBoxItemCampaignNFT721.sol";

contract InZBoxItemCampaignNFT721 is ERC721Upgradeable, IBoxItemCampaignNFT721 {
    using Counters for Counters.Counter;
    // EVENT DEFINITION
    event TokenCreated(
        address _to,
        uint256 _fromBox,
        uint256 _tokenId,
        uint8 _tokenType
    );
    // LOCAL VARIABLE
    // Address of box campaign
    address private boxCampaign;

    // All types of campaign
    uint8[] private nftTypes;

    // Uri by type
    mapping(uint8 => string) private typeToUri;

    // Token id is is opened by which box id (token id => box id)
    mapping(uint256 => uint256) private fromBoxId;

    // Mapping token's holder address to tokenIds list
    mapping(address => uint256[]) private holders;

    Counters.Counter private idCounters;

    // MODIFIERS

    modifier onlyFromBoxCampaign() {
        require(boxCampaign == msg.sender, "Must be called in box campaign");
        _;
    }

    /**
     *          Contract Initialization
     */
    function initialize(
        string memory _symbol,
        string memory _name,
        address _boxCampaign
    ) external initializer {
        __ERC721_init(_name, _symbol);
        // __AccessControl_init();
        // __UUPSUpgradeable_init();
        // _transferOwnership(_adminAddress);

        boxCampaign = _boxCampaign;

        // _setupRole(ADMIN_ROLE, _adminAddress);
        // _setupRole(DEFAULT_ADMIN_ROLE, _adminAddress);
        // _setupRole(DESIGN_ROLE, _adminAddress);
        // _setupRole(BURNER_ROLE, _adminAddress);
    }

    /// @notice Mint nft from box
    /// @dev Only box campaign can call this function
    /// @param _boxId id of the box
    /// @param _to Address of user receive nft
    /// @param _tokenType Type of nft to mint
    function mintFromBox(
        uint256 _boxId,
        address _to,
        uint8 _tokenType
    ) external onlyFromBoxCampaign {
        // Check token type is exist in this campaign
        require(isNFTTypeExist(_tokenType), "Token type does not exist");

        uint256 _id = idCounters.current();
        idCounters.increment();
        _safeMint(_to, _id);

        // save token information to contract
        holders[_to].push(_id);
        fromBoxId[_id] = _boxId;

        emit TokenCreated(_to, _boxId, _id, _tokenType);
    }

    // GETTERS
    /// @notice Check if NFT type is exist in this campaign
    /// @param _nftType nft type need to check if it exist in this box campaign
    /// @return A boolean indicate nft is exist
    function isNFTTypeExist(uint8 _nftType) private view returns (bool) {
        for (uint i = 0; i < nftTypes.length; i++) {
            if (nftTypes[i] == _nftType) {
                return true;
            }
        }
        return false;
    }
}
