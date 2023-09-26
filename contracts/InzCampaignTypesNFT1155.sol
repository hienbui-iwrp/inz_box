pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interface/ICampaignTypeNFT1155.sol";

contract InzCampaignTypesNFT1155 is ERC1155, ICampaignTypeNFT1155 {
    event MintItem(address _to, uint256 tokenId, uint8 _type);
    event SetBoxAddress(address _old, address _new);

    // address of box campaign
    address boxAddress;

    Counters.Counter idCounter;

    // list nft types
    uint8[] types;

    // nft type => uri
    mapping(uint8 => string) typeUri;

    // ntf id => type
    mapping(uint256 => uint8) nftTypes;

    // ntf id => uri
    mapping(uint256 => string) nftUris;

    modifier fromBox() {
        require(msg.sender == boxAddress, "Caller is not box");
        _;
    }

    constructor(
        address _boxCollection,
        uint8[] memory _types,
        string[] memory _uri
    ) ERC1155("ERC1155 Nothing") {
        require(
            _types.length == _uri.length,
            "don't provide enought uri for each type"
        );

        boxAddress = _boxCollection;

        types = _types;
        for (uint i = 0; i < _types.length; i++) {
            typeUri[_types[i]] = _uri[i];
        }

        Counters.reset(idCounter);
    }

    function setBoxAddress(address box) external {
        address oldAddress = boxAddress;
        boxAddress = box;
        emit SetBoxAddress(oldAddress, box);
    }

    function mintNFT(address _to, uint8 _type) external fromBox {
        uint256 id = Counters.current(idCounter);

        _mint(_to, id, 1, "");

        nftTypes[id] = _type;
        nftUris[id] = typeUri[_type];
        Counters.increment(idCounter);

        emit MintItem(_to, id, _type);
    }

    function getNftType(uint256 id) public view returns (uint8) {
        return nftTypes[id];
    }

    function getNextId() public view returns (uint256) {
        return Counters.current(idCounter);
    }
}
