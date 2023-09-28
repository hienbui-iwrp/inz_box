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

        const types = [1, 2, 3, 4, 5]
        const uri = ["1", "2", "3", "4", "5"]
        const amounts = [10, 20, 30, 40, 50]


        const createBoxLog = await inZCampaignBoxFactory.createBox(
            inZBoxItemCampaignNFT721.address,
            "12134",
            "0x0000000000000000000000000000000000000000",
            "ABC",
            "ABC",
            0,
            1000000000000000,
            true,
            0,
            process.env.RECEIVER
        )

        console.log("clone campaign log: ", createBoxLog)
        console.log("clone campaign arg: ", createBoxLog.logs[0].args)

        const cloneBoxCampaign = createBoxLog.logs[0].args[0]

        const createBoxItemLog = await inZCampaignBoxFactory.createBoxItem(
            "ABC",
            "ABC",
            types,
            uri,
            amounts,
            cloneBoxCampaign
        )
        console.log("clone item campaign log: ", createBoxItemLog)
        console.log("clone item campaign arg: ", createBoxItemLog.logs[0].args)
        return assert.isTrue(true);
    });


});
