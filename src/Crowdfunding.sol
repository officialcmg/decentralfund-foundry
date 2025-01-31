// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "./Campaign.sol"; // Import the Campaign contract

contract CrowdfundingFactory {

    address public owner;
    Campaign[] public campaigns;

    event CampaignCreated(
        address indexed campaignAddress, 
        address indexed creator, 
        uint256 goal, 
        uint256 deadline,
        string title, 
        string description
    );


    constructor() {
        owner = msg.sender; // Set the contract owner
    }

    // Function to create a new Campaign
    function createCampaign(
        uint256 _goal,
        uint256 _deadline,
        string memory _title,
        string memory _description
    ) external returns (address) {

        // Deploy the new Campaign contract
        Campaign newCampaign = new Campaign(
            msg.sender, // Creator is the one calling the function (whoever creates the campaign)
            _goal,
            _deadline,
            _title,
            _description
        );

        campaigns.push(newCampaign); // Add the new campaign to the campaigns array

        // Emit an event when a new campaign is created
        emit CampaignCreated(
            address(newCampaign), 
            msg.sender, 
            _goal, 
            _deadline,
            _title, 
            _description
        );

        return address(newCampaign); // Return the address of the newly created campaign
    }

    // Function to get the list of campaigns created by the factory
    function getCampaigns() external view returns (address[] memory) {
        address[] memory campaignAddresses = new address[](campaigns.length);

        for (uint256 i = 0; i < campaigns.length; i++) {
            campaignAddresses[i] = address(campaigns[i]);
        }

        return campaignAddresses;
    }
}
