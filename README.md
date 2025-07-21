## 🐶 CryptoPets - an NFT project
CryptoPets is a custom ERC-721 smart contract written in Solidity that allows users to mint, manage, and personalize their own digital pets as NFTs on the blockchain. Each pet is unique, with custom attributes and tied to its original creator. The contract includes additional features such as metadata retrieval and a basic voting system to select the "cutest pet."

## 🔧 Features
### 🐾 Mint Your Own Pet
Users can mint a pet by providing:
- `name`: The pet's name.
- `breed`: The pet's breed.
- `age`: The pet's initial age.
Each minted pet is assigned a unique tokenId and stored with metadata on-chain.

### ✏️ Editable Properties
- **Age**: Can be updated only by the pet's original creator.
- **Name**: Can be updated only by the current owner of the pet.

### 📲 Metadata URI
Each pet can be queried for a simple on-chain JSON string using:
```
function tokenMetadataURI(uint256 tokenId) public view returns (string memory)
```
Example return:
```
{
  "name": "Fluffy",
  "breed": "Shiba Inu",
  "age": 3
}
```

### 🗳️ Voting System: Cutest Pet

A simple voting mechanism allows users to vote for the cutest pet by tokenId:
- One vote per wallet (vote can be changed).
- Votes are tracked and counted.
- Multiple pets can tie for most votes.
#### Relevant functions:
voteCutestPet(uint256 tokenId): Cast or change your vote.
getCutestPets(): Returns an array of tokenIds with the highest votes.

## 🚧 Future improvements

###  Include a deployment Script
Deploy to Sepolia and test the cntract in live environment.