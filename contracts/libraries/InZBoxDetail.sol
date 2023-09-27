// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./InZNFTTypeDetail.sol";

interface InZBoxTypeDetail {
    struct BoxTypeDetail {
        string boxType; // type of the box E.g: common, rare,...
        uint256 totalSupply; // total supply of this box type
        uint256[] nftTypeDetails; // a box can have 1 or more nft type that can be opened (maximum item open from box is 1)
    }
}
