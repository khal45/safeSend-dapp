// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import {SafeSend} from "../../src/SafeSend.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BaseSafeSendTest is Test {
    SafeSend internal safeSend;
    address internal user = makeAddr("user");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    uint256 internal constant ETH_AMOUNT_TO_SEND = 1 ether;
    uint256 internal constant TOKENS_TO_SEND = 1 ether;

    event AddressAdded(address indexed _newAddress);
    event EthSent(address indexed _recipient, uint256 _amount);
    event TokenSent(address indexed _tokenAddress, address indexed _recipient, uint256 _amount);

    // --- Abstract hook: each test type must define how SafeSend & tokens are set up
    function setUpEnvironment() internal virtual;

    function setUp() public virtual {
        setUpEnvironment();
    }

    /*//////////////////////////////////////////////////////////////
                          ADDADDRESS TESTS
    //////////////////////////////////////////////////////////////*/
    function testCannotAddAnAddressThatIsAlreadyInTheMapping() public {
        vm.startPrank(user);
        safeSend.addAddress(alice);
        vm.expectRevert(abi.encodeWithSelector(SafeSend.SafeSend__AddressAlreadyExists.selector, alice));
        safeSend.addAddress(alice);
        vm.stopPrank();
    }

    function testAddAddressUpdatesTheWhitelistMapping() public {
        vm.startPrank(user);
        safeSend.addAddress(alice);
        assertEq(safeSend.isWhitelisted(alice), true);
        vm.stopPrank();
    }

    function testAddAddressEmitsAnEvent() public {
        vm.startPrank(user);
        vm.expectEmit(true, false, false, false);
        emit AddressAdded(alice);
        safeSend.addAddress(alice);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                             SENDETH TESTS
    //////////////////////////////////////////////////////////////*/
    function testOnlyOwnerCanSendEth() public {
        vm.startPrank(alice);
        vm.deal(alice, ETH_AMOUNT_TO_SEND);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        safeSend.sendEth{value: ETH_AMOUNT_TO_SEND}(bob);
        vm.stopPrank();
    }

    function testSendEthRevertsIfRecipientNotWhitelisted() public {
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(SafeSend.SafeSend__AddressNotWhitelisted.selector, alice));
        safeSend.sendEth{value: ETH_AMOUNT_TO_SEND}(alice);
        vm.stopPrank();
    }

    function testSendEthSendsEthIfAddressIsWhitelisted() public {
        vm.startPrank(user);
        safeSend.addAddress(alice);
        uint256 balanceBefore = alice.balance;
        safeSend.sendEth{value: ETH_AMOUNT_TO_SEND}(alice);
        assertEq(alice.balance, balanceBefore + ETH_AMOUNT_TO_SEND);
        vm.stopPrank();
    }

    function testSendEthEmitsAnEventIfSuccessful() public {
        vm.startPrank(user);
        safeSend.addAddress(alice);
        vm.expectEmit(true, false, false, false);
        emit EthSent(alice, ETH_AMOUNT_TO_SEND);
        safeSend.sendEth{value: ETH_AMOUNT_TO_SEND}(alice);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                          SENDERC20TOKENS TEST
    //////////////////////////////////////////////////////////////*/
    function testOnlyOwnerCanSendErc20Tokens() public {
        vm.startPrank(alice);
        _approveTokens(address(safeSend), TOKENS_TO_SEND); // helper, see below
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        safeSend.sendErc20Token(_token(), bob, TOKENS_TO_SEND);
        vm.stopPrank();
    }

    function testErc20RevertsIfAddressNotWhitelisted() public {
        vm.startPrank(user);
        _approveTokens(address(safeSend), TOKENS_TO_SEND);
        vm.expectRevert(abi.encodeWithSelector(SafeSend.SafeSend__AddressNotWhitelisted.selector, alice));
        safeSend.sendErc20Token(_token(), alice, TOKENS_TO_SEND);
        vm.stopPrank();
    }

    function testSendErc20TokenToWhitelistedAddress() public {
        vm.startPrank(user);
        _approveTokens(address(safeSend), TOKENS_TO_SEND);
        safeSend.addAddress(alice);
        uint256 balanceBefore = IERC20(_token()).balanceOf(alice);
        safeSend.sendErc20Token(_token(), alice, TOKENS_TO_SEND);
        assertEq(IERC20(_token()).balanceOf(alice), balanceBefore + TOKENS_TO_SEND);
        vm.stopPrank();
    }

    function testSendErc20TokenEmitsAnEventIfSuccessful() public {
        vm.startPrank(user);
        _approveTokens(address(safeSend), TOKENS_TO_SEND);
        safeSend.addAddress(alice);
        vm.expectEmit(true, false, false, false);
        emit TokenSent(_token(), alice, TOKENS_TO_SEND);
        safeSend.sendErc20Token(_token(), alice, TOKENS_TO_SEND);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                          HELPERS
    //////////////////////////////////////////////////////////////*/
    // Child contracts must return their token + implement approve
    function _token() internal view virtual returns (address);
    function _approveTokens(address spender, uint256 amount) internal virtual;
}
