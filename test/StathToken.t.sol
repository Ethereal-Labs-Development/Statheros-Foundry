// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/StathToken.sol";

import "../src/users/Actor.sol";

import "./AvaxToolbox.sol";


contract StathTokenTest is Test {
    
    StathToken stathToken;

    function setUp() public {
        stathToken = new StathToken(
            
        );
    }

}
