// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/Locker.sol";

import "../src/users/Actor.sol";

import "./PolygonUtility.sol";


contract LockerTest is Test, PolygonUtility {

    Locker locker;

    function setUp() public {

        locker = new Locker(
            address(dev),
            address(arn),
            USDC,
            address(1),
            address(2)
        );

    }

    function test_locker_init_state() public {
        assertEq(locker.owner(), address(dev));
        assertEq(locker.admin(), address(arn));
        assertEq(locker.stableCurrency(), USDC);
        assertEq(locker.stakingContract(), address(1));
        assertEq(locker.treasury(), address(2));
    }

}
