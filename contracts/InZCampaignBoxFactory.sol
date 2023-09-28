// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interface/ICampaignBoxFactory.sol";
import "./InZBoxCampaign.sol";
import "./InZBoxItemCampaignNFT721.sol";

contract InZCampaignBoxFactory {
    // EVENT
    event NewBox(
        address newBoxAddress,
        string uri,
        address payToken,
        string name,
        string symbol,
        uint256 startTime,
        uint256 endTime,
        bool isAutoIncreaseId,
        uint256 price,
        address feeAddress
    );

    event CreateBoxItemCampaign(
        string name,
        string symbol,
        address boxAddress,
        uint8[] nftTypes,
        string[] uri,
        uint256[] amountOfEachNFTType,
        address boxItemAddress
    );

    // address of the contract implement box logic
    address private boxImplementation;
    // box campaign have been cloned by factory
    address[] private boxCampaigns;

    // address of the contract implement box item collection
    address private boxItemImplementation;

    // address box item of each box campaign
    mapping(address => address) boxItemAddress;

    constructor(address _boxImplementation, address _boxItemImplementation) {
        boxImplementation = _boxImplementation;
        boxItemImplementation = _boxItemImplementation;
    }

    /// @notice Create new box campaign
    /// @param _campaignTypeNFT721 address of items collection
    /// @param _tokenUri uri of NFT box
    /// @param _payToken currency of transaction
    /// @param _name name of NFT box
    /// @param _symbol symbol of NFT box
    /// @param _startTime start time of campaign can make mint
    /// @param _endTime end time of campaign can make mint
    /// @param _isAutoIncreaseId is creator want box id auto increase
    /// @param _price price of each mint acton
    /// @param _feeAddress address received fee pay to mint
    function createBox(
        address _campaignTypeNFT721,
        string memory _tokenUri,
        address _payToken,
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _endTime,
        bool _isAutoIncreaseId,
        uint256 _price,
        address _feeAddress
    ) external returns (address) {
        address clone = Clones.clone(boxImplementation);
        InZBoxCampaign(clone).initialize(
            _campaignTypeNFT721,
            _tokenUri,
            _payToken,
            _name,
            _symbol,
            _startTime,
            _endTime,
            _isAutoIncreaseId,
            _price,
            _feeAddress
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
            _isAutoIncreaseId,
            _price,
            _feeAddress
        );
        return address(clone);
    }

    /// @notice create new Box item campaign
    /// @param _name name of NFT box
    /// @param _symbol symbol of NFT box
    /// @param _nftTypes list type available of NFT items
    /// @param _uri uri for each type
    /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
    /// @param _boxCampaign address of box campaign own
    function createBoxItem(
        string memory _name,
        string memory _symbol,
        uint8[] memory _nftTypes,
        string[] memory _uri,
        uint256[] memory _amountOfEachNFTType,
        address _boxCampaign
    ) external returns (address) {
        address clone = Clones.clone(boxItemImplementation);
        InZBoxItemCampaignNFT721(clone).initialize(
            _name,
            _symbol,
            _nftTypes,
            _uri,
            _boxCampaign
        );

        InZBoxCampaign(_boxCampaign).initializeAmountForEachType(
            _nftTypes,
            _amountOfEachNFTType
        );
        boxItemAddress[_boxCampaign] = clone;
        emit CreateBoxItemCampaign(
            _name,
            _symbol,
            _boxCampaign,
            _nftTypes,
            _uri,
            _amountOfEachNFTType,
            clone
        );
        return address(clone);
    }

    /// @notice get all address of box campaign created
    function getListBoxCampaign() public view returns (address[] memory) {
        return boxCampaigns;
    }

    /// @notice get address of box item campaign by box campaign
    /// @param _boxCampaign address of box campaign own
    function getBoxItemCampaign(
        address _boxCampaign
    ) public view returns (address) {
        return boxItemAddress[_boxCampaign];
    }
}
