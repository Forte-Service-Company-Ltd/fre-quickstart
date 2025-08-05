// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "src/RulesEngineIntegration.sol";
/**
 * An example contract that does nothing.
 * This contract is used to demonstrate the use of the `transfer` function.
 */

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ExampleERC20Contract is RulesEngineClientCustom, ERC20 {
    constructor() ERC20("ExampleERC20Contract", "EXC") {}
    
    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
    
    function transfer(address to, uint256 value) public checkRulesBeforetransfer(to, value) override returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public checkRulesBeforetransferFrom(from, to, value) override returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        return super.approve(spender, value);
    }
    
}

/*
Use of trackers of all supported types
Use for foreign calls
Use of mapped trackers of all supported key-value types
Use of foreign calls that have the result of other foreign calls as their parameters
Use of foreign calls that have trackers as their parameters (standard and mapped)
Use of global variables
Use of permissioned  foreign calls
Use of effects that contain revert and emit statments
Use of effects that contain foreign calls (with trackers and mapped trackers as their parameters)
Use of effects that contain tracker updates (mapped and standard)
*/
