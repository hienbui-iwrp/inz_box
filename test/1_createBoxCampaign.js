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

contract("BoxFactory", async function (accounts) {
    it("create box campaign", async function () {
        const inZBoxCampaign = await InZBoxCampaign.at(process.env.InZBoxCampaign)
        const inZBoxItemCampaignNFT721 = await InZBoxItemCampaignNFT721.at(process.env.InZBoxItemCampaignNFT721)
        const inZCampaignBoxFactory = await InZCampaignBoxFactory.at(process.env.InZCampaignBoxFactory)

        var types = [1, 2, 3, 4, 5]
        var supplies = [10, 20, 30, 40, 50]
        var nullAddress = "0x0000000000000000000000000000000000000000"


        const createBoxLog = await inZCampaignBoxFactory.createBox(
            inZBoxItemCampaignNFT721.address,
            "/uri",
            nullAddress,
            "ABC name",
            "ABC symbol",
            0,
            9000000000000000,
            0,
            process.env.RECEIVER
        )

        console.log("clone campaign log: ", createBoxLog)
        console.log("clone campaign arg: ", createBoxLog.logs[createBoxLog.logs.length - 1].args)

        const cloneBoxCampaign = createBoxLog.logs[createBoxLog.logs.length - 1].args[0]
        console.log("clone address: ", cloneBoxCampaign)


        const configLog = await inZCampaignBoxFactory.configTypeInCampaign(
            types,
            supplies,
            cloneBoxCampaign
        )


        console.log("item log: ", configLog)
        console.log("item arg: ", configLog.logs[configLog.logs.length - 1].args)
        return assert.isTrue(true);
    });


});
