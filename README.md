# MetaSapiens NFT Game

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg?cacheSeconds=2592000)
![Prerequisite](https://img.shields.io/badge/node-%3E%3D10.0-blue.svg)

## Setup
- `yarn`
- `yarn global add hardhat-shorthand`

## Run local node
- `yarn node`

## Environment File (.env)
- Configure the following environment variables on a .env in the package root:
  - Mnemonic - Deployment Owner(s) BIP-32 Mnemonic phrase
  - Lottery Participant Entry Fee in Wei
  - Owner Fee in Wei

## Compile & migrate (Deploy) Contracts
- `yarn deploy` (Default network: Kovan Ethereum Testnet)

![image](https://user-images.githubusercontent.com/25655858/138593361-b2bdb31d-6b0e-491b-b000-69a183fa0f1c.png)

## Run Tests
- `yarn test`
