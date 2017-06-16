pragma solidity ^0.4.2;

import "./owned.sol";

contract DubToken is owned {

	event Transfer(address indexed from, address indexed to, uint value);

	// This creates an array with all balances
	mapping (address => uint) public balanceOf;

	string public name;
	string public symbol;
	uint8 public decimals;
	uint public totalSupply;

	// Initializes contract with initial supply tokens to the creator of the contract
	function DubToken(uint initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol, address centralMinter) {
		if (centralMinter != 0) owner = centralMinter;
		balanceOf[msg.sender] = initialSupply;  // Give the creator all initial tokens
		name = tokenName;						// Set the name for display purposes
		symbol = tokenSymbol;					// Set the symbol for display purposes
		decimals = decimalUnits;				// Amount of decimals for display purposes
		totalSupply = initialSupply;
	}

	// Send tokens
	function transfer(address _to, uint _value) {
		if (balanceOf[msg.sender] < _value) throw;				// Check if the sender has enough tokens
		if (balanceOf[_to] + _value < balanceOf[_to]) throw;	// Check for overflows
		balanceOf[msg.sedner] -= _value;						// Subtrack from the sender
		balanceOf[_to] += _value;								// Add the same to the recipient
		Transfer(msg.sender, _to, _value);						// Notify listeners that the transfer took place
	}

	// Create more tokens
	function mintToken(address target, uint mintedAmount) onlyOwner {
		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		Transfer(0, owner, mintedAmount);
		Transfer(owner, target, mintedAmount);
	}
}
