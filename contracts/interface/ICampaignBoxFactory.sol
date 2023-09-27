// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICampaignBoxFactory {
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
