const fs = require("fs");
const web3 = require("web3");
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

  it("mint box", async function () {
    const inZBoxCampaign = await InZBoxCampaign.at(process.env.InZBoxCampaignConfigured)
    const inZBoxItemCampaignNFT721 = await InZBoxItemCampaignNFT721.at(process.env.InZBoxItemCampaignNFT721)
    const inZCampaignBoxFactory = await InZCampaignBoxFactory.at(process.env.InZCampaignBoxFactory)

    // signature
    const _encode = web3.eth.abi.encodeParameters(
      ["address", "address", "address"],
      [
        process.env.SIGNER,
        process.env.InZBoxCampaignConfigured,
        process.env.InZBoxItemCampaignNFT721,
      ]
    );

    const _digest = web3.utils.keccak256(_encode);
    let signature = web3.eth.accounts.sign(_digest, `0x${privateKey}`);

    // mint
    const mintLog = await inZBoxCampaign.mintBox({ v: signature.v, s: signature.s, r: signature.r, deadline: 9999999999 });

    console.log("mintLog: ", mintLog)
    console.log("mintLog args: ", mintLog.logs[mintLog.logs.length - 1].args)


    return assert.isTrue(true);
  });
});
