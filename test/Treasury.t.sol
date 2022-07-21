// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/Treasury.sol";

import "../src/users/Actor.sol";

import "./AvaxToolbox.sol";


contract TreasuryTest is Test, AvaxToolbox {

    Treasury treasury;

    function setUp() public {

        treasury = new Treasury(
            USDC
        );

    }

}
