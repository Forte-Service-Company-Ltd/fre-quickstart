// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import 'src/RulesEngineIntegration.sol';
/**
 * An example contract that does nothing.
 * This contract is used to demonstrate the use of the `transfer` function.
 */

contract ExampleContract is RulesEngineClientCustom {
  address public owner;

  modifier onlyOwner() {
    require(msg.sender == owner, 'Not the owner');
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  /**
   * @notice This function overrides a function in the RulesEngineClient and must be updated for successful compilation.
   */
  function setCallingContractAdmin(address callingContractAdmin) public override onlyOwner {
    super.setCallingContractAdmin(callingContractAdmin);
  }

  function transfer(address to, uint256 value) public checkRulesBeforetransfer(to, value) returns (bool) {
    // this function is purposefully empty
    return true;
  }
}
