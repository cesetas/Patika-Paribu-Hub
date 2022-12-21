// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract EtherStore {

    //These are state variables
    address public owner;
    uint public balance;

    // With deployment of contract owner is created
    constructor (){
        owner = msg.sender;
    }

    //Since this will be a payable contract,
    //receive function is needed 
    receive() payable external {
        balance += msg.value;
    }

    //Only owner is able to send any amount 
    //less than balance to any address
    function withdraw (uint amount, address payable to) external {
        require(msg.sender==owner,  "You are not owner"); //To block other user except owner to withdraw
        require(amount <= balance,  "Insufficient balance" ); //Should be enoug balance to withdraw
        
        balance -= amount;
        to.transfer(amount); //this commit transfer        
    }

}
