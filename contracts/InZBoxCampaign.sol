pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interface/ICampaignTypeNFT1155.sol";
import "./interface/IBoxCampaign.sol";

contract BoxCollection is IBoxCampaign, ERC1155 {
    event MintBox(address buyer, uint256 boxId);
    event OpenBox(uint256 tokenId);

    // collection mint items
    ICampaignTypeNFT1155 itemCollection;

    Counters.Counter idCounter;

    // Signer for mint with signature
    address public signer;

    // current supply
    uint256 supply;

    // list types
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
        itemCollection = ICampaignTypeNFT1155(_itemCollection);
        idCounter._value = 0;

        types = _types;
        for (uint i = 0; i < _types.length; i++) {
            typeSuplies[_types[i]] = _supply[i];
        }
    }

    function updateNftCollection(address _itemCollection) public {
        itemCollection = ICampaignTypeNFT1155(_itemCollection);
    }

    function updateSupply(
        uint8[] memory _types,
        uint256[] memory _supply
    ) public {
        require(
            _types.length == _supply.length,
            "don't provide enought supply for each type"
        );

        types = _types;
        for (uint i = 0; i < _types.length; i++) {
            typeSuplies[_types[i]] = _supply[i];
        }
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

        uint8 typeMint = randomType();
        itemCollection.mintNFT(boxOwner[boxId], typeMint);
        typeSuplies[typeMint]--;

        boxOpened[boxId] = true;

        emit OpenBox(boxId);
    }

    function getCurrentBoxId() public view returns (uint256) {
        return Counters.current(idCounter);
    }

    function randomType() internal view returns (uint8) {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(msg.sender, block.timestamp, block.number)
            )
        );
        rand = rand % getTotalSupply();

        uint256 current = 0;
        for (uint8 i = 0; i < types.length; i++) {
            current += typeSuplies[types[i]];
            if (rand < current) {
                return types[i];
            }
        }

        return types[0];
    }

    function getTotalSupply() internal view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < types.length; i++) {
            total += typeSuplies[types[i]];
        }
        return total;
    }
}
