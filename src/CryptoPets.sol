// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title CryptoPets
 * @notice ERC721 contract for virtual pet management
 */

contract CryptoPets is ERC721, Ownable {

    mapping(uint256 => Pet) pets;
    uint256 currentTokenId;

    event PetMinted(uint256 tokenId, string name, string breed, uint8 age, address creator);
    event AgeUpdated(uint256 tokenId, uint8 age);
    event NameUpdated(uint256 tokenId, string name);

    struct Pet {
        uint256 tokenId;
        string name;
        string breed;
        uint8 age;
        address creator;
    }

    constructor(string memory name_, string memory symbol_) 
        ERC721(name_, symbol_) 
        Ownable(msg.sender)
    {}

    /// @notice Creates a new Pet for the user
    function mintPet(string memory name_, string memory breed_, uint8 age_) external {
        _safeMint(msg.sender, currentTokenId);
        Pet memory newPet = Pet(currentTokenId, name_, breed_, age_, msg.sender);
        pets[currentTokenId] = newPet;
        emit PetMinted(currentTokenId, newPet.name, newPet.breed, newPet.age, newPet.creator);

        currentTokenId++;
    }

    /// @notice Returns pet's data
    function getPetInfo(uint256 tokenId_) external view returns(uint256, string memory, string memory, uint8) {
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

    /// @dev Checks if the tokenId exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}