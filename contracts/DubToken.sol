pragma solidity ^0.4.2;

import "./ConvertLib.sol";

contract DubToken {
	// This creates an array with all balances
	mapping (address => uint) public balanceOf;

	// Initializes contract with initial supply tokens to the creator of the contract
	function DubToken(uint initialSupply) {
		balanceOf[msg.sender] = initialSupply;  // Give the creator all initial tokens
	}

	// Send tokens
	function transfer(address _to, uint _value) {
		if (balanceOf[msg.sender] < _value) throw;				// Check if the sender has enough tokens
		if (balanceOf[_to] + _value < balanceOf[_to]) throw;	// Check for overflows
		balanceOf[msg.sedner] -= _value;						// Subtrack from the sender
		balanceOf[_to] += _value;								// Add the same to the recipient
	}
}
