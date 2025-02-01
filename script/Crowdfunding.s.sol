// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { CrowdfundingFactory } from "../src/Crowdfunding.sol"; 
import { console } from "forge-std/console.sol";

contract CrowdfundingScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey); 

        CrowdfundingFactory crowdfunding = new CrowdfundingFactory();

        console.log("Crowdfunding deployed at:", address(crowdfunding));

        vm.stopBroadcast();
    }
}
