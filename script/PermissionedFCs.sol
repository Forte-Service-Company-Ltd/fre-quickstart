// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ExampleERC20Contract} from "../src/ExampleERC20Contract.sol";
import {ExampleERC721Contract} from "../src/ExampleERC721Contract.sol";
import {RulesEngineForeignCallAdmin} from "@thrackle-io/forte-rules-engine/src/client/RulesEngineForeignCallAdmin.sol";


struct ForeignCall {
    bool set;
    // Address of the contract to make the call to
    address foreignCallAddress;
    // The function signature of the foreign call
    bytes4 signature;
    // The parameter type of the foreign calls return
    ParamTypes returnType;
    // Unique identifier for the foreign contract structure (used by the rule to reference it)
    uint256 foreignCallIndex;
    // The parameter types of the arguments the foreign call takes
    ParamTypes[] parameterTypes;
    // A list of type specific indices to use for the foreign call and where they sit in the calldata
    ForeignCallEncodedIndex[] encodedIndices;
    // Tracks the index of the arguments that are mapped to a tracker
    ForeignCallEncodedIndex[] mappedTrackerKeyIndices;
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

struct ForeignCallEncodedIndex {
    EncodedIndexType eType;
    uint256 index;
}

enum EncodedIndexType {
    ENCODED_VALUES,
    FOREIGN_CALL,
    TRACKER,
    GLOBAL_VAR,
    MAPPED_TRACKER_KEY
}

enum PolicyType {
    CLOSED_POLICY,
    OPEN_POLICY,
    DISABLED_POLICY
}

interface RulesEngineForeignCallFacet {


    function createPolicy(PolicyType policyType, string calldata policyName, string calldata policyDescription) external returns (uint256);
    function createForeignCall(uint256 policyId, ForeignCall calldata foreignCall, string calldata foreignCallName) external returns (uint256);
}


contract ExampleUserScript is Script {
    ExampleERC20Contract public exampleERC20;
    ExampleERC721Contract public exampleERC721;
    address diamondSepolia = vm.envAddress("RULES_ENGINE_ADDRESS");
    address constant fcAddress = 0xB0a01858969e7c04B4257062Cb2E61Ec02254e8E;
    RulesEngineForeignCallAdmin rulesEngineForeignCallAdmin = RulesEngineForeignCallAdmin(fcAddress);
    function setUp() public {}

    function run() public {
        RulesEngineForeignCallFacet rulesEngineForeignCallFacet = RulesEngineForeignCallFacet(diamondSepolia);

        vm.startBroadcast(vm.envUint("PRIV_KEY"));
            rulesEngineForeignCallAdmin.setRulesEngineAddress(diamondSepolia);
            rulesEngineForeignCallAdmin.setForeignCallAdmin(vm.envAddress("USER_ADDRESS"), bytes4(keccak256("square(uint256)")));
            console.log("TransferFrom admin set");
            // to test this comment the below line out
            rulesEngineForeignCallAdmin.setForeignCallAdmin(vm.envAddress("FAKE_ADMIN_ADDRESS"), bytes4(keccak256("square(uint256)")));
            console.log("Square admin set");
        vm.stopBroadcast();

        vm.startBroadcast(vm.envUint("FAKE_ADMIN_PRIV_KEY"));
            uint policyId = rulesEngineForeignCallFacet.createPolicy(PolicyType.OPEN_POLICY, "Test Policy", "Test Policy Description");
            ParamTypes[] memory parameterTypes = new ParamTypes[](1);
            parameterTypes[0] = ParamTypes.UINT;
            ForeignCallEncodedIndex[] memory encodedIndices = new ForeignCallEncodedIndex[](1);
            encodedIndices[0] = ForeignCallEncodedIndex({eType: EncodedIndexType.ENCODED_VALUES, index: 0});
            ForeignCallEncodedIndex[] memory mappedTrackerKeyIndices = new ForeignCallEncodedIndex[](0);
            
            rulesEngineForeignCallFacet.createForeignCall(policyId, ForeignCall({
                set: true,
                foreignCallAddress: fcAddress,
                signature: bytes4(keccak256("square(uint256)")),
                returnType: ParamTypes.UINT,
                foreignCallIndex: 0,
                parameterTypes: parameterTypes,
                encodedIndices: encodedIndices,
                mappedTrackerKeyIndices: mappedTrackerKeyIndices
            }), "square(uint256)");
        vm.stopBroadcast();
    }
}