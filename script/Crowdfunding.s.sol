// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { CrowdfundingFactory } from "../src/Crowdfunding.sol"; // Update path if needed
import { console } from "forge-std/console.sol";

contract CrowdfundingScript is Script {
    function run() external {
        vm.startBroadcast(); // Use private key from env or CLI

        CrowdfundingFactory crowdfunding = new CrowdfundingFactory();

        console.log("Crowdfunding deployed at:", address(crowdfunding));

        vm.stopBroadcast();
    }
}
