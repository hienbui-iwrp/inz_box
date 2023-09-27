// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICampaignBoxFactory {
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
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
    /// @param _nftTypes list type available of NFT items
    /// @param _amountOfEachNFTType supply for each NFT type follow to _nftTypes
    function createBox(
        address _campaignTypeNFT721,
        string memory _tokenUri,
        IERC20 _payToken,
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _endTime,
        bool _isAutoIncreaseId,
        uint256 _price,
        address _feeAddress,
        uint8[] memory _nftTypes,
        uint256[] memory _amountOfEachNFTType
    ) external;
}
