// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {SafeSend} from "../../src/SafeSend.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {
    SafeSend safeSend;
    ERC20Mock mockToken;
    uint256 private constant PLAYERS_NUM = 100;
    uint256 private constant TOKENS_TO_SEND = 1 ether;
    uint256 private constant TOKENS_TO_MINT = 1000 ether;
    address[] public recipients;

    constructor(SafeSend _safeSend, ERC20Mock _mockToken) {
        safeSend = _safeSend;
        mockToken = _mockToken;
    }

    function addAddressAndApprove() public {
        vm.startPrank(safeSend.owner());
        for (uint256 i = 0; i < PLAYERS_NUM; i++) {
            address recipient = vm.addr(i + 1);
            if (!safeSend.isWhitelisted(recipient)) {
                safeSend.addAddress(recipient);
            }
        }
    }

    function sendEth(uint256 seed) public {
        uint256 index = bound(seed, 1, PLAYERS_NUM);
        address recipient = vm.addr(index);
        // prank as owner since onlyOwner can call
        vm.startPrank(safeSend.owner());

        // Send some ETH
        if (safeSend.isWhitelisted(recipient)) {
            safeSend.sendEth{value: 1 ether}(recipient);
            recipients.push(recipient);
        }

        vm.stopPrank();
    }

    function sendErc20Token(uint256 seed) public {
        uint256 index = bound(seed, 1, PLAYERS_NUM);
        address recipient = vm.addr(index);
        vm.startPrank(safeSend.owner());
        mockToken.mint(safeSend.owner(), TOKENS_TO_MINT);
        mockToken.approve(address(safeSend), TOKENS_TO_SEND * PLAYERS_NUM);

        if (safeSend.isWhitelisted(recipient)) {
            safeSend.sendErc20Token(address(mockToken), recipient, TOKENS_TO_SEND);
            recipients.push(recipient);
        }

        vm.stopPrank();
    }

    function getrecipientsLength() external view returns (uint256) {
        return recipients.length;
    }
}
