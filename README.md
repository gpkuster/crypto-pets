## 🐶 CryptoPets - an NFT project
CryptoPets is a custom ERC-721 smart contract written in Solidity that allows users to mint, manage, and personalize their own digital pets as NFTs on the blockchain. Each pet is unique, with custom attributes and tied to its original creator. The contract includes additional features such as metadata retrieval and a basic voting system to select the "cutest pet".

## 🔧 Features
### 🐾 Mint Your Own Pet
Users can mint a pet by providing:
- `name`: The pet's name.
- `breed`: The pet's breed.
- `age`: The pet's initial age.
Each minted pet is assigned a unique tokenId and stored with metadata on-chain.
- `image`: Add the ipfs image url.

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
data:application/json;base64,
{
  "name": "John",
  "description": "CryptoPet NFT 0",
  "image": "ipfs://image_uri",
  "attributes": [
    {
      "trait_type": "Breed",
      "value": "Golden retriever"
    },
    {
      "trait_type": "Age",
      "value": "8"
    }
  ]
}
```

### 🗳️ Voting System: Cutest Pet

A simple voting mechanism allows users to vote for the cutest pet by tokenId:
- One vote per wallet (vote can be changed).
- Votes are tracked and counted.
- Multiple pets can tie for most votes.
#### Relevant functions:
- `voteCutestPet(uint256 tokenId)`: Cast or change your vote.
- `getCutestPets()`: Returns an array of tokenIds with the highest votes.

## ‼️ Deployment
This contract is deployed on Sepolia testnet at this address: [0x39D80b357580bfAFCfC9827baAd5A990052BA49b](https://sepolia.etherscan.io/address/0x39d80b357580bfafcfc9827baad5a990052ba49b)

If you want to deploy it yourself, you need to add the following environment variables in a `.env` file on the project's root:

### 🔐 Environment Variables (`.env`)

```env
PRIVATE_KEY=0x<your_metamask_private_key> // you need ETH Sepolia, which you can get for free at some faucet
ETHERSCAN_API_KEY=<your_etherscan_api_key>
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/<your_infura_project_id>
```
Please note that infura is now known as "Metamask Developer".

### 💡 Deployment command
Run the following command on the project's root:
```bash
forge script script/DeployCryptoPets.s.sol \
  --rpc-url sepolia \
  --broadcast \
  --verify \
  --chain-id 11155111
````

## 👨‍💻 Author
Created by Guillermo Pastor
📫 Contact: gpastor.kuster@gmail.com
