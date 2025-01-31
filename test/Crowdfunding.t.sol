// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol"; // Foundry test framework
import "../src/Crowdfunding.sol";
import "../src/Campaign.sol";

contract CrowdfundingFactoryTest is Test {
    CrowdfundingFactory factory;
    address deployer;
    address user1;
    uint256 goal;
    uint256 deadline;
    string title;
    string description;

    function setUp() public {
        factory = new CrowdfundingFactory(); // Deploy the factory contract
        deployer = address(this);
        user1 = vm.addr(1); // Assign a test user

        goal = 10 ether; // Set a test goal
        deadline = block.timestamp + 1 days; // Set a test deadline
        title = "Test Campaign";
        description = "This is a test campaign.";
    }

    function testFactoryOwner() public view {
        assertEq(factory.owner(), deployer, "Owner should be deployer");
    }

    function testCreateCampaign() public {
        vm.startPrank(user1); // Simulate user1 calling the function
        address campaignAddress = factory.createCampaign(goal, deadline, title, description);
        vm.stopPrank();

        assertTrue(campaignAddress != address(0), "Campaign should be created with a valid address");
    }

    function testGetCampaigns() public {
        vm.startPrank(user1);
        address campaignAddress1 = factory.createCampaign(goal, deadline, title, description);
        address campaignAddress2 = factory.createCampaign(goal, deadline, title, description);
        vm.stopPrank();

        address[] memory campaigns = factory.getCampaigns();
        assertEq(campaigns.length, 2, "Should have two campaigns stored");
        assertEq(campaigns[0], campaignAddress1, "First campaign should match");
        assertEq(campaigns[1], campaignAddress2, "Second campaign should match");
    }
}
