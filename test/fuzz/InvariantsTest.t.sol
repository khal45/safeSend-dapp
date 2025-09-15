// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {SafeSend} from "../../src/SafeSend.sol";
import {DeploySafeSend} from "../../script/DeploySafeSend.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Handler} from "./Handler.t.sol";

// Invariants
// - A user should only be able to send eth to a whitelisted address
// - A user should only be able to send erc20 tokens to a whitelisted address

contract InvariantTest is StdInvariant, Test {
    SafeSend safeSend;
    ERC20Mock mockToken;
    DeploySafeSend deploySafeSend;
    Handler handler;
    address user = makeAddr("user");
    uint256 private constant ETH_AMOUNT_TO_DEAL = 1000 ether;

    function setUp() public {
        deploySafeSend = new DeploySafeSend();
        mockToken = new ERC20Mock();
        vm.deal(user, ETH_AMOUNT_TO_DEAL);
        safeSend = deploySafeSend.deploySafeSend(user);

        handler = new Handler(safeSend, mockToken);
        handler.addAddressAndApprove();
        targetContract(address(handler));
    }

    function invariant_onlyWhitelistedGotEth() public view {
        uint256 recipientsLength = handler.getrecipientsLength();
        for (uint256 i = 0; i < recipientsLength; i++) {
            address recipient = handler.recipients(i);
            if (recipient.balance > 0) {
                assertTrue(safeSend.isWhitelisted(recipient), "Non-whitelisted address got ETH");
            }
        }
    }

    function invariant_onlyWhitelistedGotTokens() public view {
        uint256 recipientsLength = handler.getrecipientsLength();
        for (uint256 i = 0; i < recipientsLength; i++) {
            address recipient = handler.recipients(i);
            if (mockToken.balanceOf(recipient) > 0) {
                assertTrue(safeSend.isWhitelisted(recipient), "Non-whitelisted address got tokens");
            }
        }
    }
}
