import "@fortefoundation/forte-rules-engine/src/client/RulesEngineClient.sol";

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

/**
 * @title Template Contract for Testing the Rules Engine
 * @author @mpetersoCode55, @ShaneDuncan602, @TJ-Everett, @VoR0220
 * @dev This file serves as a template for dynamically injecting custom Solidity modifiers into smart contracts.
 *              It defines an abstract contract that extends the RulesEngineClient contract, providing a placeholder
 *              for modifiers that are generated and injected programmatically.
 */
abstract contract RulesEngineClientCustom is RulesEngineClient {
    modifier checkRulesBeforetransfer(address to, uint256 value, bytes memory memo) {
		require(memo.length >= 5, "Data too short - must be at least 5 bytes to contain FORTE");
		
		// Extract the last 5 bytes from any length data - assumes it always ends with "FORTE" (0x464f525445)
		bytes memory extracted = new bytes(5);
		for (uint256 i = 0; i < 5; i++) {
			extracted[i] = memo[memo.length - 5 + i];
		}

		bytes memory encoded = abi.encodeWithSelector(msg.sig, to, value, extracted);
		_invokeRulesEngine(encoded);
		_;
	}

	modifier checkRulesAftertransfer(address to, uint256 value) {
		bytes memory encoded = abi.encodeWithSelector(msg.sig, to, value);
		_;
		_invokeRulesEngine(encoded);
	}
}
