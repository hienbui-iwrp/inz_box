// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interface/IBoxItemCampaignNFT721.sol";

contract InZBoxItemCampaignNFT721 is
    ERC721Upgradeable,
    IBoxItemCampaignNFT721,
    AccessControlUpgradeable
{
    using Counters for Counters.Counter;
    ///
    ///         EVENT DEFINITION
    ///

    /// @param _to Owner of box NFT
    /// @param _tokenId token id of box
    /// @param _tokenType token id of box
    event MintFromBox(address _to, uint256 _tokenId, uint8 _tokenType);

    ///
    ///             STORAGE DATA DECLARATIONS
    ///

    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // LOCAL VARIABLE
    // Address of box campaign
    address private boxCampaign;

    // All types of campaign
    uint8[] private nftTypes;

    // Uri by type, each type corresponding to uri
    mapping(uint8 => string) private typeToUri;

    // Mapping token's holder address to tokenIds list
    mapping(address => uint256[]) private holders;

    Counters.Counter private idCounters;

    // MODIFIERS

    modifier onlyFromBoxCampaign() {
        require(boxCampaign == msg.sender, "Must be called in box campaign");
        _;
    }

    /// @notice initialize
    /// @dev initialize
    /// @param _name Name of NFT
    /// @param _symbol Symbol of NFT
    /// @param _nftTypes List type of nft to mint
    /// @param _uri Uri of each type
    /// @param _boxCampaign Address of box campaign can mint
    function initialize(
        string memory _name,
        string memory _symbol,
        uint8[] memory _nftTypes,
        string[] memory _uri,
        address _boxCampaign
    ) public initializer {
        require(
            _nftTypes.length == _uri.length,
            "NFT type and uri are not match"
        );

        __ERC721_init(_name, _symbol);

        nftTypes = _nftTypes;

        // init uri by type
        for (uint i = 0; i < nftTypes.length; i++) {
            typeToUri[_nftTypes[i]] = _uri[i];
        }

        boxCampaign = _boxCampaign;

        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(ADMIN_ROLE, tx.origin);
    }

    /// @notice Update new address box campaign can mint
    /// @param _boxCampaign address new box campaign
    function setBoxCampaign(address _boxCampaign) public onlyRole(ADMIN_ROLE) {
        boxCampaign = _boxCampaign;
    }

    /// @notice Mint nft from box
    /// @dev Only box campaign can call this function
    /// @param _to Address of user receive nft
    /// @param _tokenType Type of nft to mint
    function mintFromBox(
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

        emit MintFromBox(_to, _id, _tokenType);
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

    /// @notice Get current box campaign
    /// @return address of current campaign
    function getBoxCampaign() public view returns (address) {
        return boxCampaign;
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
