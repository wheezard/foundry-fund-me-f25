// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. keep track of contract addresses across different chains
// 3. Sepolia ETH/USD
// 4. MAINNET ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil chain, we deploy mocks
    // otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // 2000.00000000

    struct NetworkConfig{
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEThConfig();
        } else if (block.chainid == 1)
            activeNetworkConfig = getMainnetEThConfig();
        
          else {
            activeNetworkConfig = getorCreateAnvilEThConfig();
        }
        }
    

    function getSepoliaEThConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return SepoliaConfig;
    }

    function getMainnetEThConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory EthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return EthConfig;
    }

    function getorCreateAnvilEThConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

         // 1. Deploy the mocks
         // 2. Return the mock's addresses

         vm.startBroadcast();
         MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
             INITIAL_PRICE
             );
         vm.stopBroadcast(); 

            NetworkConfig memory anvilConfig = NetworkConfig({
                priceFeed: address(mockPriceFeed)
    });
        return anvilConfig;
    }
}
    
