// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {BaseSafeSendTest} from "../base/BaseSafeSendTest.t.sol";
import {SafeSend} from "../../src/SafeSend.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SafeSendForkTest is BaseSafeSendTest {
    address internal dai;

    function setUpEnvironment() internal override {
        vm.createSelectFork(vm.envString("ETH_MAINNET_RPC_URL"));

        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        safeSend = new SafeSend(user);

        deal(dai, user, 1000 ether);
        vm.deal(user, 100 ether);
    }

    function _token() internal view override returns (address) {
        return dai;
    }

    function _approveTokens(address spender, uint256 amount) internal override {
        IERC20(dai).approve(spender, amount);
    }
}
