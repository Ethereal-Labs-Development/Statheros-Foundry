// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

//import "./Utility.sol";

import "../src/Treasury.sol";

import "../src/users/Actor.sol";


contract TreasuryTest is Test {

    address constant DAI   = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT  = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant FRAX  = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant WBTC  = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address constant TUSD  = 0x0000000000085d4780B73119b644AE5ecd22b376;

    Actor  dev = new Actor(); // Owner/Dev
    Actor  arn = new Actor(); // Aaron/Admin
    Actor  mgr = new Actor(); // Account Manager
    Actor  joe = new Actor(); // Normal User

    Treasury treasury;

    function setUp() public {

        treasury = new Treasury(
            USDC
        );

    }

}
