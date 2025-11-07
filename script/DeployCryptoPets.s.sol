// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {CryptoPets} from "../src/CryptoPets.sol";

contract DeployCryptoPets is Script {
    function run() external returns (CryptoPets) {
        // El deploy lo tiene que hacer una cartera. Para poder hacer eso, necesitamos la clave privada de la cartera.
        // envUint is the method to read a uint256 environment variable in Foundry scripts.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // we use startbroadcast to deploy the smart contract with the given privatekey
        vm.startBroadcast(deployerPrivateKey);

        string memory name_ = "Crypto Pets NFT by Guillermo Pastor";
        string memory symbol_ = "GPPET";
        CryptoPets pets = new CryptoPets(name_, symbol_);

        vm.stopBroadcast();

        return pets;
    }
}
