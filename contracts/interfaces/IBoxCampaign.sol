// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBoxCampaign {
    /// @notice Mint a mystery box to the user
    /// @dev Mint directly to whoever call this contract
    function mintBox() external;

    /// @notice Mint a mystery box to the user with id specified by the user
    /// @dev Mint directly to whoever call this contract
    /// @param _tokenId ID of the box that will be minted
    function mintBoxWithSpecifiedID(uint256 _tokenId) external;

    function openBox(uint256 boxId) external;
}
