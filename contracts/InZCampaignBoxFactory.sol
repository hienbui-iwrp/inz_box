// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./InZBoxCampaign.sol";

contract InZCampaignBoxFactory is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     *          Constant
     */
    uint8 internal constant STANDARD_ID_ERC721 = 1;
    uint8 internal constant STANDARD_ID_ERC1155 = 2;

    event NewBox(
        address newBoxAddress,
        string uri,
        address payToken,
        string name,
        string symbol,
        uint256 startTime,
        uint256 endTime,
        bool isAutoIncreaseId,
        uint256 totalSupply,
        uint256 price
    );

    event SetConfiguration(address newConfiguration);

    /**
     *          Storage data declarations
     */
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address[] public inZBoxCampaignsAddress;

    // implementation of BOX
    address public boxImplementationAddress;

    // Wrapper Creator address: using for calling from dapp
    address public dappCreatorAddress;

    /**
     *          Contructor of the contract
     */
    constructor() {
        boxImplementationAddress = address(new InZBoxCampaign());

        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     *  @notice Clone instance of Mystery Box
     * @param _boxUri   uri of box campaign
     * @param _payToken     token used for buying box
     * @param _symbol   symbol of this campaign
     * @param _name     name of this campaign
     * @param _startTime    start time to buy box
     * @param _endTime  end time to buy box
     * @param _isAutoIncreaseId is creator want box id auto increase
     * @param _totalSupply  total supply of this box campaign
     * @param _price    price of each box in campaign
     * @param _nftType  the nft type can be opened in box
     */
    function createBox(
        string memory _boxUri,
        IERC20 _payToken,
        string memory _name,
        string memory _symbol,
        uint256 _startTime,
        uint256 _endTime,
        bool _isAutoIncreaseId,
        uint256 _totalSupply,
        uint256 _price,
        uint8[] memory _nftType
    ) external onlyRole(ADMIN_ROLE) {
        address clone = Clones.clone(boxImplementationAddress);
        InZBoxCampaign(clone).initialize(
            _boxUri,
            _payToken,
            _name,
            _symbol,
            _startTime,
            _endTime,
            _isAutoIncreaseId,
            _totalSupply,
            _price,
            _nftType
        );
        inZBoxCampaignsAddress.push(address(clone));
        emit NewBox(
            address(clone),
            _boxUri,
            address(_payToken),
            _name,
            _symbol,
            _startTime,
            _endTime,
            _isAutoIncreaseId,
            _totalSupply,
            _price
        );
    }
}
