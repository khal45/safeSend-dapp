// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/

import {Test, console2} from "forge-std/Test.sol";
import {SafeSend} from "../../src/SafeSend.sol";
import {DeploySafeSend} from "../../script/DeploySafeSend.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SafeSendIntegrationTest is Test {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    SafeSend safeSend;
    ERC20Mock mockToken;
    DeploySafeSend deploySafeSend;
    address user = makeAddr("user");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    uint256 private constant ETH_AMOUNT_TO_DEAL = 1000 ether;
    uint256 private constant ETH_AMOUNT_TO_SEND = 1 ether;
    uint256 private constant TOKENS_TO_MINT = 1000 ether;
    uint256 private constant TOKENS_TO_SEND = 1 ether;
    uint256 private constant PLAYERS_NUM = 100;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AddressAdded(address indexed _recipient);
    event EthSent(address indexed _recipient, uint256 _amount);
    event TokenSent(address indexed _tokenAddress, address indexed _recipient, uint256 _amount);

    function setUp() public {
        deploySafeSend = new DeploySafeSend();
        safeSend = deploySafeSend.deploySafeSend(user);

        mockToken = new ERC20Mock();
        vm.deal(user, ETH_AMOUNT_TO_DEAL);
        mockToken.mint(user, TOKENS_TO_MINT);
    }

    function testEthFlowMultipleRecipients() public {
        vm.startPrank(user);
        for (uint256 i = 0; i < PLAYERS_NUM; i++) {
            address recipient = vm.addr(i + 1);
            safeSend.addAddress(recipient);
            uint256 previousUserBalance = user.balance;
            uint256 previousRecipientBalance = recipient.balance;

            safeSend.sendEth{value: ETH_AMOUNT_TO_SEND}(recipient);

            assertEq(user.balance, previousUserBalance - ETH_AMOUNT_TO_SEND);
            assertEq(recipient.balance, previousRecipientBalance + ETH_AMOUNT_TO_SEND);
        }
        vm.stopPrank();
    }

    function testErc20FlowMultipleRecipients() public {
        vm.startPrank(user);
        mockToken.approve(address(safeSend), PLAYERS_NUM * TOKENS_TO_SEND);
        for (uint256 i = 0; i < PLAYERS_NUM; i++) {
            address recipient = vm.addr(i + 1);
            safeSend.addAddress(recipient);
            mockToken.approve(address(safeSend), TOKENS_TO_SEND);
            uint256 userBalanceBefore = mockToken.balanceOf(user);
            uint256 recipientBalanceBefore = mockToken.balanceOf(recipient);

            safeSend.sendErc20Token(address(mockToken), recipient, TOKENS_TO_SEND);

            uint256 userBalanceAfter = mockToken.balanceOf(user);
            uint256 recipientBalanceAfter = mockToken.balanceOf(recipient);
            assertEq(userBalanceAfter, userBalanceBefore - TOKENS_TO_SEND);
            assertEq(recipientBalanceAfter, recipientBalanceBefore + TOKENS_TO_SEND);
        }
        vm.stopPrank();
    }
}
