pragma >=0.5.0 <0.9.0;

contract Lottery{
    // addresses from where bids can be placed
    address payable[] public players;
    address public manager;

    constructor(){
        manager = msg.sender; // owner of the contract
    }   
    
}