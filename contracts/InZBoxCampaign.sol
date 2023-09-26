pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interface/ICampaignTypeNFT1155.sol";
import "./interface/IBoxCampaign.sol";

contract BoxCampaign is IBoxCampaign, ERC1155 {
    event MintBox(address buyer, uint256 boxId);
    event OpenBox(uint256 tokenId);
    event SetCampaignAddress(address _old, address _new);
    event SetSigner(address _old, address _new);

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
        uint256[] memory _supply,
        address _signer
    ) public ERC1155("Box Nothing") {
        require(
            _types.length == _supply.length,
            "don't provide enought supply for each type"
        );
        itemCollection = ICampaignTypeNFT1155(_itemCollection);
        signer = _signer;
        idCounter._value = 0;

        types = _types;
        supply = 0;
        for (uint i = 0; i < _types.length; i++) {
            supply += _supply[i];
            typeSuplies[_types[i]] = _supply[i];
        }
    }

    function setNftCollection(address _itemCollection) public {
        address oldAddress = address(itemCollection);
        itemCollection = ICampaignTypeNFT1155(_itemCollection);
        emit SetCampaignAddress(oldAddress, _itemCollection);
    }

    function setSigner(address _signer) public {
        address oldAddress = signer;
        signer = _signer;
        emit SetSigner(oldAddress, _signer);
    }

    // function setSupply(uint8[] memory _types, uint256[] memory _supply) public {
    //     require(
    //         _types.length == _supply.length,
    //         "don't provide enought supply for each type"
    //     );

    //     types = _types;
    //     for (uint i = 0; i < _types.length; i++) {
    //         typeSuplies[_types[i]] = _supply[i];
    //     }
    // }

    function mintBox(address _to, Proof memory _proof) external {
        // require(verifySignature(_to, _proof), "Wrong signer");
        require(supply > 0, "Box is out of stock");
        uint256 id = Counters.current(idCounter);
        _mint(_to, id, 1, "");

        boxOpened[id] = false;
        boxOwner[id] = _to;
        supply--;
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

    function verifySignature(
        address _to,
        Proof memory _proof
    ) public view returns (bool) {
        if (signer == address(0x0)) {
            return true;
        }

        bytes32 digest = keccak256(abi.encode(signer, _to));
        address signatory = ecrecover(digest, _proof.v, _proof.r, _proof.s);
        return signatory == signer;
    }

    function getSigner(
        address _to,
        Proof memory _proof
    ) public view returns (address, address) {
        bytes32 digest = keccak256(abi.encode(_to));
        address signatory = ecrecover(digest, _proof.v, _proof.r, _proof.s);
        return (signatory, signer);
    }

    function getMessage(
        address _to,
        Proof memory _proof
    ) public view returns (bytes32) {
        bytes32 digest = keccak256(abi.encode(_to));
        // address signatory = ecrecover(digest, _proof.v, _proof.r, _proof.s);
        return digest;
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
