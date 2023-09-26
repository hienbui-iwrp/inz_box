var InzCampaignTypesNFT1155 = artifacts.require("InzCampaignTypesNFT1155");
var BoxCampaign = artifacts.require("BoxCampaign");
const fs = require("fs");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const { BigNumber } = require("@ethersproject/bignumber");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
require("dotenv").config();

const privateKey = fs.readFileSync(".private_key").toString().trim();

contract("BoxCollection", function (accounts) {
  it("create box", async function () {
    var _inzCampaignTypesNFT1155 = await InzCampaignTypesNFT1155.at(process.env.ERC1155RandomCollection);
    var _boxCampaign = await BoxCampaign.at(process.env.BoxCollection);
    console.log("account: ", accounts)

    // const value = BigNumber.from('1000000000000000000'); // 10**18

    // console.log("value: ", value)

    // console.log("logs: ", await _boxCollection.transferNativeCoin
    //   .sendTransaction(process.env.RECEIVER, value, { from: accounts[0], value: value }))

    // create box
    // await _boxCampaign.mintBox(process.env.RECEIVER)


    // var latestId = await _boxCampaign.getCurrentBoxId()
    // await _boxCampaign.mintBox(accounts[0], {
    //   v: 1,
    //   s: "0x0000000000000000000000000000000000000000000000000000006d6168616d",
    //   r: "0x0000000000000000000000000000000000000000000000000000006d6168616d"
    // })
    // console.log("Latest box id: ", parseInt(latestId.toString()))

    for (var i = 0; i < 15; i++) {
      await _boxCampaign.mintBox(accounts[0], {
        v: 1,
        s: "0x0000000000000000000000000000000000000000000000000000006d6168616d",
        r: "0x0000000000000000000000000000000000000000000000000000006d6168616d"
      })
      var latestId = parseInt((await _inzCampaignTypesNFT1155.getNextId()).toString());
      await _boxCampaign.openBox(latestId)
      console.log("Open success id: ", latestId)

      var type = await _inzCampaignTypesNFT1155.getNftType(latestId);
      console.log(i, ", Nft Type: ", type.toString(), "remain: ", (await _boxCampaign.getTotalSupply()).toString())
    }

    return assert.isTrue(true);
  });

  // it("open box", async function () {
  //   var _inzCampaignTypesNFT1155 = await InzCampaignTypesNFT1155.at(process.env.ERC1155RandomCollection);
  //   var _boxCampaign = await BoxCampaign.at(process.env.BoxCollection);

  //   var latestId = parseInt((await _inzCampaignTypesNFT1155.getNextId()).toString());
  //   await _boxCampaign.openBox(latestId)
  //   console.log("Open success id: ", latestId)

  //   var type = await _inzCampaignTypesNFT1155.getNftType(latestId);
  //   console.log("Nft Type: ", type.toString())


  //   return assert.isTrue(true);
  // });
});
