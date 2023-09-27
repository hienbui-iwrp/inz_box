pragma solidity ^0.8.9;

interface IBoxCampaign {
    struct Proof {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// @notice buy a box
    /// @dev mint a NFT box to an address
    /// @param _tokenId token id need to mint when auto increase if off
    function mintBox(uint256 _tokenId) external payable;

    /// @notice open a box bought
    /// @dev mint a NFT item when open a box
    /// @param _boxId token id of minted box
    function openBox(uint256 _boxId) external;
}
