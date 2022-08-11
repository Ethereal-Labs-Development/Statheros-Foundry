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

}
