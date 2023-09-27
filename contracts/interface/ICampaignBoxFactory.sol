pragma solidity ^0.8.0;

interface ICampaignBoxFactory {
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
    ) external;
}
