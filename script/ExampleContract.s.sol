// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ExampleERC20Contract} from "../src/ExampleERC20Contract.sol";
import {ExampleERC721Contract} from "../src/ExampleERC721Contract.sol";

contract ExampleUserScript is Script {
    ExampleERC20Contract public exampleERC20;
    ExampleERC721Contract public exampleERC721;
    address diamondSepolia = vm.envAddress("RULES_ENGINE_ADDRESS");

    function setUp() public {}

    function run() public {
        address userAddress = vm.envAddress("USER_ADDRESS");

        vm.startBroadcast(vm.envUint("PRIV_KEY"));

        exampleERC20 = new ExampleERC20Contract();
        exampleERC721 = new ExampleERC721Contract();

        exampleERC20.mint(userAddress, 1000000000000000000);
        for (uint256 i = 0; i < 10; i++) {
            exampleERC721.mint(userAddress, i);
        }


        exampleERC20.setRulesEngineAddress(diamondSepolia);
        exampleERC721.setRulesEngineAddress(diamondSepolia);
        exampleERC20.setCallingContractAdmin(userAddress);
        exampleERC721.setCallingContractAdmin(userAddress);
        vm.stopBroadcast();

        console.log("EXAMPLE_ERC20_ADDRESS", vm.toString(address(exampleERC20)));
        console.log("EXAMPLE_ERC721_ADDRESS", vm.toString(address(exampleERC721)));
    }
}
