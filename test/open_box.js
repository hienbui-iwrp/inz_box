var ERC1155RandomCollection = artifacts.require("ERC1155RandomCollection");
var BoxCollection = artifacts.require("BoxCollection");
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
    var _erc1155RandomCollection = await ERC1155RandomCollection.at(
      process.env.ERC1155RandomCollection
    );
    var _boxCollection = await BoxCollection.at(process.env.BoxCollection);
    console.log("account: ", accounts);

    // const value = BigNumber.from('1000000000000000000'); // 10**18

    // console.log("value: ", value)

    // console.log("logs: ", await _boxCollection.transferNativeCoin
    //   .sendTransaction(process.env.RECEIVER, value, { from: accounts[0], value: value }))

    // create box
    await _boxCollection.mintBox(process.env.RECEIVER);
    console.log("Latest box id: ", await _boxCollection.getCurrentBoxId());

    return assert.isTrue(true);
  });

  it("open box", async function () {
    var _erc1155RandomCollection = await ERC1155RandomCollection.at(
      process.env.ERC1155RandomCollection
    );
    var _boxCollection = await BoxCollection.at(process.env.BoxCollection);

    await _boxCollection.openBox(2);
    console.log("Open success");

    var latestId = await _erc1155RandomCollection.getCurrentId();
    console.log("Latest Nft Type: ", latestId.toString());

    var type = await _erc1155RandomCollection.getNftType(2);
    console.log("type: ", type.toString());

    return assert.isTrue(true);
  });
});
