// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Campaign is ReentrancyGuard {
    address public creator;

    address[] public contributors;
    mapping(address => uint256) public contributions;

    uint256 public goal; // in ETH
    uint256 public deadline;   // in blockTimeStamp
    uint256 public fundsRaised;  // in ETH

    bool public isGoalReached;
    bool public isFundsWithdrawn;
    bool public isRefundsEnabled;
    bool public isCompleted;
    
    string public title;
    string public description;
    
    event ContributorDonates(address indexed contributor, uint256 amount);
    event ContributorRefunded(address indexed contributor, uint256 amount);
    event FundsWithdrawn(address indexed creator, uint256 amount);
    event RefundsEnabled();
    event RefundedContributor(address indexed contributor, uint256 amount);
    event RefundedAllContributors(bool allContributorsRefunded, uint256 amount, uint256 raisedAmount);

    modifier onlyCreator() {
        require(msg.sender == creator, "Not the campaign creator");
        _;
    }

    modifier onlyBeforeDeadline() {
        require(block.timestamp <= deadline, "Deadline has passed");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp > deadline, "Deadline not reached");
        _;
    }

    constructor(
        address _creator, 
        uint256 _goal, 
        uint256 _deadline,
        string memory _title,
        string memory _description
    ) {
        require(_goal > 0, "Goal must be greater than 0");
        require(_deadline > block.timestamp, "Invalid deadline");
        creator = _creator;
        goal = _goal;
        deadline = _deadline;
        title = _title;
        description = _description;
    }

    receive() external payable {
        donate();
    }

    function withdrawFunds() external nonReentrant onlyCreator onlyAfterDeadline {
        require(!isFundsWithdrawn, "Funds already withdrawn");
        isFundsWithdrawn = true;
        (bool sent, ) = creator.call{value: fundsRaised}("");
        require(sent, "Failed to withdraw Ether"); // Revert on failure
        
        emit FundsWithdrawn(creator, fundsRaised);
        isCompleted = true;
    }

    // Function for the creator to enable refunds for all contributors
    function enableRefunds() external onlyCreator onlyAfterDeadline {
        require(!isGoalReached, "Goal was reached; no refunds possible");
        require(!isRefundsEnabled, "Refunds already enabled");
        isRefundsEnabled = true;
        emit RefundsEnabled();
    }


    function refundAllContributors() external onlyCreator {
        require(isRefundsEnabled, "Refunds not enabled by creator");
        uint256 totalRefund = 0;
        
        for (uint i = 0; i < contributors.length; i++){
            uint contributedAmount = contributions[contributors[i]];
            
            if(contributedAmount > 0) {
                _helperRefund(contributors[i]); // Refund all the contributor's funds
                totalRefund += contributedAmount;
            }
        }
        bool allContributorsRefunded = totalRefund < fundsRaised;
        emit RefundedAllContributors(allContributorsRefunded, totalRefund, fundsRaised);

    }

    function claimRefund() external {
        require(isRefundsEnabled, "Refunds not enabled by creator");
        uint256 contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "No funds to refund");
        _helperRefund(msg.sender);
        emit RefundedContributor(msg.sender, contributedAmount);
    }

    function updateTitleAndDescription(string memory _title, string memory _description) external {
        title = _title;
        description = _description;
    }

    function getTitleAndDescription() external view returns (string memory , string memory ) {
        return (title, description);
    }

    function getContributionByAddress(address _address) external view returns(uint256) {
        return (contributions[_address]);
    }

    function donate() public payable onlyBeforeDeadline {
        require(msg.value > 0, "Must send ETH to fund");
        contributors.push(msg.sender);
        contributions[msg.sender] += msg.value;
        fundsRaised += msg.value;
        emit ContributorDonates(msg.sender, msg.value);

        if (fundsRaised >= goal) {
            isGoalReached = true;
        }
    }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function _helperRefund(address _contributor) internal nonReentrant {
        uint256 contributedAmount = contributions[_contributor];
        contributions[_contributor] = 0;
        (bool sent, ) = _contributor.call{value:contributedAmount}("");
        require(sent, "failed to send Ether refund");

        if (address(this).balance == 0) {
            isCompleted = true;
        }
    }

}