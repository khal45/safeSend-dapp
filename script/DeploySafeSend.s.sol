// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/
import {SafeSend} from "../src/SafeSend.sol";
import {Script, console2} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeploySafeSend is Script {
    SafeSend public safeSend;

    function run() external returns (SafeSend) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getAnvilNetworkConfig();
        vm.startBroadcast();
        safeSend = new SafeSend(config.owner);
        vm.stopBroadcast();
        return safeSend;
    }

    function deploySafeSend(address owner) public returns (SafeSend) {
        safeSend = new SafeSend(owner);
        return safeSend;
    }
}
