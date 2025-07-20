// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/CryptoPets.sol";

contract CryptoPetsTest is Test {
    CryptoPets cryptoPets;
    address public admin = vm.addr(1);
    address public randomUser1 = vm.addr(2);
    address public randomUser2 = vm.addr(3);

    string name = "Crypto Pets NFT by Guillermo Pastor";
    string symbol = "GPPET";

    function setUp() public {
        vm.startPrank(admin);
        cryptoPets = new CryptoPets(name, symbol);
        vm.stopPrank();
    }

    // Contract deployment
    function testCryptoPetsDeployedSuccesfully() external view {
        //then
        assertNotEq(address(cryptoPets), address(0));
        assertEq(cryptoPets.owner(), admin);
        assertEq(cryptoPets.name(), name);
        assertEq(cryptoPets.symbol(), symbol);
    }

    // Happy paths
    function testMintPetAndUpdateAge() public {
        //given
        vm.startPrank(randomUser1);
        cryptoPets.mintPet("John", "Golden retriever", 8);
        //assert(cryptoPets._exists(0));
        cryptoPets.updateAge(0, 5);
        (,,, uint8 newAge_) = cryptoPets.getPetInfo(0);
        assertEq(newAge_, 5);
        vm.stopPrank();
    }
}
