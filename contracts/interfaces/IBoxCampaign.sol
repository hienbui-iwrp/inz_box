// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBoxCampaign {
    function mintBox(address _to) external;

    function openBox(address to, uint256 boxId) external;
}
