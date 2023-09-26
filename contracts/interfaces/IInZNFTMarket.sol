// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IInZNFTMarket {
    function getMarketFeePercent(address) external view returns (uint16);
}
