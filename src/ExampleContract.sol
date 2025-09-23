// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
/**
 * An example contract that does nothing.
 * This contract is used to demonstrate the use of the `transfer` function.
 */

contract ExampleContract {
    function transfer(address to, uint256 value, bytes memory data) public returns (bool) {
        // this function is purposefully empty
        return true;
    }
}
