-include .env

.PHONY: all test clean deploy add sendeth senderc20 help install snapshot format anvil

chain ?= anvil
fork_url := $(if $(filter $(chain),anvil),http://127.0.0.1:8545,$(SEPOLIA_RPC_URL))
account := $(if $(filter $(chain),anvil),keyOne,devWallet)
verify_flags := $(if $(filter $(chain),sepolia),--verify --etherscan-api-key $(ETHERSCAN_API_KEY),)

install:
	forge install OpenZeppelin/openzeppelin-contracts@v5.4.0 && forge install Cyfrin/foundry-devops@0.4.0

fmt-build:; forge fmt && forge build

coverage:; forge coverage --report debug > coverage.txt

test:; forge test

test-sepolia:; forge test --fork-url $(SEPOLIA_RPC_URL) 

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

deploy-safeSend: 
	forge script script/DeploySafeSend.s.sol:DeploySafeSend \
		--fork-url $(fork_url) --account $(account) --broadcast $(verify_flags) -vvvv

add-address:
	forge script script/Interactions.s.sol:AddAddress \
		--fork-url $(fork_url) --account $(account) --broadcast $(verify_flags) -vvvv

send-eth:
	forge script script/Interactions.s.sol:SendEth \
		--fork-url $(fork_url) --account $(account) --broadcast $(verify_flags) -vvvv

send-erc20:
	forge script script/Interactions.s.sol:SendErc20Token \
		--fork-url $(fork_url) --account $(account) --broadcast $(verify_flags) -vvvv
