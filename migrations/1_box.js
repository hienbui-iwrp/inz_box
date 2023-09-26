const console = require("console");
const fs = require("fs");

// command line run: truffle migrate --f 1 --to 1 --network base_goerli -reset --compile-none

var BoxCampaign = artifacts.require("BoxCampaign");
var InzCampaignTypesNFT1155 = artifacts.require("InzCampaignTypesNFT1155");

function wf(name, address) {
    fs.appendFileSync("_address.txt", name + "=" + address);
    fs.appendFileSync("_address.txt", "\r\n");
}

const deployments = {
    inzCampaignTypesNFT1155: true,
    boxCampaign: true,
    configItemCampaign: true,
};

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("deployer = ", account);
    require("dotenv").config();
    var _devWallet = process.env.DEV_WALLET;

    var types = [1, 2, 3, 4, 5]
    var uri = ["/1", "/2", "/3", "/4", "/5"]
    var nullAddress = "0x0000000000000000000000000000000000000000"
    var supplies = [5, 4, 3, 2, 1]

    /**
     *      0.1.    Deploy ERC1155RandomCollection
     */
    if (deployments.inzCampaignTypesNFT1155) {
        await deployer.deploy(InzCampaignTypesNFT1155, nullAddress, types, uri);
        var _inzCampaignTypesNFT1155 = await InzCampaignTypesNFT1155.deployed();
        wf("ERC1155RandomCollection", _inzCampaignTypesNFT1155.address);
    } else {
        var _inzCampaignTypesNFT1155 = await InzCampaignTypesNFT1155.at(
            process.env.ERC1155RandomCollection
        );
    }

    /**
     *      0.2.    Deploy BoxCollection
     */
    if (deployments.boxCampaign) {
        await deployer.deploy(BoxCampaign, _inzCampaignTypesNFT1155.address, types, supplies,
            process.env.SIGNER);
        var _boxCampaign = await BoxCampaign.deployed();
        wf("BoxCollection", _boxCampaign.address);
    } else {
        var _boxCampaign = await BoxCampaign.at(process.env.BoxCollection);
    }

    /**
    *      0.3.    config Item Collection
    */
    if (deployments.configItemCampaign) {
        await _inzCampaignTypesNFT1155.setBoxAddress(_boxCampaign.address)
        console.log("update box address succesfully")
    }
}