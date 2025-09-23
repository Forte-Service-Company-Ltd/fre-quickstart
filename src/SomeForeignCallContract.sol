// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {RulesEngineForeignCallAdmin} from "@fortefoundation/forte-rules-engine/src/client/RulesEngineForeignCallAdmin.sol";


contract SomeForeignCallContract is RulesEngineForeignCallAdmin {

    uint256 value;
    bytes public someMsgData;

    function someFunction() public returns (bool) {
        return true;
    }

    function aSetterFunction(uint256 value) public {
        value = value + 1;
    }

    function aGetterFunction() public view returns (uint256) {
        return value;
    }

    function setSomeMsgData(bytes memory data) public {
        someMsgData = data;
    }

}