pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/ICampaignTypeNFT1155.sol";
import "./interface/IBoxCampaign.sol";

contract InzBoxCampaign is
    IBoxCampaign,
    ERC721Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    event MintBox(address buyer, uint256 boxId);
    event OpenBox(uint256 tokenId);
    event SetItemsCollection(address _old, address _new);
    event SetSigner(address _old, address _new);

    ///
    ///             STORAGE DATA DECLARATIONS
    ///
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant DESIGNER_ROLE = keccak256("DESIGNER_ROLE");
    bytes32 internal constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    // collection mint items
    address itemCollection;

    // Signer for mint with signature
    address signer;

    // address receive fee
    address feeAddress;

    Counters.Counter idCounter;

    // Pay Token for minting action
    IERC20 payToken;

    // tokenURI of box
    string tokenUri;

    // current supply
    uint256 boxSupply;

    // price mint
    uint256 price;

    // list types
    uint8[] types;

    // type => supply number
    mapping(uint8 => uint256) typeSuplies;

    // box id => opened or not
    mapping(uint256 => bool) boxOpened;

    // box id => owner address
    mapping(uint256 => address) boxOwner;

    // Duration of the campaign
    uint256 private startTimeToBuy;
    uint256 private endTimeToBuy;

    constructor() {}

    function initialize(
        string memory _uri,
        address _payToken,
        string memory _name,
        string memory _symbol,
        address _signer,
        uint256 _startTimeToBuy,
        uint256 _endTimeToBuy,
        uint256 _price,
        address _itemCollection,
        address _feeAddress,
        uint8[] memory _types,
        uint256[] memory _supply
    ) public {
        require(
            _types.length == _supply.length,
            "don't provide enought supply for each type"
        );

        tokenUri = _uri;
        payToken = IERC20(_payToken);

        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _transferOwnership(tx.origin);
        idCounter._value = 0;
        signer = _signer;
        startTimeToBuy = _startTimeToBuy;
        endTimeToBuy = _endTimeToBuy;
        price = _price;

        itemCollection = _itemCollection;
        feeAddress = _feeAddress;

        types = _types;
        boxSupply = 0;
        for (uint i = 0; i < _types.length; i++) {
            boxSupply += _supply[i];
            typeSuplies[_types[i]] = _supply[i];
        }

        _setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
        _setupRole(ADMIN_ROLE, tx.origin);
        _setupRole(DESIGNER_ROLE, tx.origin);
        _setupRole(WITHDRAW_ROLE, tx.origin);
    }

    function setItemsCollection(address _itemCollection) public {
        address oldAddress = address(itemCollection);
        itemCollection = _itemCollection;
        emit SetItemsCollection(oldAddress, _itemCollection);
    }

    function setSigner(address _signer) public {
        address oldAddress = signer;
        signer = _signer;
        emit SetSigner(oldAddress, _signer);
    }

    function mintBox(
        address _to,
        uint256 _price,
        Proof memory _proof
    ) external payable {
        // require(verifySignature(_to, _proof), "Wrong signer");
        require(boxSupply > 0, "Box is out of stock");

        if (address(payToken) == address(0x0)) {
            require(_price <= msg.value, "Not enough native coin");
            payable(feeAddress).transfer(_price);
        } else {
            payToken.transferFrom(msg.sender, feeAddress, _price);
        }
        uint256 id = Counters.current(idCounter);
        _mint(_to, id);

        boxOpened[id] = false;
        boxOwner[id] = _to;
        boxSupply--;
        Counters.increment(idCounter);

        emit MintBox(_to, id);
    }

    function openBox(uint256 boxId) external {
        require(boxOpened[boxId] == false, "Box have already been opened");

        uint8 typeMint = randomType();
        ICampaignTypeNFT1155(itemCollection).mintNFT(boxOwner[boxId], typeMint);
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

    function withdrawAll() external payable {
        payable(feeAddress).transfer(address(this).balance);
    }

    ///
    ///          INHERITANCE FUNCTIONS
    ///
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(ADMIN_ROLE) {}

    function getTotalSupply() internal view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < types.length; i++) {
            total += typeSuplies[types[i]];
        }
        return total;
    }
}
