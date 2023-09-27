// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interface/ICampaignBoxFactory.sol";
import "./InZBoxCampaign.sol";

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

    event ConfigBoxCampaign(
        address boxAddress,
        uint8[] nftTypes,
        uint256[] amountOfEachNFTType
    );
    // address of the contract implement box logic
    address private boxImplementation;
    // box campaign have been cloned by factory
    address[] private boxCampaigns;

    constructor(address _boxImplementation) {
        boxImplementation = _boxImplementation;
    }

    // /// @notice Explain to an end user what this does
    // /// @dev Explain to a developer any extra details
    // /// @param _campaignTypeNFT721 address of items collection
    // /// @param _tokenUri uri of NFT box
    // /// @param _payToken currency of transaction
    // /// @param _name name of NFT box
    // /// @param _symbol symbol of NFT box
    // /// @param _startTime start time of campaign can make mint
    // /// @param _endTime end time of campaign can make mint
    // /// @param _isAutoIncreaseId is creator want box id auto increase
    // /// @param _price price of each mint acton
    // /// @param _feeAddress address received fee pay to mint
    // /// @param _nftTypes list type available of NFT items
    // /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
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

    function configBoxCampaign(
        address _boxCampaign,
        uint8[] memory _nftTypes,
        uint256[] memory _amountOfEachNFTType
    ) public {
        InZBoxCampaign(_boxCampaign).initializeAmountForEachType(
            _nftTypes,
            _amountOfEachNFTType
        );
        emit ConfigBoxCampaign(
            address(_boxCampaign),
            _nftTypes,
            _amountOfEachNFTType
        );
    }
}
