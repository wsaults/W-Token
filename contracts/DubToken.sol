pragma solidity ^0.4.2;

import "./owned.sol";

contract DubToken is owned {

	event Transfer(address indexed from, address indexed to, uint value);
	event FrozenFunds(address target, bool frozen);

	// This creates an array with all balances
	mapping (address => uint) public balanceOf;
	mapping (address => bool) public frozenAccount;

	string public name;
	string public symbol;
	uint8 public decimals;
	uint public totalSupply;
	uint public sellPrice;
	uint public buyPrice;

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
		if (frozenAccount[msg.sender]) throw;					// Throw if the account is frozen
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

	// Freeze account
	function freezeAccount(address, target, bool freeze) onlyOwner {
		frozenAccount[target] = freeze; // Freeze or unfreeze account
		FrozenFunds(target, freeze);	// Fire event for account frozen status
	}

	// Set buy and sell prices
	// Checkout this url for Data feed examples:
	// https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs#data-feeds
	function setPrices(uint newSellPrice, uint newBuyPrice) onlyOwner {
		sellPrice = newSellPrice;
		buyPrice = newBuyPrice;
	}

	function buy() payable returns (uint amount) {
		amount = msg.value / buyPrice;				// calculates the amount
		if (balanceOf[this] < amount) throw;		// checks if it has enough to sell
		balanceOf[msg.sender] += amount;			// adds the amount ot buyer's balance
		balanceOf[this] -= amount;					// subtracts amount from seller's balance
		Transfer(this, msg.sender, amount);			// execute an event reflecting the change
		return amount;								// ends function and returns.
	}

	/*

	Note Buy and sell "prices" are not set in ether, but in wei the minimum currency of the system 
	(equivalent to the cent in the Euro and Dollar, or the Satoshi in Bitcoin). 
	One ether is 1000000000000000000 wei. So when setting prices for your token in ether, 
	add 18 zeros at the end.		

	*/ 

	function sell(uint amount) returns (uint revenue) {
		if (balanceOf[msg.sender] < amount) throw;		// checks if the sender has enough to sell
		balanceOf[this] += amount;						// adds the amount to the owner's balance
		balanceOf[msg.sender] -= amount;				// subtracts the amount form the seller's balance
		revenue = amount * sellPrice;
		if (!msg.sender.send(revenue)) {				// sends ether to the seller: it's important
			throw;										// to do this last to prevent recursion attacks
		} else {
			Transfer(msg.sender, this, amount);			// executes an event reflecting on the change
			return revenue;								// ends function and returns
		}	
	}
}
