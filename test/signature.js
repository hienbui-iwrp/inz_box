const web3 = require("web3");
const fs = require("fs");

var InZBoxCampaign = artifacts.require("InZBoxCampaign");
var InZBoxItemCampaignNFT721 = artifacts.require("InZBoxItemCampaignNFT721");
var InZCampaignBoxFactory = artifacts.require("InZCampaignBoxFactory");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
require("dotenv").config();

// const privateKey = fs.readFileSync(".private_key").toString().trim();
const privateKey = "a1a3605d9a4af5fa38d2c7cb7c410bf2bd8473722ef63e15b80322e62beff826";

contract("BoxCollection", function (accounts) {
    it("signature", async function () {
        const inZBoxCampaign = await InZBoxCampaign.at(
            process.env.InZBoxCampaignConfigured
        );
        const inZBoxItemCampaignNFT721 = await InZBoxItemCampaignNFT721.at(
            process.env.InZBoxItemCampaignNFT721
        );
        const inZCampaignBoxFactory = await InZCampaignBoxFactory.at(
            process.env.InZCampaignBoxFactory
        );

        console.log("account: ", accounts);


        const _encode = web3.eth.abi.encodeParameters(
            ["address", "address", "address"],
            [
                accounts[0],
                process.env.InZBoxCampaignConfigured,
                process.env.InZBoxItemCampaignNFT721,
            ]
        );

        console.log("_encode: ", _encode)

        const _digest = web3.utils.keccak256(_encode);

        console.log("_digest: ", _digest);

        let signature = web3.eth.accounts.sign(web3.eth.accounts.hashMessage(_digest), `0x${privateKey}`);
        console.log(signature);
        // let recover = web3.eth.accounts.recover(signature.message, signature.v, signature.r, signature.s)

        // console.log("recover: ", recover)

        let data = await inZBoxCampaign.getData();
        console.log("data: ", data);

        let signer = await inZBoxCampaign.getSigner({
            v: signature.v,
            r: signature.r,
            s: signature.s,
            deadline: 1000000000,
        });
        console.log("signer: ", signer);

        let signerWithHash = await inZBoxCampaign.getSignerWithMessage(web3.eth.accounts.hashMessage(_digest), {
            v: signature.v,
            r: signature.r,
            s: signature.s,
            deadline: 1000000000,
        });
        console.log("signerWithHash: ", signerWithHash);


        return assert.isTrue(true);
    });
});
