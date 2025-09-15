// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/
import {Script, console2} from "forge-std/Script.sol";
import {SafeSend} from "../src/SafeSend.sol";
import {DeploySafeSend} from "./DeploySafeSend.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {DevOpsTools} from "devops-tools/DevOpsTools.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract AddAddress is Script {
    function addAddressToWhitelist(address mostRecentlyDeployed) public {
        // Add address to whitelist
        console2.log("Adding address to whitelist...");
        SafeSend(mostRecentlyDeployed).addAddress(vm.addr(2));
    }

    function run() public {
        vm.startBroadcast();
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("SafeSend", block.chainid);
        addAddressToWhitelist(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract SendEth is Script {
    function sendEthToWhitelisted(address mostRecentlyDeployed) public {
        console2.log("Adding address to whitelist...");
        SafeSend(mostRecentlyDeployed).addAddress(vm.addr(3));
        // Send ETH to whitelisted address
        console2.log("Sending ETH to whitelisted address...");
        SafeSend(mostRecentlyDeployed).sendEth{value: 1 ether}(vm.addr(3));
    }

    function run() public {
        vm.startBroadcast();
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("SafeSend", block.chainid);
        sendEthToWhitelisted(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract SendErc20Token is Script {
    function sendTokensToWhitelisted(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getAnvilNetworkConfig();

        // Add address to whitelist
        SafeSend(mostRecentlyDeployed).addAddress(vm.addr(4));

        // Create mock token
        ERC20Mock mockToken = new ERC20Mock();

        // Mint the user some tokens
        mockToken.mint(config.owner, 100 ether);

        // Approve SafeSend to spend tokens
        mockToken.approve(mostRecentlyDeployed, 100 ether);

        // Send ERC20 tokens to whitelisted address
        console2.log("Sending ERC20 tokens to whitelisted address...");
        SafeSend(mostRecentlyDeployed).sendErc20Token(address(mockToken), vm.addr(4), 100 ether);
    }

    function run() public {
        vm.startBroadcast();
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("SafeSend", block.chainid);
        sendTokensToWhitelisted(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
