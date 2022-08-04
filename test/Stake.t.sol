// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/Stake.sol";
import "../src/Treasury.sol";
import "../src/StathToken.sol";

import "../src/users/Actor.sol";

import "./PolygonUtility.sol";

contract StakeTest is Test, PolygonUtility {

    Stake stake;
    Treasury treasury;
    StathToken stathToken;

    function setUp() public {

        // setup tokens for use with Uniswap V3???
        setUpTokens();

        stathToken = new StathToken();
        treasury = new Treasury(USDC);

        stake = new Stake(
            USDC,
            address(treasury),
            address(stathToken),
            address(dev)
        );

        dev.try_updateTokenWhitelist(address(stake), WBTC, true);
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

        // State Change: Update the stable currency from USDC to DAI.
        dev.try_updateStableCurrency(address(stake), DAI);

        // Post-State: Confirm that the new stable currency is equivalent to DAI.
        assertEq(stake.stableCurrency(), DAI);
        
        // State Change: Change the stable currency from DAI back to USDC.
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

        // Verify dev can update stable currency to DAI.
        assert(dev.try_updateStableCurrency(address(stake), DAI));

        // Verify admin cannot update stable currency.
        assert(!arn.try_updateStableCurrency(address(stake), DAI));

        // Verify manager cannot update stable currency.
        assert(!mgr.try_updateStableCurrency(address(stake), DAI));

        // Verify users cannot update stable currency.
        assert(!joe.try_updateStableCurrency(address(stake), DAI));
    }

    // ~ getOracleStableQuote() Testing ~
    
    function test_stake_getOracleStableQuote() public {
        uint256 _amount = 100 ether;
        (uint256 oracleQuote,) = stake.getOracleStableQuote(WMATIC, _amount, 90);
        assert(oracleQuote >= 0);
    }

    // ~ getUsdAmountOutSingle() Testing ~

    function test_stake_getUsdAmountOutSingle(uint256 _amount) public {
        uint256 quote = stake.getUsdAmountOutSingle(WMATIC, _amount);
        assert(quote >= 0);
    }

    // ~ stakeAsset() Testing ~

    function test_stake_mintFoundry() public {
        
        assertEq(IERC20(WBTC).balanceOf(address(10)), 0);
        mint("WBTC", address(10), 10*BTC);
        
        vm.prank(address(10));
        IERC20(WBTC).approve(address(stake), 10*BTC);
        vm.prank(address(10));
        uint256 amount = stake.stakeAsset(WBTC, 10*BTC, address(10), 0, "joe");

        assertGt(amount, 0);
        assertEq(IERC20(WBTC).balanceOf(address(10)), 0);
        assertEq(IERC20(WBTC).balanceOf(address(stake)), 0);
        assertEq(IERC20(USDC).balanceOf(address(stake)), amount);

    }

}
