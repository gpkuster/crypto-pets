// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/CryptoPets.sol";

contract CryptoPetsTest is Test {
    // For pet management
    CryptoPets cryptoPets;
    address public admin = vm.addr(1);
    address public petCreator = vm.addr(2);
    address public petSecondOwner = vm.addr(3);

    // For voting
    address public voter1 = vm.addr(4);
    address public voter2 = vm.addr(5);
    address public voter3 = vm.addr(6);
    address public voter4 = vm.addr(7);

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

    // Voting system
    // Happy paths
    function testVoteCutestPetJustOneWinner() public {
        vm.startPrank(voter1);
        // tokenId = 1
        cryptoPets.mintPet("Roco", "Parrot", 10);
        cryptoPets.voteCutestPet(0);
        vm.startPrank(voter2);
        // tokenId = 2
        cryptoPets.mintPet("Will", "Silver cat", 2);
        cryptoPets.voteCutestPet(1);
        vm.startPrank(voter3);
        // tokenId = 3
        cryptoPets.mintPet("May", "Golden retriever", 3);
        cryptoPets.voteCutestPet(1);
        vm.startPrank(voter4);
        // tokenId = 4
        cryptoPets.mintPet("Lawrence", "Beagle", 3);
        cryptoPets.voteCutestPet(1);

        // There's just 1 winner
        assertEq(cryptoPets.getCutestPets().length, 1);
        // winner is tokenId = 1
        assertEq(cryptoPets.getCutestPets()[0], 1);

        vm.stopPrank();
    }

    function testVoteCutestPetManyWinners() public {
        vm.startPrank(voter1);
        // tokenId = 1
        cryptoPets.mintPet("Roco", "Parrot", 10);
        cryptoPets.voteCutestPet(1);
        vm.startPrank(voter2);
        // tokenId = 2
        cryptoPets.mintPet("Will", "Silver cat", 2);
        cryptoPets.voteCutestPet(1);
        vm.startPrank(voter3);
        // tokenId = 3
        cryptoPets.mintPet("May", "Golden retriever", 3);
        cryptoPets.voteCutestPet(2);
        vm.startPrank(voter4);
        // tokenId = 4
        cryptoPets.mintPet("Lawrence", "Beagle", 3);
        cryptoPets.voteCutestPet(2);

        // There are 2 winners
        assertEq(cryptoPets.getCutestPets().length, 2);
        // There's a tie between 1 and 2
        assert(cryptoPets.getCutestPets()[0] == 1 || cryptoPets.getCutestPets()[0] == 2);
        assert(cryptoPets.getCutestPets()[1] == 1 || cryptoPets.getCutestPets()[1] == 2);

        vm.stopPrank();
    }

    function testChangeVoteSuccesfully() public {
        vm.startPrank(voter1);
        // tokenId = 1
        cryptoPets.mintPet("Roco", "Parrot", 10);
        cryptoPets.voteCutestPet(1);
        assertEq(cryptoPets.getCutestPets()[0], 1);
        assertEq(cryptoPets.getCutestPets().length, 1);

        // same vote does nothing
        cryptoPets.voteCutestPet(1);
        assertEq(cryptoPets.getCutestPets()[0], 1);
        assertEq(cryptoPets.getCutestPets().length, 1);

        // changin vote allowed
        cryptoPets.voteCutestPet(0);
        assertEq(cryptoPets.getCutestPets()[0], 0);
        assertEq(cryptoPets.getCutestPets().length, 1);

        vm.stopPrank();
    }

    function testIfNoVotesShouldReturnEmptyArray() public {
        assertEq(cryptoPets.getCutestPets().length, 0);
    }

    // Reverts
    function testPetMustExistForVotingIt() public {
        vm.startPrank(voter1);
        // tokenId = 1
        cryptoPets.mintPet("Roco", "Parrot", 10);

        vm.expectRevert("Pet does not exist");
        cryptoPets.voteCutestPet(2);

        vm.stopPrank();
    }

    function testAddressMustOwnAPetBeforeVoting() public {
        vm.startPrank(voter1);

        vm.expectRevert("Invalid pet owner");
        cryptoPets.voteCutestPet(0);

        vm.stopPrank();
    }
}
