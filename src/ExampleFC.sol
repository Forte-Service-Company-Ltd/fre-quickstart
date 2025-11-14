import "@fortefoundation/forte-rules-engine/src/client/RulesEngineForeignCallAdmin.sol";

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @title Example contract for testing the Rules Engine
 * @dev This contract provides the ability to test the rules engine with an external contract
 * @author @TJ-Everett 
 */
contract ExampleFCContract is RulesEngineForeignCallAdmin {
    uint256 public countValue;

    event ForeignCallReceived(bytes data, address sender);
    event ForeignCallResult(bool result);

    /**
     @dev This is a generic function for rules engine testing 
     */
    function count(uint256 value) public  {
        countValue = value;
    }

    /**
     @dev This is a generic function for rules engine testing 
     */
    function permissionedCount() public returns (uint256) {
       if(countValue < 2) {
            countValue += 1;
       }
        return countValue;
    }

    /**
     @dev This is a generic function for rules engine testing 
     */
    function compareBytes(bytes memory value) public returns (bool) {
        emit ForeignCallReceived(value, msg.sender);
        bytes memory compareTo = "FORTE";
        bool result = keccak256(value) == keccak256(compareTo);
        emit ForeignCallResult(result);
        return result;
    }

    /**
     @dev Getter function for countValue
     */
    function getCount() public view returns (uint256) {
        return countValue;
    }
}
