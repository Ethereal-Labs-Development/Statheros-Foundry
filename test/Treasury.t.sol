// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/Treasury.sol";

import "../src/users/Actor.sol";

import "./PolygonUtility.sol";


contract TreasuryTest is Test, PolygonUtility {

    Treasury treasury;

    function setUp() public {

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

    function test_treasury_updateAdmin() public {
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


}
