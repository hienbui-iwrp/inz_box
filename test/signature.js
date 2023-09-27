const web3 = require('web3')
const fs = require("fs");

var InzCampaignBoxFactory = artifacts.require("InzCampaignBoxFactory");
var InzCampaignTypesNFT1155 = artifacts.require("InzCampaignTypesNFT1155");
var InzBoxCampaign = artifacts.require("InzBoxCampaign");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
require("dotenv").config();

const privateKey = fs.readFileSync(".private_key").toString().trim();

contract("BoxCollection", function (accounts) {
    it("signature", async function () {
        var _inzCampaignTypesNFT1155 = await InzCampaignTypesNFT1155.at(process.env.ERC1155RandomCollection);
        var _boxCampaign = await BoxCampaign.at(process.env.BoxCollection);
        const txData =
        {
            signer: process.env.SIGNER,
            _to: accounts[1]
        }


        // const message = web3.utils.keccak256(web3.eth.abi.encodeFunctionSignature(txData._to))

        // const message = web3.utils.soliditySha3(txData._to)
        // const message = web3.utils.encodePacked(accounts[1])
        const message = web3.utils.soliditySha3(web3.utils.keccak256(web3.eth.abi.encodeParameters(["address"], [accounts[1]])))

        let signature = web3.eth.accounts.sign(message, `0x${privateKey}`)
        console.log(signature)
        // let recover = web3.eth.accounts.recover(signature.message, signature.v, signature.r, signature.s)

        // console.log("recover: ", recover)

        let sign = await _boxCampaign.getSigner(accounts[1], { v: signature.v, r: signature.r, s: signature.s, })
        console.log("signer: ", sign)

        let msg = await _boxCampaign.getMessage(accounts[1], { v: signature.v, r: signature.r, s: signature.s, })
        console.log("msg: ", msg)
        console.log("message hash: ", signature.messageHash)

        return assert.isTrue(true);
    });
});
