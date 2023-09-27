// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IBoxItemCampaignNFT721 {
    function mintFromBox(
        uint256 _boxId,
        address _to,
        uint8 _tokenType
    ) external;
}
