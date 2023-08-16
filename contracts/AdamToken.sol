// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdamToken{
    uint256 public initialTokenSupply = 1000000;
    uint256 faucetAmount = 10000;
    uint256 public constant transactionFeePercent = 1;
    string constant ticker = "$ADAM";

    mapping(address => uint256) public ledger;
    mapping(address => bool) public receivedCoin;

    address public immutable owner;

    // constructor gets called immediately after a contract is deployed
    constructor(){
        owner = msg.sender;
    }

    function faucet(address walletAddress) public{
        require(receivedCoin[walletAddress] != true, "Your wallet already received funds");
        initialTokenSupply -= faucetAmount;
        ledger[walletAddress] += faucetAmount;
    }

    function transfer(address walletAddress, uint256 amount) public payable{
        // from every transaction a small amount (1%) of coins are sent to the contract address
        // the owner of the (person who deployed the wallet is then able to burn the coins and increase the demand of the coin
        // or be added to the faucet to create equilibrium between coins burnt and tokens minted
        uint256 transactionFee = (amount/100);
        uint256 totalTransactionAmount = amount + transactionFee;
        require(ledger[msg.sender] >= totalTransactionAmount, "Your wallet does not have the funds for this transaction");
        // take the amount from the sender
        ledger[msg.sender] -= totalTransactionAmount;
        // add the amount to the contract and the receiver
        ledger[address(this)] += transactionFee;
        ledger[walletAddress] += amount;
    }

    // function to tell the user how many tokens they have w/ the ticker
    function tokenAmount(address walletAddress) public view returns (uint256){
        uint256 walletAmount = ledger[walletAddress];
        return walletAmount;
    }

    // function to allow the owner of the contract to burn tokens
    function burnTokens() public isOwner{
        // remove all the tokens from the contract address, do not add it back into the supply
        ledger[address(this)] = 0;
    }
    
    // function to allow the owner of the contract to remint the tokens that they recieve from the 
    function remintTokens() public isOwner{
        // re add the contract within 
        initialTokenSupply += ledger[address(this)];
        ledger[address(this)] = 0;
    }
    
    modifier isOwner{
        require(msg.sender == owner, "You do not have access to this function as you are not the owner of this smart contract.");
        _;
    }
}
