// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

struct Trackers {
    // Whether the tracker has been set
    bool set;
    // Define what type of tracker
    ParamTypes pType; // determine the type of tracker value
    bool mapped; // if true, the tracker is using top level mapping: mappedTrackerValues
    ParamTypes trackerKeyType; // if mapped, this is the type of the key used in the mapping
    // tracker types arrays
    bytes trackerValue;
    // to be added: uint lastUpdatedTimestamp;
    uint256 trackerIndex;
}

enum ParamTypes {
    ADDR,
    STR,
    UINT,
    BOOL,
    VOID,
    BYTES,
    STATIC_TYPE_ARRAY,
    DYNAMIC_TYPE_ARRAY
}

interface RulesEngineComponentFacet {
    function getAllTrackers(uint256 policyId) external view returns (Trackers[] memory); 
}


contract GetAllTrackers is Script {
    RulesEngineComponentFacet public rulesEngineComponentFacet = RulesEngineComponentFacet(vm.envAddress("RULES_ENGINE_ADDRESS"));

    function run() public {
        console.log("Getting all trackers");
        Trackers[] memory trackers = rulesEngineComponentFacet.getAllTrackers(20);
        for (uint256 i = 0; i < trackers.length; i++) {
            console.log("Tracker", i);
            console.log("Set", trackers[i].set);
            console.log("Type", uint(trackers[i].pType));
            console.log("Mapped", trackers[i].mapped);
            console.log("Key Type", uint(trackers[i].trackerKeyType));
            console.log("value");
            console.logBytes(trackers[i].trackerValue);
        }
    }
}