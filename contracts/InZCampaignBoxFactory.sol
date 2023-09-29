// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interface/ICampaignBoxFactory.sol";
import "./InZBoxCampaign.sol";
import "./InZBoxItemCampaignNFT721.sol";

contract InZCampaignBoxFactory is ICampaignBoxFactory, AccessControl {
    ///
    ///         Event Definitions
    ///

    /// @param newBoxAddress Address of new box campaign created
    /// @param uri uri of new box campaign
    /// @param payToken paytoken use for minting
    /// @param name name of new box campaign
    /// @param symbol symbol of new box campaign
    /// @param startTime start time can mint
    /// @param endTime end time can mint
    /// @param price price used for minting
    /// @param feeAddress wallet receive platform fee
    event NewBox(
        address newBoxAddress,
        string uri,
        address payToken,
        string name,
        string symbol,
        uint256 startTime,
        uint256 endTime,
        uint256 price,
        address feeAddress
    );

    /// @param boxAddress Address of box configurated
    /// @param nftTypes list valid type of item
    /// @param amountOfEachNFTType supply of each type
    event SetSupplyEachType(
        address boxAddress,
        uint8[] nftTypes,
        uint256[] amountOfEachNFTType
    );

    /**
     *          Storage data declarations
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // address of the contract implement box logic
    address private boxImplementation;
    // box campaign have been cloned by factory
    address[] private boxCampaigns;

    constructor(address _boxImplementation) {
        boxImplementation = _boxImplementation;

        _setupRole(ADMIN_ROLE, tx.origin);
        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
    }

    /// @notice Create new box campaign
    /// @param _itemCampaign _itemCampaign
    /// @param _tokenUri uri of NFT box
    /// @param _payToken currency of transaction
    /// @param _name name of NFT box
    /// @param _symbol symbol of NFT box
    /// @param _startTime start time of campaign can make mint
    /// @param _endTime end time of campaign can make mint
    /// @param _price price of each mint acton
    /// @param _feeAddress address received fee pay to mint
    function createBox(
        address _itemCampaign,
        string memory _tokenUri,
        address _payToken,
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price,
        address _feeAddress
    ) external onlyRole(ADMIN_ROLE) {
        address clone = Clones.clone(boxImplementation);
        InZBoxCampaign(clone).initialize(
            _itemCampaign,
            _tokenUri,
            _payToken,
            _name,
            _symbol,
            _startTime,
            _endTime,
            _price,
            _feeAddress,
            msg.sender
        );

        boxCampaigns.push(address(clone));
        emit NewBox(
            address(clone),
            _tokenUri,
            address(_payToken),
            _name,
            _symbol,
            _startTime,
            _endTime,
            _price,
            _feeAddress
        );
    }

    /// @notice create new Box item campaign
    /// @param _nftTypes list type available of NFT items
    /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
    /// @param _boxCampaign address of box campaign own
    function configTypeInCampaign(
        uint8[] memory _nftTypes,
        uint256[] memory _amountOfEachNFTType,
        address _boxCampaign
    ) external onlyRole(ADMIN_ROLE) {
        InZBoxCampaign(_boxCampaign).setAmountForEachType(
            _nftTypes,
            _amountOfEachNFTType
        );

        emit SetSupplyEachType(_boxCampaign, _nftTypes, _amountOfEachNFTType);
    }

    /// @notice get all address of box campaign created
    function getListBoxCampaign() public view returns (address[] memory) {
        return boxCampaigns;
    }
}
