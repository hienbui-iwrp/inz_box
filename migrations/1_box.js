const console = require("console");
const fs = require("fs");

// command line run: truffle migrate --f 1 --to 1 --network base_goerli -reset --compile-none

var BoxCollection = artifacts.require("BoxCollection");
var ERC1155RandomCollection = artifacts.require("ERC1155RandomCollection");

function wf(name, address) {
    fs.appendFileSync("_address.txt", name + "=" + address);
    fs.appendFileSync("_address.txt", "\r\n");
}

const deployments = {
    erc1155RandomCollection: false,
    boxCollection: false,
    config1155: true,
};

module.exports = async function (deployer, network, accounts) {
    let account = deployer.options?.from || accounts[0];
    console.log("deployer = ", account);
    require("dotenv").config();
    var _devWallet = process.env.DEV_WALLET;

    var types = [1, 2, 3, 4, 5]
    var uri = ["1", "2", "3", "4", "5"]
    var nullAddress = "0x0000000000000000000000000000000000000000"
    var supplies = [5000, 2000, 500, 100, 10]

    /**
     *      0.1.    Deploy ERC1155RandomCollection
     */
    if (deployments.erc1155RandomCollection) {
        await deployer.deploy(ERC1155RandomCollection, nullAddress, types, uri);
        var _erc1155RandomCollection = await ERC1155RandomCollection.deployed();
        wf("ERC1155RandomCollection", _erc1155RandomCollection.address);
    } else {
        var _erc1155RandomCollection = await ERC1155RandomCollection.at(
            process.env.ERC1155RandomCollection
        );
    }

    /**
     *      0.2.    Deploy BoxCollection
     */
    if (deployments.boxCollection) {

        // await deployer.deploy(BoxCollection, _erc1155RandomCollection.address);
        await deployer.deploy(BoxCollection, _erc1155RandomCollection.address, types, supplies);
        var _boxCollection = await BoxCollection.deployed();
        wf("BoxCollection", _boxCollection.address);
    } else {
        var _boxCollection = await BoxCollection.at(process.env.BoxCollection);
    }

    // update box collection
    if (deployments.config1155) {
        await _erc1155RandomCollection.updateBox(_boxCollection.address)
        console.log("update box address succesfully")
    }
}