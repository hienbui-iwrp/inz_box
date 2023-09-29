pragma solidity ^0.8.9;

interface IBoxCampaign {
    struct Proof {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    /// @notice buy a box
    /// @dev mint a NFT box to an address
    function mintBox(Proof memory _proof) external payable;

    /// @notice open a box bought
    /// @dev mint a NFT item when open a box
    /// @param _boxId token id of minted box
    function openBox(uint256 _boxId) external;
}
