//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;
contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;

    /**
        Successful campaign if minimumContribution is met
        within the deadline
        One of the features of this contract is that the admin cannot 
        get the money without getting a majority vote from the contributors
        Unlike traditional systems which are honour based - here the control is 
        more on the user side

    **/
    uint public minimumContribution;
    uint public deadline; //timestamp
    uint public goal; // maximum amount to raise

    uint public raisedAmount; // public raised amount

    struct SpendingRequest{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        int noOfVoters;
        // latest solidity version doesnt allow storing struct with mapping attribute in arrays
        mapping(address => bool) voters;
    }

    mapping(uint => SpendingRequest) public spendingrequests;
    uint public numRequests;

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        // _deadline is in hours - which is added to block timestamp
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }

    function contribute() public payable{
        require(block.timestamp < deadline,"deadline has passed");
        require(msg.value >= minimumContribution," Minimum contribution not met! ");
        
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    receive() payable external{
        contribute();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }


    // when deadline is completed and goal wasnt reached
    function getRefund() public{
        require(block.timestamp > deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);
        contributors[msg.sender] = 0;

    }

    modifier onlyAdmin() {
        require(msg.sender == admin,"only admin can call this function");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) 
    public onlyAdmin{
        SpendingRequest storage newRequest = spendingrequests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0, "you must be a contributor to vote!");
        SpendingRequest storage thisRequest = spendingrequests[_requestNo];
        require(thisRequest.voters[msg.sender] == false, "You have already voted!!");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

}