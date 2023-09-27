pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ICampaignTypeNFT721.sol";

contract InzCampaignTypesNFT721 is ERC721Upgradeable, ICampaignTypeNFT721 {
    // address of box campaign
    address private boxCampaign;

    // all types of campaign
    uint8[] private types;

    // uri by type
    mapping(uint8 => string) private typeToUri;

    // owner of token Id
    mapping(uint256 => address) private nftOwner;

    // token id is is opened by which box id (token id => box id)
    mapping(uint256 => uint256) private fromBoxId;

    // list token id of each wallet
    mapping(address => uint256[]) private tokensOfOwner;

    Counters.Counter private idCounters;

    function mintFromBox() external {}
}
