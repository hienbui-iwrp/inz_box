pragma solidity ^0.8.9;

interface IBoxCampaign {
    struct Proof {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function mintBox() external payable;

    function openBox() external;
}
