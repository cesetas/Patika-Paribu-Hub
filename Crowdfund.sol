// SPDX-License-Identifier: UNDEFINED
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.7;

contract Crowdfund {
    IERC20 public immutable token;
    
    uint public count;

    constructor (address _token) {
        token = IERC20(_token);
    }
    
    event Created(uint id, address indexed creator, uint fundGoal, uint32 startDate, uint32 endDate);
    event Canceled(uint id);
    event Funded(uint indexed id, address indexed funder, uint fundAmount);
    event Withdrawn(uint indexed id, address indexed withdrawer, uint fundAmount);
    event Claimed(uint id, address claimer);
    event Refunded(uint indexed id, address indexed refunder, uint refundAmount);

    struct Campaign{
        address creator;
        uint fundGoal;
        uint pledgedAmount;
        uint32 startDate;
        uint32 endDate;
        bool isClaimed;
    }
    mapping(uint => Campaign) public campaigns;
    mapping(uint=> mapping (address => uint)) public fundedCampaigns;

    function createCampaign(uint _fundGoal, uint32 _startDate, uint32 _endDate ) public{        
        require(_startDate >= block.timestamp, "Should not be start at past");
        require(_endDate > _startDate, "Should be a  valid date");
        require(_endDate <= block.timestamp + 90 days, "Should be less than 90 days");
        count += 1;
        campaigns[count] = Campaign(msg.sender, _fundGoal,0, _startDate, _endDate, false);
        emit Created(count, msg.sender, _fundGoal, _startDate, _endDate);
    }

    function cancelCampaign(uint _id) public{
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "Only creator can delete");
        require(campaign.startDate > block.timestamp, "Campaign is already started");
        delete campaigns[_id];
        emit Canceled(_id);
    }

    function fundCampaign(uint _id, uint _fundAmount) public{
        Campaign storage campaign = campaigns[_id];
        require(campaign.endDate >= block.timestamp, "Time is up");
        require(campaign.startDate < block.timestamp, "Campaig is not started");

        // campaign.pledgedAmount = _fundAmount;
        campaign.pledgedAmount += _fundAmount;
        fundedCampaigns[_id][msg.sender] += _fundAmount;
        token.transferFrom(msg.sender, address(this), _fundAmount);
        emit Funded(_id, msg.sender, _fundAmount);
    }

    function withdraw(uint _id, uint _fundAmount) public{
        Campaign storage campaign = campaigns[_id];
        require(campaign.endDate >= block.timestamp, "Should  be withdrawn before deadline");
        require(fundedCampaigns[_id][msg.sender] >= _fundAmount, "Insuficient fund");

        campaign.pledgedAmount -= _fundAmount;
        fundedCampaigns[_id][msg.sender] -= _fundAmount;
        token.transfer(msg.sender, _fundAmount);
        emit Withdrawn(_id, msg.sender, _fundAmount);
    }

    function claimFunds(uint _id) public{
        Campaign storage campaign = campaigns[_id];
        require(campaign.endDate < block.timestamp, "Should  be claimed after deadline");
        require(campaign.creator == msg.sender, "Only creator can claim");
        require(campaign.pledgedAmount >= campaign.fundGoal, "Insufficient funds");
        require(!campaign.isClaimed, "Already claimed");
        
        campaign.isClaimed = true;
        uint balance = campaign.pledgedAmount;
        campaign.pledgedAmount = 0;    
        token.transfer(msg.sender, balance);
        emit Claimed(_id, msg.sender);
    }

    function refund(uint _id) public{
        Campaign storage campaign = campaigns[_id];
        require(campaign.endDate < block.timestamp, "Should  be refunded after deadline");
        require(campaign.pledgedAmount < campaign.fundGoal, "Insufficient funds");
       
        uint balance = fundedCampaigns[_id][msg.sender];
        fundedCampaigns[_id][msg.sender] = 0;    
        token.transfer(msg.sender, balance);
        emit Refunded(_id, msg.sender, balance);
    }
}