# Crowdfunding Smart Contract

## Overview
This project implements a decentralized crowdfunding platform using Solidity smart contracts. It consists of two main contracts:
- **CrowdfundingFactory**: A factory contract responsible for creating and managing individual crowdfunding campaigns.
- **Campaign**: A contract representing an individual crowdfunding campaign with donation, refund, and withdrawal functionalities.

## Architecture
The project follows a factory-based design pattern, where the `CrowdfundingFactory` deploys new `Campaign` instances. Each campaign is a standalone smart contract with its own state and logic.

### Contracts

#### 1. CrowdfundingFactory
This contract acts as the entry point for campaign creation. It stores deployed campaign instances and provides functions to retrieve them.

- **State Variables:**
  - `owner`: The address of the factory owner.
  - `campaigns`: A list of deployed `Campaign` contract addresses.

- **Functions:**
  - `createCampaign(uint256 _goal, uint256 _deadline, string _title, string _description)`: Deploys a new `Campaign` contract.
  - `getCampaigns()`: Returns a list of deployed campaign contract addresses.

- **Events:**
  - `CampaignCreated`: Emitted when a new campaign is created.

#### 2. Campaign
This contract represents a crowdfunding campaign. It allows users to donate funds and provides refund mechanisms if the goal is not reached by the deadline.

- **State Variables:**
  - `creator`: The campaign owner.
  - `goal`: The fundraising goal in ETH.
  - `deadline`: The campaign deadline timestamp.
  - `fundsRaised`: The total funds collected.
  - `isGoalReached`: Whether the goal has been met.
  - `isRefundsEnabled`: Whether refunds have been enabled.
  - `contributors`: A list of contributors.
  - `contributions`: Mapping of contributors and their respective donations.

- **Functions:**
  - `donate()`: Allows users to donate ETH to the campaign.
  - `withdrawFunds()`: Allows the creator to withdraw funds if the goal is met.
  - `enableRefunds()`: Allows the creator to enable refunds.
  - `refundAllContributors()`: Refunds all contributors.
  - `claimRefund()`: Allows an individual contributor to claim a refund.
  - `updateTitleAndDescription(string _title, string _description)`: Updates the campaign title and description.
  - `getContributionByAddress(address _address)`: Returns the amount contributed by a specific address.

- **Events:**
  - `ContributorDonates`: Emitted when a user donates.
  - `ContributorRefunded`: Emitted when a contributor receives a refund.
  - `FundsWithdrawn`: Emitted when funds are withdrawn by the creator.
  - `RefundsEnabled`: Emitted when refunds are enabled.
  - `RefundedAllContributors`: Emitted when all contributors are refunded.

## UML Diagram
Below is a UML representation of the contract relationships and interactions:

![image](https://github.com/user-attachments/assets/b92629e4-d726-430d-87f2-a7666411d32e)


## Deployment

To deploy the `CrowdfundingFactory` contract:
```sh
forge script script/Crowdfunding.s.sol:CrowdfundingScript \
  --rpc-url https://rpc.sepolia-api.lisk.com \
  --broadcast
```

To verify the contract on Lisk Sepolia Blockscout:
```sh
forge create --rpc-url https://rpc.sepolia-api.lisk.com \
  --etherscan-api-key 123 \
  --verify \
  --verifier blockscout \
  --verifier-url https://sepolia-blockscout.lisk.com/api \
  --private-key $PRIVATE_KEY \
  src/Crowdfunding.sol:CrowdfundingFactory
```

## License
This project is licensed under the MIT License.

