const console = require("console");
const fs = require("fs");

// command line run: truffle migrate --f 1 --to 1 --network base_goerli -reset --compile-none

var InZBoxCampaign = artifacts.require("InZBoxCampaign");
var InzCampaignTypesNFT721 = artifacts.require("InzCampaignTypesNFT721");
var InZCampaignBoxFactory = artifacts.require("InZCampaignBoxFactory");

function wf(name, address) {
  fs.appendFileSync("_address.txt", name + "=" + address);
  fs.appendFileSync("_address.txt", "\r\n");
}

const deployments = {
  InzCampaignTypesNFT721: true,
  InZBoxCampaign: true,
  InZCampaignBoxFactory: true,
};

module.exports = async function (deployer, network, accounts) {
  let account = deployer.options?.from || accounts[0];
  console.log("deployer = ", account);
  require("dotenv").config();
  var _devWallet = process.env.DEV_WALLET;

  var types = [1, 2, 3, 4, 5];
  var uri = ["/1", "/2", "/3", "/4", "/5"];
  var nullAddress = "0x0000000000000000000000000000000000000000";
  var supplies = [5000, 2000, 500, 100, 10];

  /**
   *      0.1.    Deploy InzCampaignTypesNFT721
   */
  if (deployments.InzCampaignTypesNFT721) {
    await deployer.deploy(InzCampaignTypesNFT721);
    var _InzCampaignTypesNFT721 = await InzCampaignTypesNFT721.deployed();
    wf("InzCampaignTypesNFT721", _InzCampaignTypesNFT721.address);
  } else {
    var _InzCampaignTypesNFT721 = await InzCampaignTypesNFT721.at(
      process.env.InzCampaignTypesNFT721
    );
  }

  /**
   *      0.2.    Deploy InZBoxCampaign
   */
  if (deployments.InZBoxCampaign) {
    await deployer.deploy(InZBoxCampaign);
    var _InZBoxCampaign = await InZBoxCampaign.deployed();
    wf("InZBoxCampaign", _InZBoxCampaign.address);
  } else {
    var _InZBoxCampaign = await InZBoxCampaign.at(process.env.InZBoxCampaign);
  }

  /**
   *      0.3.    config InZCampaignBoxFactory
   */
  if (deployments.InZCampaignBoxFactory) {
    await deployer.deploy(InZCampaignBoxFactory, _InZBoxCampaign.address);
    var _InZCampaignBoxFactory = await InZCampaignBoxFactory.deployed();
    wf("InZCampaignBoxFactory", _InZCampaignBoxFactory.address);
  } else {
    var _InZCampaignBoxFactory = await InZCampaignBoxFactory.at(
      process.env.InZCampaignBoxFactory
    );
  }
};
