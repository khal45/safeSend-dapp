# SafeSend

SafeSend is a security-focused decentralized application that protects users from address poisoning attacks.
It allows transfers only to pre-approved addresses, acting as a personal trusted contacts system on-chain.
Traditional wallets are vulnerable to address poisoning attacks. SafeSend eliminates this by enforcing transfers only to pre-approved addresses, ensuring users never send funds to malicious addresses.

# Table of Contents

- [SafeSend](#safesend)
- [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Getting Started](#getting-started)
    - [Deploy](#deploy)
    - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
    - [Scripts](#scripts)
    - [Estimate gas](#estimate-gas)
  - [Formatting](#formatting)
  - [Compatibilities](#compatibilities)
  - [Roles](#roles)
  - [Known Issues](#known-issues)
  - [Future Developments](#future-developments)

## Installation

**Foundry**

- Follow the instructions on [getfoundry](https://book.getfoundry.sh/getting-started/installation) to install Foundry on your local machine

## Usage

### Getting Started

Follow these steps to run this project locally:

- Clone the Github repo
- Install foundry on your machine
- Set your sepolia and mainnet rpc urls in your .env file. You can get them from [alchemy](https://www.alchemy.com/).
- Set your etherscan api key if you want to verify your contract on [Etherscan](https://etherscan.io/).

```# .env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-api-key
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your-api-key
ETHERSCAN_API_KEY=your-api-key
```

> ⚠️ **Never store your private key in plain text in your `.env` file**, even for testnets!  
> Watch [this video by Cyfrin Audits](https://youtu.be/VQe7cIpaE54?si=GDZAdaltdRO8-Ond) to learn best practices for handling private keys.

- Install the necessary packages with `make install` or just run `forge install` if you don't have makefile installed

### Deploy

`make deploy-sepolia`

Replace `keyOne` and `devWallet` in the makefile with your encrypted wallets

### Testing

Local test

`make test`

Sepolia test

`make test-sepolia`

### Test Coverage

`forge coverage`

## Deployment to a testnet or mainnet

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy

`make deploy-safeSend`

This will deploy the `safeSend.sol` contract

### Scripts

After deploying to a testnet or local net, you can run the scripts.

- Run `make add-address` to add an address to the whitelist
- Run `send-eth` to send eth to a whitelisted address
- Run `send-erc20` to send an erc20 token to a whitelisted address

### Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

## Formatting

To run code formatting:

```
forge fmt
```

## Compatibilities

- solc version: 0.8.30
- Chain(s) to deploy contract to: Ethereum

## Roles

Owner - The user of the protocol, only the owner can add an address to the whitelist and send eth or erc20 tokens to them

## Known Issues

Currently no known issues. Please open an issue
if you find one.
This invites community feedback.

## Future Developments

- Building the UI and integration with the UI
