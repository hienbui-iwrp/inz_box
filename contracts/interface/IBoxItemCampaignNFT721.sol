// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IBoxItemCampaignNFT721 {
    /// @notice Mint nft from box
    /// @dev Only box campaign can call this function
    /// @param _to Address of user receive nft
    /// @param _tokenType Type of nft to mint
    function mintFromBox(address _to, uint8 _tokenType) external;
}
