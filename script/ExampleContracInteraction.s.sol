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
        address exampleERC20Address = vm.envAddress("EXAMPLE_ERC20_ADDRESS");
        address exampleERC721Address = vm.envAddress("EXAMPLE_ERC721_ADDRESS");
        exampleERC20 = ExampleERC20Contract(exampleERC20Address);
        exampleERC721 = ExampleERC721Contract(exampleERC721Address);
        console.log("exampleERC20Address: ", exampleERC20Address);
        console.log("exampleERC721Address: ", exampleERC721Address);
        console.log("balanceOf: ", exampleERC20.balanceOf(userAddress));
        vm.startBroadcast(vm.envUint("PRIV_KEY"));

        exampleERC20.transfer(address(0xdeadbeefdeadbeef), 101);

        // exampleERC721.approve(address(0xdeadbeefdeadbeef), 2);
        // exampleERC721.transferFrom(userAddress, address(0xdeadbeefdeadbeef), 2);
        vm.stopBroadcast();
    }
}