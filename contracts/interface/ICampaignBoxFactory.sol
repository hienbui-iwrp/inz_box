// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICampaignBoxFactory {
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
    ) external;

    /// @notice update type and amount for each type
    /// @param _nftTypes list type available of NFT items
    /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
    /// @param _boxCampaign address of box campaign own
    function configTypeInCampaign(
        uint8[] memory _nftTypes,
        uint256[] memory _amountOfEachNFTType,
        address _boxCampaign
    ) external;
}
