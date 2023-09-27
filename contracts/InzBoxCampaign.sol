// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interface/ICampaignTypeNFT721.sol";

contract InzBoxCampaign {
    ///
    ///             EXTERNAL USING
    ///
    using Counters for Counters.Counter;
    // Address will receive fee from mint
    address private feeAddress;
    IERC20 payToken;
    // tokenURI of box
    string private tokenUri;
    // Counter for tokenId
    Counters.Counter internal tokenIdCounter;

    // address of campaign type nft 721 to use its function
    address private campaignTypeNFT721;

    // map box id to bool
    mapping(uint256 => bool) private isOpened;
    // owner has how many box
    mapping(address => uint256[]) private boxOwners;
    // nft type can be opened from box
    uint8[] private nftTypes;
    // amount nft can be opened of each type
    mapping(uint8 => uint256) private amountOfEachType;
    // total supply of this box campaign
    uint256 private totalSupply;
    // total box have minted
    uint256 private totalMinted;
    // price of each box
    uint256 private price;

    // Duration of the campaign
    uint256 private campaignStartTime;
    uint256 private campaignEndTime;
}
