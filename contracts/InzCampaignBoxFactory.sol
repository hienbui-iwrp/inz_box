pragma solidity ^0.8.0;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import "./interface/ICampaignBoxFactory.sol";
import "./InzBoxCampaign.sol";

contract InzCampaignBoxFactory is ICampaignBoxFactory {
    event CreateCampaign(
        address _itemCollection,
        uint8[] _types,
        uint256[] _supply,
        address _signer
    );
    // implementation of BOX
    address public boxImplementationAddress;

    constructor(address _boxImplementationAddress) {
        boxImplementationAddress = _boxImplementationAddress;
    }

    function createCampaign(
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
    ) external {
        address clone = Clones.clone(boxImplementationAddress);

        InzBoxCampaign(clone).initialize(
            _uri,
            _payToken,
            _name,
            _symbol,
            _signer,
            _startTimeToBuy,
            _endTimeToBuy,
            _price,
            _itemCollection,
            _feeAddress,
            _types,
            _supply
        );

        emit CreateCampaign(_itemCollection, _types, _supply, _signer);
    }
}
