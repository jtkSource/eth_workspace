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
        //eth number without suffix are assumed to be wei
        // 100000000000000000 in wei can be written as 0.1 ether
        require(msg.value >= 0.1 ether,"should send atleast 0.1 ether "); // will throw exception and transaction is reverted to inital state and consume all gas
        // convert plain address to a payable one
        players.push(payable(msg.sender));
    }

    fallback() external payable{

    }


    //returns the balance of the caller
    function getBalance() public view returns(uint){
        require(msg.sender == manager,"Only manager can view balance"); // only manager can see the balance
        return address(this).balance;
    }
}