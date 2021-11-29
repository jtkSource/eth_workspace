//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;
contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;

    /**
        Successful campaign if minimumContribution is met
        within the deadline

    **/
    uint public minimumContribution;
    uint public deadline; //timestamp
    uint public goal; // maximum amount to raise

    uint public raisedAmount; // public raised amount

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

}