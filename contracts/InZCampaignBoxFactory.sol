// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interface/ICampaignBoxFactory.sol";

contract InZCampaignBoxFactory is ICampaignBoxFactory {
    // address of the contract implement box logic
    address private boxImplementation;
    // box campaign have been cloned by factory
    address[] private boxCampaigns;

    function createCampaign() external {}
}
