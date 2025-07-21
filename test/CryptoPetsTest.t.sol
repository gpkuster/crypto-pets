// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/CryptoPets.sol";

contract CryptoPetsTest is Test {
    CryptoPets cryptoPets;
    address public admin = vm.addr(1);
    address public petCreator = vm.addr(2);
    address public petSecondOwner = vm.addr(3);

    string name = "Crypto Pets NFT by Guillermo Pastor";
    string symbol = "GPPET";

    function setUp() public {
        vm.startPrank(admin);
        cryptoPets = new CryptoPets(name, symbol);
        vm.stopPrank();
        vm.startPrank(petCreator);
        cryptoPets.mintPet("John", "Golden retriever", 8);
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

    // Pet minting and updating
    // Happy path
    function testMintPetAndUpdateAgeAndName() public {
        vm.startPrank(petCreator);
        cryptoPets.updateAge(0, 5);
        cryptoPets.updateName(0, "Laura");
        (, string memory newName_,, uint8 newAge_) = cryptoPets.getPetInfo(0);
        assertEq(newAge_, 5);
        assertEq(newName_, "Laura");
        vm.stopPrank();
    }

    // Reverts
    function testOnlyOwnerCanUpdateName() public {
        vm.startPrank(petCreator);
        cryptoPets.safeTransferFrom(petCreator, petSecondOwner, 0);
        assertEq(cryptoPets.ownerOf(0), petSecondOwner);

        vm.expectRevert("Not the owner");
        cryptoPets.updateName(0, "Laura");
        vm.stopPrank();
    }

    function testOnlyCreatorCanUpdateAge() public {
        vm.startPrank(petCreator);
        cryptoPets.safeTransferFrom(petCreator, petSecondOwner, 0);
        assertEq(cryptoPets.ownerOf(0), petSecondOwner);

        vm.expectRevert("Not the original creator");
        vm.startPrank(petSecondOwner);
        cryptoPets.updateAge(0, 10);
        vm.stopPrank();
    }

    function testPetMustExistForAgeUpdate() public {
        vm.expectRevert("Pet does not exist");
        cryptoPets.updateAge(1, 10);
        vm.stopPrank();
    }

    function testPetMustExistForNameUpdate() public {
        vm.expectRevert("Pet does not exist");
        cryptoPets.updateName(1, "New name");
        vm.stopPrank();
    }

    // JSON generation
    // Happy path
    function testJSONIsGeneratedCorrectly() public view {
        string memory tokenMetadataURI = cryptoPets.tokenMetadataURI(0);
        assertEq(tokenMetadataURI, '{"name":"John", "breed":"Golden retriever", "age":8}');
    }

    // Reverts
    function testJSONIsNotGeneratedIfTokenDoesntExist() public {
        vm.expectRevert("Pet does not exist");
        cryptoPets.tokenMetadataURI(1);
    }
}
