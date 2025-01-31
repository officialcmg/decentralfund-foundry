// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol"; // Foundry test framework
import "../src/Campaign.sol";

contract CampaignTest is Test {
    Campaign campaign;
    address creator;
    address user1;
    address user2;
    uint256 goal;
    uint256 deadline;
    string title;
    string description;

    function setUp() public {
        creator = address(this);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        goal = 5 ether;
        deadline = block.timestamp + 1 days;
        title = "Test Campaign";
        description = "This is a test campaign";

        campaign = new Campaign(creator, goal, deadline, title, description);
    }

    function test_CampaignInitialization() public view {
        assertEq(campaign.creator(), creator, "Creator should be correct");
        assertEq(campaign.goal(), goal, "Goal should be correct");
        assertEq(campaign.deadline(), deadline, "Deadline should be correct");
    }

    function test_Donate() public {
        vm.deal(user1, 10 ether); // Give user1 10 ETH
        vm.prank(user1);
        campaign.donate{value: 3 ether}();

        assertEq(campaign.fundsRaised(), 3 ether, "Funds raised should be updated");
        assertEq(campaign.getContributionByAddress(user1), 3 ether, "User1 contribution should be recorded");
    }

    function test_WithdrawFunds() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        campaign.donate{value: 5 ether}();

        vm.warp(block.timestamp + 2 days); // Move time past deadline

        vm.prank(creator);
        campaign.withdrawFunds();

        assertEq(campaign.isFundsWithdrawn(), true, "Funds should be marked as withdrawn");
    }

    function test_EnableRefundsAndClaimRefund() public {
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.prank(user1);
        campaign.donate{value: 2 ether}();
        vm.prank(user2);
        campaign.donate{value: 2 ether}();

        vm.warp(block.timestamp + 2 days); // Move time past deadline
        vm.prank(creator);
        campaign.enableRefunds();

        assertEq(campaign.isRefundsEnabled(), true, "Refunds should be enabled");

        vm.prank(user1);
        campaign.claimRefund();
        assertEq(campaign.getContributionByAddress(user1), 0, "User1 should be refunded");

        vm.prank(user2);
        campaign.claimRefund();
        assertEq(campaign.getContributionByAddress(user2), 0, "User2 should be refunded");
    }

    function test_EnableRefundsAndRefundAll() public {
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.prank(user1);
        campaign.donate{value: 2 ether}();
        vm.prank(user2);
        campaign.donate{value: 2 ether}();

        vm.warp(block.timestamp + 2 days); // Move time past deadline
        vm.prank(creator);
        campaign.enableRefunds();

        assertEq(campaign.isRefundsEnabled(), true, "Refunds should be enabled");

        uint256 balanceBeforeUser1 = user1.balance;
        uint256 balanceBeforeUser2 = user2.balance;

        vm.prank(creator);
        campaign.refundAllContributors();

        assertGt(user1.balance, balanceBeforeUser1, "User1 should have received a refund");
        assertGt(user2.balance, balanceBeforeUser2, "User2 should have received a refund");
    }
}
