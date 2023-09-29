const console = require("console");
const fs = require("fs");

// command line run: truffle migrate --f 1 --to 1 --network base_goerli -reset --compile-none

var InZBoxCampaign = artifacts.require("InZBoxCampaign");
var InZBoxItemCampaignNFT721 = artifacts.require("InZBoxItemCampaignNFT721");
var InZCampaignBoxFactory = artifacts.require("InZCampaignBoxFactory");

function wf(name, address) {
    fs.appendFileSync("_address.txt", name + "=" + address);
    fs.appendFileSync("_address.txt", "\r\n");
}

const deployments = {
    boxItemCampaignNFT721: false,
    boxCampaign: true,
    campaignBoxFactory: true,
};

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("deployer = ", account);
    require("dotenv").config();
    var _devWallet = process.env.DEV_WALLET;

    var types = [1, 2, 3, 4, 5]
    var uri = ["/1", "/2", "/3", "/4", "/5"]
    var nullAddress = "0x0000000000000000000000000000000000000000"

    /**
     *      0.1.    Deploy InZBoxItemCampaignNFT721
     */
    if (deployments.boxItemCampaignNFT721) {
        await deployer.deploy(InZBoxItemCampaignNFT721);

        var _boxItemCampaignNFT721 = await InZBoxItemCampaignNFT721.deployed();

        await _boxItemCampaignNFT721.initialize("BOX ITEM",
            "BI",
            types,
            uri,
            nullAddress)
        wf("InZBoxItemCampaignNFT721", _boxItemCampaignNFT721.address);
    } else {
        var _boxItemCampaignNFT721 = await InZBoxItemCampaignNFT721.at(
            process.env.InZBoxItemCampaignNFT721
        );
    }

    /**
     *      0.2.    Deploy InZBoxCampaign
     */
    if (deployments.boxCampaign) {
        await deployer.deploy(InZBoxCampaign);
        var _boxCampaign = await InZBoxCampaign.deployed();
        wf("InZBoxCampaign", _boxCampaign.address);
    } else {
        var _boxCampaign = await InZBoxCampaign.at(process.env.InZBoxCampaign);
    }

    /**
    *      0.3.    Deploy InZCampaignBoxFactory
    */
    if (deployments.campaignBoxFactory) {
        await deployer.deploy(InZCampaignBoxFactory, nullAddress);
        var _campaignBoxFactory = await InZCampaignBoxFactory.deployed();
        wf("InZCampaignBoxFactory", _campaignBoxFactory.address);
    } else {
        var _campaignBoxFactory = await InZCampaignBoxFactory.at(process.env.InZCampaignBoxFactory);
    }


}