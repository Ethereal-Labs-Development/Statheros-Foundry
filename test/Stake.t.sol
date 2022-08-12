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

    // TODO: add better Oracle tests later on with various currencies, pools, and fuzzing etc.
    // ~ getOracleStableQuote() Testing ~

    function test_stake_getOracleStableQuote() public {
        // Add WMATIC to tokenWhitelist mapping
        dev.try_updateTokenWhitelist(address(stake), WMATIC, true);
        // Add WMATIC pool data to tokenPools mapping
        dev.try_updateTokenPools(address(stake), WMATIC, MTC, 500);

        uint256 _amount = 100 ether;
        uint256 oracleQuote = stake.getOracleStableQuote(WMATIC, _amount, 90);
        assertGt(oracleQuote, 0);
    }

    // ~ updateTokenPools() Testing ~

    // updateTokenPools() state checks.
    function test_stake_updateTokenPools_state_changes() public {
        // Pre-State: There should be no PoolData struct in tokenPools for WBTC.
        (address token, uint256 decimals, uint24 fee) = stake.tokenPools(WBTC);
        assertEq(token, address(0));
        assertEq(decimals, uint256(0));
        assertEq(fee, uint24(0));

        // State-Change: Add associated pool data for Uniswap V3 pool between WBTC and stable currency.
        dev.try_updateTokenPools(address(stake), WBTC, BTC, 3000);

        // Post-State: Validate the PoolData struct added to tokenPools for Uniswap V3 pool between WBTC and stable currency.
        (token, decimals, fee) = stake.tokenPools(WBTC);
        assertEq(token, address(WBTC));
        assertEq(decimals, uint256(BTC));
        assertEq(fee, uint24(3000));
    }

    // updateTokenPools() restrictions.
    function test_stake_updateTokenPools_restrictions() public {
        // Verify dev cannot add address of Stake.sol to pool data.
        assert(!dev.try_updateTokenPools(address(stake), address(stake), 0, 1000));

        // Verify dev cannot add address of Treasury.sol to pool data.
        assert(!dev.try_updateTokenPools(address(stake), stake.treasury(), 0, 1000));

        // Verify dev cannot add stable currency to pool data.
        assert(!dev.try_updateTokenPools(address(stake), stake.stableCurrency(), 0, 1000));
        
        // Verify dev cannot add pool data for a Uniswap V3 pool that is impossible. 1000000 ~= 100%
        assert(!dev.try_updateTokenPools(address(stake), WBTC, BTC, 1000000));

        // Verify dev cannot add pool data for an invalid Uniswap V3 pool that does not exist.
        assert(!dev.try_updateTokenPools(address(stake), WBTC, BTC, 5000));

        // Verify dev can add pool data for a valid Uniswap V3 pool.
        assert(dev.try_updateTokenPools(address(stake), WBTC, BTC, 3000));

        // Verify admin cannot update pool data.
        assert(!arn.try_updateTokenPools(address(stake), WBTC, BTC, 3000));

        // Verify manager cannot update pool data.
        assert(!mgr.try_updateTokenPools(address(stake), WBTC, BTC, 3000));

        // Verify users cannot update pool data.
        assert(!joe.try_updateTokenPools(address(stake), WBTC, BTC, 3000));
    }

    // ~ stakeAsset() Testing ~

    // stakeAsset() proof of concept with basic staking scenario.
    function test_stake_stakeAsset_example() public {
        // Pre-State: Check balances and update token whitelist and pool data.

        // Add WBTC to the token whitelist because this is an asset we want to stake.
        dev.try_updateTokenWhitelist(address(stake), WBTC, true);
        // Add valid pool data for WBTC and stable currency to interface with Uniswap V3.
        dev.try_updateTokenPools(address(stake), WBTC, BTC, 3000);

        // Assert that balance of stable currency in Stake.sol is 0 to start.
        assertEq(IERC20(stake.stableCurrency()).balanceOf(address(stake)), 0);
        // Assert that balance of WBTC in address(10) is 0 to start.
        assertEq(IERC20(WBTC).balanceOf(address(10)), 0);

        // State-Changes: Mint 10 WBTC to address(10) and have address(10) stake 10 WBTC using stakeAsset().

        // Mint 10 WBTC to address(10) to be used for staking purposes.
        mint("WBTC", address(10), 10 * BTC);
        // Confirm address(10) received 10 WBTC.
        assertEq(IERC20(WBTC).balanceOf(address(10)), 10 * BTC);

        // Use Foundry's startPrank cheatcode to make the msg.sender of all function calls, until stopPrank, address(10).
        vm.startPrank(address(10));
        // Approve the Stake.sol contract to use 10 WBTC from address(10).
        IERC20(WBTC).approve(address(stake), 10 * BTC);
        // Call stakeAsset() on the Stake.sol to stake 10 WBTC from address(10).
        (uint256 receivedAmt, uint256 quoteAmt) = stake.stakeAsset(WBTC, 10 * BTC, address(10), 0, "joe");
        // Resume normal msg.sender for the following function calls.
        vm.stopPrank();

        // Post-State: Verify WBTC/stable currency balances, ensure acceptable stake receipt, and log amounts.

        // Assert receivedAmt in stable currency is greater than 0.
        assertGt(receivedAmt, 0);
        // Assert receivedAmt in stable currency is greater than minimum quoteAmt for the 10 WBTC.
        assertGe(receivedAmt, (quoteAmt - (quoteAmt * 2 / 100)));
        // Assert address(10) transferred all 10 WBTC to the Stake.sol contract with the call to stakeAsset().
        assertEq(IERC20(WBTC).balanceOf(address(10)), 0);
        // Assert Stake.sol swapped all 10 WBTC received for stable currency during call to stakeAsset() without leftovers.
        assertEq(IERC20(WBTC).balanceOf(address(stake)), 0);
        // Assert that balance of stable currency in Stake.sol is equivalent to the 10 WBTC swapped during call to stakeAsset(). 
        assertEq(IERC20(stake.stableCurrency()).balanceOf(address(stake)), receivedAmt);

        // Emit amount of stable currency received from the swap and quoted for the swap from Uniswap V3.
        emit log_named_uint("Stable currency received = ", receivedAmt);
        emit log_named_uint("Stable currency quoted = ", quoteAmt);
        emit log_named_uint("Stable currency minimum = ", (quoteAmt - (quoteAmt * 2 / 100)));
    }

    /*
    // stakeAsset() proof of concept with basic staking scenario.
    function test_stake_stakeAsset_example_fuzzing(uint256 amount) public {
        // Prevent overflow but allow reasonable value range for amounts of WBTC.
        bound(amount, 0, ((((10 ** 77) / BTC) * 20)/ 100));

        // Add WBTC to the token whitelist because this is an asset we want to stake.
        dev.try_updateTokenWhitelist(address(stake), WBTC, true);
        // Add valid pool data for WBTC and stable currency to interface with Uniswap V3.
        dev.try_updateTokenPools(address(stake), WBTC, BTC, 3000);

        // Assert that balance of stable currency in Stake.sol is 0 to start.
        assertEq(IERC20(stake.stableCurrency()).balanceOf(address(stake)), 0);

        // Assert that balance of WBTC in address(10) is 0 to start.
        assertEq(IERC20(WBTC).balanceOf(address(10)), 0);
        // Mint 10 WBTC to address(10) to be used for staking purposes.
        mint("WBTC", address(10), amount * BTC);
        // Confirm address(10) received 10 WBTC.
        assertEq(IERC20(WBTC).balanceOf(address(10)), amount * BTC);

        // Use Foundry's startPrank cheatcode to make the msg.sender of all function calls, until stopPrank, address(10).
        vm.startPrank(address(10));
        // Approve the Stake.sol contract to use 10 WBTC from address(10).
        IERC20(WBTC).approve(address(stake), amount * BTC);
        // Call stakeAsset() on the Stake.sol to stake 10 WBTC from address(10).
        (uint256 receivedAmt, uint256 quoteAmt) = stake.stakeAsset(WBTC, amount * BTC, address(10), 0, "joe");
        // Resume normal msg.sender for the following function calls.
        vm.stopPrank();

        // Assert receivedAmt in stable currency is greater than 0.
        assertGt(receivedAmt, 0);
        // Assert receivedAmt in stable currency is greater than minimum quoteAmt for the 10 WBTC.
        assertGe(receivedAmt, (quoteAmt - (quoteAmt * 2 / 100)));
        // Assert address(10) transferred all 10 WBTC to the Stake.sol contract with the call to stakeAsset().
        assertEq(IERC20(WBTC).balanceOf(address(10)), 0);
        // Assert Stake.sol swapped all 10 WBTC received for stable currency during call to stakeAsset() without leftovers.
        assertEq(IERC20(WBTC).balanceOf(address(stake)), 0);
        // Assert that balance of stable currency in Stake.sol is equivalent to the 10 WBTC swapped during call to stakeAsset(). 
        assertEq(IERC20(stake.stableCurrency()).balanceOf(address(stake)), receivedAmt);

        // Emit amount of stable currency received from the swap and quoted for the swap from Uniswap V3.
        emit log_named_uint("Stable currency received = ", receivedAmt);
        emit log_named_uint("Stable currency quoted = ", quoteAmt);
    }
    */
}
