// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";
//import "./Utility.sol";

import "../src/Stake.sol";
import "../src/Treasury.sol";
import "../src/StathToken.sol";

import "../src/users/Actor.sol";

contract StakeTest is Test {

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

    Stake stake;
    Treasury treasury;
    StathToken stathToken;

    function setUp() public {

        stathToken = new StathToken();
        treasury = new Treasury(USDC);

        stake = new Stake(
            USDC,
            address(treasury),
            address(stathToken),
            address(dev)
        );
    }

    // Verify initial state of stake contract.
    function test_stake_init_state() public {
        assertEq(stake.stableCurrency(), USDC);
        assertEq(stake.treasury(), address(treasury));
        assertEq(stake.soulboundToken(), address(stathToken));
        assertEq(stake.owner(), address(dev));
        assertTrue(!stake.stakingEnabled());
    }

    // ~ updateTreasury() Testing ~

    // updateTreasury state check.
    function test_stake_updateTreasury_state_changes() public {
        //Pre-State check: Verify address(1) is not treasury.
        assert(stake.treasury() != address(1));

        //State Change: "dev" will call updateTreasury to update the treasury to address(1).
        assert(dev.try_updateTreasury(address(stake), address(1)));

        //Post-State check: Verify address(1) is now the treasury.
        assert(stake.treasury() == address(1));
    }

    // updateTreasury restrictions
    function test_stake_updateTreasury_restrictions() public {
        // Verify you cannot set the same address.
        assert(!dev.try_updateTreasury(address(stake), stake.treasury()));

        // Verify you cannot set to the stablecoin.
        assert(!dev.try_updateTreasury(address(stake), stake.stableCurrency()));

        // Verify you cannot set to $STATH.
        assert(!dev.try_updateTreasury(address(stake), stake.soulboundToken()));

        // Verify you cannot set to the stake address.
        assert(!dev.try_updateTreasury(address(stake), address(stake)));

        // Verify users cannot call this function.
        assert(!joe.try_updateTreasury(address(stake), address(1)));

        // Verify admins cannot call this function.
        assert(!arn.try_updateTreasury(address(stake), address(1)));

        // Verify managers cannot call this function.
        assert(!mgr.try_updateTreasury(address(stake), address(1)));
    }

    // ~ updateTokenWhitelist() Testing ~

    // updateTokenWhitelist state checks.
    function test_stake_updateTokenWhitelist_state_changes() public {
        //Pre-State: no tokens have been added, so all should be false.
        assert(!stake.tokenWhitelist(address(WBTC)));

        //State Change: add token with address 1 to the whitelist.
        assert(dev.try_updateTokenWhitelist(address(stake), address(WBTC), true));

        //Post-State: token with address 1 has been added and should be true.
        assert(stake.tokenWhitelist(address(WBTC)));

        //State Change: remove token with address 1 from the whitelist.
        assert(dev.try_updateTokenWhitelist(address(stake), address(WBTC), false));

        //Post-State: token with address 1 has been removed and should be false.
        assert(!stake.tokenWhitelist(address(WBTC)));
    }

    // updateTokenWhitelist restrictions.
    function test_stake_updateTokenWhitelist_restrictions() public {
        // Verify dev cannot add Stake.sol address to whitelist.
        assert(!dev.try_updateTokenWhitelist(address(stake), address(stake), true));

        // Verify dev cannot add Treasury to whitelist.
        assert(!dev.try_updateTokenWhitelist(address(stake), stake.treasury(), true));

        // Verify dev cannot add $STATH to whitelist.
        assert(!dev.try_updateTokenWhitelist(address(stake), stake.soulboundToken(), true));

        // Verify dev can add address(1) to whitelist.
        assert(dev.try_updateTokenWhitelist(address(stake), address(WBTC), true));

        // Verify admins cannot call this function.
        assert(!arn.try_updateTokenWhitelist(address(stake), address(WBTC), true));

        // Verify managers cannot call this function.
        assert(!mgr.try_updateTokenWhitelist(address(stake), address(WBTC), true));

        // Verify users cannot call this function.
        assert(!joe.try_updateTokenWhitelist(address(stake), address(WBTC), true));
    }

    // ~ updateStableCurrency() Testing ~

    // updateStableCurrency() state checks.
    function test_stake_updateStableCurrency_state_changes() public {
        // Pre-State: USDC should be the current stable currency of the Stake.sol contract.
        assertEq(stake.stableCurrency(), USDC);

        // State Change: Update the stable currency from USDC to USDT.
        dev.try_updateStableCurrency(address(stake), USDT);

        // Post-State: Confirm that the new stable currency is equivalent to USDT.
        assertEq(stake.stableCurrency(), USDT);
        
        // State Change: Change the stable currency from USDT back to USDC.
        dev.try_updateStableCurrency(address(stake), USDC);

        // Post-State: confirm that the new stable currency is equivalent to USDC.
        assertEq(stake.stableCurrency(), USDC);
    }

    // updateStableCurrency() restrictions.
    function test_stake_updateStableCurrency_restrictions() public {
        // Verify dev cannot update stable currency to the same stable currency.
        assert(!dev.try_updateStableCurrency(address(stake), USDC));

        // Verify dev cannot update stable currency to Stake.sol address.
        assert(!dev.try_updateStableCurrency(address(stake), address(stake)));

        // Verify dev cannot update stable currency to Treasury.
        assert(!dev.try_updateStableCurrency(address(stake), stake.treasury()));

        // Verify dev cannot update stable currency to $STATH.
        assert(!dev.try_updateStableCurrency(address(stake), stake.soulboundToken()));

        // Verify dev can update stable currency to USDT.
        assert(dev.try_updateStableCurrency(address(stake), USDT));

        // Verify admin cannot update stable currency.
        assert(!arn.try_updateStableCurrency(address(stake), USDT));

        // Verify manager cannot update stable currency.
        assert(!mgr.try_updateStableCurrency(address(stake), USDT));

        // Verify users cannot update stable currency.
        assert(!joe.try_updateStableCurrency(address(stake), USDT));
    }

}
