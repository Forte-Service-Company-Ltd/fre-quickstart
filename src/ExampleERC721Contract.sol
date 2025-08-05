// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "src/RulesEngineIntegration.sol";
/**
 * An example contract that does nothing.
 * This contract is used to demonstrate the use of the `transfer` function.
 */

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ExampleERC721Contract is RulesEngineClientCustom, ERC721 {
    constructor() ERC721("ExampleERC721Contract", "EXC") {}
    
    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override checkRulesBeforetransferFrom(from, to, tokenId) {
        super.transferFrom(from, to, tokenId);
    }

    function approve(address spender, uint256 tokenId) public override {
        super.approve(spender, tokenId);
    }
    
}