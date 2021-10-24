// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

const main = async () => {
  const gameContractFactory = await ethers.getContractFactory("MetaSapiens");
  const gameContract = await gameContractFactory.deploy(
    ["Xander", "Amora", "Morpheus", "Pythora"], // Names
    ["Warrior", "Healer", "Shapeshifter", "Reptile"], // Class
    [
      "https://images.outlookindia.com/public/uploads/newsimages/Alien_630_630.jpg",
      "https://i.pinimg.com/originals/5b/2a/5e/5b2a5e9d95549f531efde702ac50b857.jpg",
      "https://topicimages.mrowl.com/large/joshbwilliams/aliens_ufos/allegedextrate/alienhumanhybr_1.jpg",
      "https://3.bp.blogspot.com/-myLieYsD-qc/Tnsx6vezozI/AAAAAAAACXs/aGZ6cVIlW10/s1600/hybrid1.jpg",
    ],
    [300, 200, 260, 220], // HP values
    [200, 120, 150, 140], // Attack damage values
    "Triton", // Boss name
    "https://i.imgur.com/MfuSeoA.mp4", // Boss image
    1000, // Boss hp
    50 // Boss attack damage
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  let returnedTokenUri;

  txn = await gameContract.mintSapienNFT(0);
  await txn.wait();

  returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Minted Sapien NFT #1\nURI:", returnedTokenUri);

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.mintSapienNFT(1);
  await txn.wait();

  returnedTokenUri = await gameContract.tokenURI(2);
  console.log("Minted Sapien NFT #2\nURI:", returnedTokenUri);

  txn = await gameContract.mintSapienNFT(2);
  await txn.wait();

  returnedTokenUri = await gameContract.tokenURI(3);
  console.log("Minted Sapien NFT #3\nURI:", returnedTokenUri);

  txn = await gameContract.mintSapienNFT(3);
  await txn.wait();

  returnedTokenUri = await gameContract.tokenURI(4);
  console.log("Minted Sapien NFT #4\nURI:", returnedTokenUri);
};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
