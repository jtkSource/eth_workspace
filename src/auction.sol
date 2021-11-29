//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    // hash for the inter-platenary-filesystem
    string public ipfsHash;
    enum State {Started, Running, Ended, Cancelled}
    State public auctionState;
    uint public highestBindingBid;
    address payable public highestBidder;
    mapping(address => uint) public bids;
    uint bidIncrement;

    constructor(){
        owner = payable(msg.sender);
        auctionState = State.Running;
        startBlock = block.number;
        // assumes that the block is generated every 50s
        // calculate number of blocks created in a week
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 100; //wei
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    // function modifier to check if bidder is not owner
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }

    // block should be after the start block
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }

// block should before the endblock 
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    // user need to place a bid greater than 100 wei
    // user needs to place a bid higher than the current highestBindingBid

    function placeBid() public payable notOwner afterStart beforeEnd{
        require(auctionState == State.Running);
        require(msg.value >= 100);
        // default value map is zero so for a 
        // non-existant sender it would be zero
        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid,
           string( abi.encodePacked("currentBid should be higher than higestBindingBid: ", highestBindingBid)));
        bids[msg.sender] = currentBid;
        highestBindingBid = currentBid + bidIncrement;
        highestBidder = payable(msg.sender);
    }


    function cancelAuction() public onlyOwner {
        auctionState = State.Cancelled;
    }

    function finalizeAuction() public{
        require(auctionState == State.Cancelled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        address payable recipient;
        uint value;

        if(auctionState == State.Cancelled) {
            // if cancelled all users can get their respective bid
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        }else {
            // auction ended - not cancelled
            // highest bidder should only get the money
            // this is a highest bidder
            if(msg.sender == highestBidder){
                recipient = highestBidder;
                value = bids[highestBidder];
                
            }
        }
        recipient.transfer(value);
    }
}