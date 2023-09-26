// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTOpeningItem {
    function mintFromBoxOpening(address to, uint8 tokenType) external;
}
