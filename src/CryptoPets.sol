// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

/**
 * @title CryptoPets
 * @notice ERC721 contract for virtual pet management
 */
contract CryptoPets is ERC721, Ownable {
    using Strings for uint8;
    using Strings for uint256;

    mapping(uint256 => Pet) pets;
    uint256 currentTokenId;

    // For voting
    mapping(address => uint256) public ownerVotes; // owner => tokenId they voted for (0 if none)
    mapping(uint256 => uint256) public petVotes; // tokenId => vote count
    uint256 public maxVotes; // highest votes count so far

    event PetMinted(uint256 tokenId, string name, string breed, uint8 age, address creator);
    event AgeUpdated(uint256 tokenId, uint8 age);
    event NameUpdated(uint256 tokenId, string name);
    event VoteCast(address voter, uint256 tokenId);

    struct Pet {
        uint256 tokenId;
        string name;
        string breed;
        uint8 age;
        address creator;
        string image;
    }

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(msg.sender) {}

    /// @notice Creates a new Pet for the user
    function mintPet(string memory name_, string memory breed_, uint8 age_, string memory image) external {
        _safeMint(msg.sender, currentTokenId);
        Pet memory newPet = Pet(currentTokenId, name_, breed_, age_, msg.sender, image);
        pets[currentTokenId] = newPet;
        emit PetMinted(currentTokenId, newPet.name, newPet.breed, newPet.age, newPet.creator);

        currentTokenId++;
    }

    /// @notice Returns pet's data
    function getPetInfo(uint256 tokenId_) external view returns (uint256, string memory, string memory, uint8) {
        Pet memory pet = pets[tokenId_];
        return (pet.tokenId, pet.name, pet.breed, pet.age);
    }

    /// @notice Allows the original creator to update their pet's age
    function updateAge(uint256 tokenId_, uint8 newAge_) external {
        require(_exists(tokenId_), "Pet does not exist");
        require(msg.sender == pets[tokenId_].creator, "Not the original creator");
        pets[tokenId_].age = newAge_;
        emit AgeUpdated(tokenId_, newAge_);
    }

    /// @notice Allows the owner to update their pet's name
    function updateName(uint256 tokenId_, string memory newName_) external {
        require(_exists(tokenId_), "Pet does not exist");
        require(msg.sender == ownerOf(tokenId_), "Not the owner");
        pets[tokenId_].name = newName_;
        emit NameUpdated(tokenId_, newName_);
    }

    /// @notice Vote for the cutest pet by tokenId
    function voteCutestPet(uint256 tokenId_) external {
        require(_exists(tokenId_), "Pet does not exist");
        require(balanceOf(msg.sender) > 0, "Invalid pet owner");

        uint256 previousVote = ownerVotes[msg.sender];
        if (previousVote == tokenId_) {
            // Already voted for this pet, do nothing
            return;
        }

        // Remove previous vote if any
        if (previousVote != 0) {
            petVotes[previousVote]--;
        }

        // Register new vote
        ownerVotes[msg.sender] = tokenId_;
        petVotes[tokenId_]++;

        // Update maxVotes if needed
        if (petVotes[tokenId_] > maxVotes) {
            maxVotes = petVotes[tokenId_];
        }

        emit VoteCast(msg.sender, tokenId_);
    }

    /// @notice Returns tokenId(s) with the highest votes (could be multiple ties)
    function getCutestPets() external view returns (uint256[] memory) {
        uint256[] memory winners;

        if (maxVotes == 0) {
            return winners; // no votes cast yet
        }

        // Count how many pets have maxVotes
        uint256 count = 0;
        for (uint256 i = 0; i < currentTokenId; i++) {
            if (petVotes[i] == maxVotes) {
                count++;
            }
        }

        winners = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < currentTokenId; i++) {
            if (petVotes[i] == maxVotes) {
                winners[index++] = i;
            }
        }

        return winners;
    }

    /// @notice Returns the pet's data in JSON format, base64 encoded
    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        require(_exists(tokenId_), "Pet does not exist");
        Pet memory pet = pets[tokenId_];

        string memory json = string(
            abi.encodePacked(
                "{",
                '"name":"',
                pet.name,
                '",',
                '"description":"CryptoPet NFT ',
                tokenId_.toString(),
                '",',
                '"image":"ipfs://',
                pet.image,
                '",',
                '"attributes":[',
                '{ "trait_type": "Breed", "value": "',
                pet.breed,
                '" },',
                '{ "trait_type": "Age", "value": "',
                pet.age.toString(),
                '" }',
                "]",
                "}"
            )
        );

        //string memory encodedJson = Base64.encode(bytes(json));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /// @dev Checks if the tokenId exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
