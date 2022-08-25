// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/Treasury.sol";

import "../src/users/Actor.sol";

import "./PolygonUtility.sol";


contract TreasuryTest is Test, PolygonUtility {

    Treasury treasury;

    function setUp() public {

        setUpTokens();

        treasury = new Treasury(
            address(dev),
            address(arn),
            USDC,
            address(1)
        );

    }

    function test_treasury_init_state() public {
        assertEq(treasury.owner(), address(dev));
        assertEq(treasury.admin(), address(arn));
        assertEq(treasury.stableCurrency(), USDC);
        assertEq(treasury.stakingContract(), address(1));
    }

    function test_treasury_updateAdmin_state_changes() public {
        //Pre-State check: checking _admin address.
        assertEq(treasury.admin(), address(arn));

        //State Change: attempt to update admin address.    
        assert(dev.try_updateAdmin(address(treasury), address(32)));

        //Post-State check: verify _admin address has been updated.
        assertEq(treasury.admin(), address(32));
    }

   function test_treasury_updateAdmin_restrictions () public {
        //_newAdmin cannot be address(0).
        assert(!dev.try_updateAdmin(address(treasury), address(0)));

        //_newAdmin cannot be previous admin.
        assert(!dev.try_updateAdmin(address(treasury), address(arn)));

        //updating to a legitimate admin address.
        assert(dev.try_updateAdmin(address(treasury), address(32)));
    }


    function test_treasury_safeWithdrawERC20_state_changes() public {
        // Make sure funds are in the treasury for a withdraw to occur.
        mint("WBTC", address(treasury), 100 * BTC);

        // Pre-State check.
        // Makes sure dev has a balance of 0.
        // Makes sure treasury has a balance of 2000.
        assertEq(IERC20(WBTC).balanceOf(address(dev)), 0);
        assertEq(IERC20(WBTC).balanceOf(address(treasury)), 100 * BTC);
        
        // State-Change.
        assert(dev.try_safeWithdrawERC20(address(treasury), WBTC));

        // Post-State check.
        // Dev now should have 2000 USD, which indicates a successful withdraw.
        // Treasury should not have 0 USD, which indictaes a successful withdraw.
        assertEq(IERC20(WBTC).balanceOf(address(dev)), 100 * BTC);
        assertEq(IERC20(WBTC).balanceOf(address(treasury)), 0);
         
    }

    function test_treasury_safeWithdraw_restrictions() public {
      // Make sure our safeWithdraw function does not allow users to withdraw with 0 funds available.
      assert(!dev.try_safeWithdrawERC20(address(treasury), WBTC));
        
      // Add funds to contract balance of stableCurrency inside Treasury.sol.
      mint("WBTC", address(treasury), 1069 * BTC);
      
      // "dev" should be able to call safeWithdraw() and successfully withdraw after funds have been added.
      assert(dev.try_safeWithdrawERC20(address(treasury), WBTC));
    }

}
