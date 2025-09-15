// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/
import {Script} from "forge-std/Script.sol";
import {SafeSend} from "../src/SafeSend.sol";

contract HelperConfig is Script {
    // Change the address below if you want to use a different address for the owner on anvil
    address public constant ANVIL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // First anvil key to be set as the owner of the SafeSend contract when on anvil
    // Change the address below if you want to use a different address for the owner on sepolia
    address public constant SEPOLIA_ADDRESS = 0xE5bCBA588f2831d99181F1794390E88EA904640c; // Sepolia development wallet address
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ANVIL_CHAIN_ID = 31337;

    struct NetworkConfig {
        address owner;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == ANVIL_CHAIN_ID) {
            activeNetworkConfig = getAnvilNetworkConfig();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        }
    }

    function getAnvilNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({owner: ANVIL_ADDRESS});
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({owner: SEPOLIA_ADDRESS});
    }
}
