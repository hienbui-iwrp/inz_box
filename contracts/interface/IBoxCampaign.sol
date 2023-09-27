pragma solidity ^0.8.0;

interface IBoxCampaign {
    struct Proof {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function mintBox(
        address _to,
        uint256 price,
        Proof memory _proof
    ) external payable;

    function openBox(uint256 boxId) external;
}
