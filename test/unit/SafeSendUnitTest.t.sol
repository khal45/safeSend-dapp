// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {DeploySafeSend} from "../../script/DeploySafeSend.s.sol";
import {BaseSafeSendTest} from "../base/BaseSafeSendTest.t.sol";
import {SafeSend} from "../../src/SafeSend.sol";

contract SafeSendUnitTest is BaseSafeSendTest {
    ERC20Mock internal mockToken;
    DeploySafeSend internal deploySafeSend;
    uint256 private constant ETH_AMOUNT_TO_DEAL = 10 ether;
    uint256 private constant TOKENS_TO_MINT = 10 ether;

    function setUpEnvironment() internal override {
        deploySafeSend = new DeploySafeSend();
        safeSend = deploySafeSend.deploySafeSend(user);

        mockToken = new ERC20Mock();
        vm.deal(user, ETH_AMOUNT_TO_DEAL);
        mockToken.mint(user, TOKENS_TO_MINT);
    }

    function _token() internal view override returns (address) {
        return address(mockToken);
    }

    function _approveTokens(address spender, uint256 amount) internal override {
        mockToken.approve(spender, amount);
    }
}
