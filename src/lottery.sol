//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{
    // addresses from where bids can be placed
    address payable[] public players;
    address payable public manager;

    constructor(){
        manager = payable(msg.sender); // owner of the contract
        
        // add manager to the lottery
        players.push(manager);

    }   

// enable receiving eth
    receive() external payable{
        
        require(msg.sender != manager,"Manager cannot participate in the lottery");
        //eth number without suffix are assumed to be wei
        // 100000000000000000 in wei can be written as 0.1 ether
        require(msg.value == 0.1 ether,"should send 0.1 ether "); // will throw exception and transaction is reverted to inital state and consume all gas
        
        // convert plain address to a payable one
        players.push(payable(msg.sender));
    }

    fallback() external payable{}

    //returns the balance of the caller
    function getBalance() public view returns(uint){
        require(msg.sender == manager,"Only manager can view balance"); // only manager can see the balance
        return address(this).balance;
    }

    // should use chainlink to generate random number 
    // https://docs.chain.link/docs/get-a-random-number/
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    function pickWinner() public{
        //anyone can pickwinner if there is more than 10 players
            if(players.length < 10){
                require(msg.sender == manager);
            }
            require(players.length  >= 3);
            uint r = random();
            address payable winner;
            uint index = r % players.length;
            winner = players[index];
            uint balance = getBalance();
            uint managerPayout = (balance/10);
            uint playerPayout = balance - managerPayout;
            winner.transfer(playerPayout);
            manager.transfer(managerPayout);
            players = new address payable[](0);
        }
   }