const fs = require("fs");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const { BigNumber } = require("@ethersproject/bignumber");

var InZBoxCampaign = artifacts.require("InZBoxCampaign");
var InZBoxItemCampaignNFT721 = artifacts.require("InZBoxItemCampaignNFT721");
var InZCampaignBoxFactory = artifacts.require("InZCampaignBoxFactory");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
require("dotenv").config();

const privateKey = fs.readFileSync(".private_key").toString().trim();

contract("BoxCampaign", function (accounts) {

    it("Open box", async function () {
        const inZBoxCampaign = await InZBoxCampaign.at(process.env.InZBoxCampaign)
        const inZBoxItemCampaignNFT721 = await InZBoxItemCampaignNFT721.at(process.env.InZBoxItemCampaignNFT721)
        const inZCampaignBoxFactory = await InZCampaignBoxFactory.at(process.env.InZCampaignBoxFactory)


        const openLog = await inZBoxCampaign.openBox(0);

        console.log("openLog: ", mintLog)
        console.log("openLog args: ", mintLog.logs[0].args)


        return assert.isTrue(true);
    });
});
