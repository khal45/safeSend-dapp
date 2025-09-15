// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title SafeSend
 * @author khal45
 * @notice This is a contract for managing a list of whitelist addresses to help mitigate address poisoning.
 * @notice The contract allows a user to add a list of addresses to the whitelist which the user can then send eth or other evm tokens to
 * @dev Uses a simple mapping to store the addresses
 */
contract SafeSend is Ownable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error SafeSend__AddressAlreadyExists(address _user);
    error SafeSend__AddressNotWhitelisted(address _recipient);
    error SafeSend__TransferFailed();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    mapping(address => bool) private s_whitelist;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event AddressAdded(address indexed _newAddress);
    event EthSent(address indexed _recipient, uint256 _amount);
    event TokenSent(address indexed _tokenAddress, address indexed _recipient, uint256 _amount);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier checkAddress(address _recipient) {
        if (!s_whitelist[_recipient]) {
            revert SafeSend__AddressNotWhitelisted(_recipient);
        }
        _;
    }

    constructor(address owner) Ownable(owner) {}

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks if a user is part of the whitelist
     * @param _user The address to check if it is part of the whitelist
     */
    function isWhitelisted(address _user) external view returns (bool) {
        return s_whitelist[_user];
    }

    /**
     * @notice Adds an address to the whitelist
     * @param _newAddress The address to be added to the whitelist
     */
    function addAddress(address _newAddress) external onlyOwner {
        // Checks
        if (s_whitelist[_newAddress]) {
            revert SafeSend__AddressAlreadyExists(_newAddress);
        }
        // Effects
        s_whitelist[_newAddress] = true;
        emit AddressAdded(_newAddress);
    }

    /**
     * @notice Function to send ETH to a whitelisted address
     * @notice Should revert if address is not whitelisted
     * @notice Only the owner should be able to call this function
     * @param _recipient The address to receive eth
     */
    function sendEth(address _recipient) external payable onlyOwner checkAddress(_recipient) {
        (bool success,) = _recipient.call{value: msg.value}("");
        if (!success) {
            revert SafeSend__TransferFailed();
        }
        emit EthSent(_recipient, msg.value);
    }

    /**
     * @notice Function that handles sending erc20 tokens to a whitelisted address
     * @notice Should revert if the `_recipient` is not whitelisted
     * @notice Only the owner should be able to call this function
     * @dev Uses `transferFrom` to send the tokens from the owner to the recipient. The owner would have to approve the contract to spend their tokens
     * @param _tokenAddress Address of the erc20 token to be sent
     * @param _recipient The recieving address of the erc20 token
     * @param amount The amount of the erc20 tokens to be sent
     */
    function sendErc20Token(address _tokenAddress, address _recipient, uint256 amount)
        external
        onlyOwner
        checkAddress(_recipient)
    {
        IERC20(_tokenAddress).safeTransferFrom(owner(), _recipient, amount);
        emit TokenSent(_tokenAddress, _recipient, amount);
    }
}
