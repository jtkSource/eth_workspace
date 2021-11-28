//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    // addresses from where bids can be placed
    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender; // owner of the contract
    }   

// enable receiving eth
    receive() external payable{
        // convert plain address to a payable one
        players.push(payable(msg.sender));
    }

    fallback() external payable{
        
    }


    //returns the balance of the caller
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}