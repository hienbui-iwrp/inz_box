pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IERC1155Collection {
    function mintNFT(address _to, uint8 _type) external;
}

contract ERC1155RandomCollection is ERC1155, IERC1155Collection {
    event MintNFT(address _to, uint256 tokenId, uint8 _type);

    address boxAddress;

    Counters.Counter idCounter;

    uint8[] types;

    // type => uri
    mapping(uint8 => string) typeUri;

    // ntf id => type
    mapping(uint256 => uint8) nftTypes;

    // ntf id => uri
    mapping(uint256 => string) nftUris;

    modifier fromBox() {
        require(msg.sender == boxAddress, "caller is not box");
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

    function updateBox(address box) external {
        boxAddress = box;
    }

    function mintNFT(address _to, uint8 _type) external {
        uint256 id = Counters.current(idCounter);

        _mint(_to, id, 1, "");

        nftTypes[id] = _type;
        nftUris[id] = typeUri[_type];

        Counters.increment(idCounter);

        emit MintNFT(_to, id, _type);
    }

    function getNftType(uint256 id) public view returns (uint8) {
        return nftTypes[id];
    }

    function getCurrentId() public view returns (uint256) {
        return Counters.current(idCounter);
    }
}
