pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./ERC1155RandomCollection.sol";

interface IBoxCollection {
    function mintBox(address _to) external;

    function openBox(uint256 boxId) external;
}

contract BoxCollection is IBoxCollection, ERC1155 {
    event MintBox(address buyer, uint256 boxId);
    event OpenBox(uint256 tokenId);

    IERC1155Collection itemCollection;

    Counters.Counter idCounter;

    // current supply
    uint256 supply;

    uint8[] types;

    // type => supply number
    mapping(uint8 => uint256) typeSuplies;

    // box id => opened or not
    mapping(uint256 => bool) boxOpened;

    // box id => owner address
    mapping(uint256 => address) boxOwner;

    constructor(
        address _itemCollection,
        uint8[] memory _types,
        uint256[] memory _supply
    ) public ERC1155("Box Nothing") {
        require(
            _types.length == _supply.length,
            "don't provide enought supply for each type"
        );
        itemCollection = IERC1155Collection(_itemCollection);
        idCounter._value = 0;

        types = _types;
        for (uint i = 0; i < _types.length; i++) {
            typeSuplies[_types[i]] = _supply[i];
        }
    }

    function updateNftCollection(address _itemCollection) public {
        itemCollection = IERC1155Collection(_itemCollection);
    }

    function mintBox(address _to) external {
        uint256 id = Counters.current(idCounter);
        _mint(_to, id, 1, "");

        boxOpened[id] = false;
        boxOwner[id] = _to;

        Counters.increment(idCounter);

        emit MintBox(_to, id);
    }

    function openBox(uint256 boxId) external {
        require(boxOpened[boxId] == false, "Box have already been opened");

        uint8 typeMint = getNFTType();
        itemCollection.mintNFT(boxOwner[boxId], typeMint);
        typeSuplies[typeMint]--;

        boxOpened[boxId] = true;

        emit OpenBox(boxId);
    }

    function getCurrentBoxId() public view returns (uint256) {
        return Counters.current(idCounter);
    }

    function getBoxOwner(uint256 id) public view returns (address) {
        return boxOwner[id];
    }

    function getNFTType() public view returns (uint8) {
        uint256 rand = genRandomNumber() % getTotalSupply();
        uint256 current = 0;
        for (uint8 i = 0; i < types.length; i++) {
            current += typeSuplies[types[i]];
            if (rand < current) {
                return types[i];
            }
        }

        return types[0];
    }

    function getTotalSupply() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < types.length; i++) {
            total += typeSuplies[types[i]];
        }
        return total;
    }

    function genRandomNumber() public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(msg.sender, block.timestamp, block.number)
                )
            );
    }
}
