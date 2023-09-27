pragma solidity ^0.8.9;

import "./interface/ICampaignBoxFactory.sol";

contract InzCampaignBoxFactory is ICampaignBoxFactory {
    // address of box campaign
    address private boxCampaignImplement;

    // all types of campaign
    address[] private boxCampaignInstances;

    function createCampaign() external {}
}
