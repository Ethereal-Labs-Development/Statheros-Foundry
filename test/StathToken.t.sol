// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../lib/forge-std/src/Test.sol";

import "../src/StathToken.sol";

import "../src/users/Actor.sol";

import "./PolygonUtility.sol";


contract StathTokenTest is Test, PolygonUtility {
    
    StathToken stathToken;

    function setUp() public {
        stathToken = new StathToken(
            100000, // NOTE: DO NOT ADD 18 ZEROS, when deployed set to 0
            18,
            "StathToken",
            "STATH",
            address(dev)
        );
    }

    function test_stathToken_init_state() public {
        assertEq(stathToken.totalSupply(), 100000 ether);
        assertEq(stathToken.decimals(), 18);
        assertEq(stathToken.name(), "StathToken");
        assertEq(stathToken.symbol(), "STATH");
        assertEq(stathToken.owner(), address(dev));
        assertEq(stathToken.balanceOf(address(dev)), 100000 ether);
    }

    function test_stathToken_mint_state_changes() public {
        //Pre-State check: Asserting that the wallet address has 0 tokens and verify total supply is what is expected.
        assertEq(stathToken.totalSupply(), 100000 ether);
        assertEq(stathToken.balanceOf(address(69)), 0);

        //State Change: Attempt to mint 10 tokens to user.
        assert(dev.try_mint(address(stathToken), address(69), 10 ether));

        //Post-State check: Verify that amount minted has been added to wallet address.
        assertEq(stathToken.totalSupply(), 100010 ether);
        assertEq(stathToken.balanceOf(address(69)), 10 ether);
    } 

    function test_stathToken_mint_restrictions () public {
        //Dev cannot mint to address 0.
        assert(!dev.try_mint(address(stathToken), address(0), 10 ether));

        //Dev cannot mint 0 tokens.
        assert(!dev.try_mint(address(stathToken), address(69), 0 ether));
    }

    function test_stathToken_burn_state_changes() public {
        //Pre-State check: Asserting that the wallet address has 0 tokens and verify total supply is what is expected.
        assertEq(stathToken.totalSupply(), 100000 ether);
        assertEq(stathToken.balanceOf(address(dev)), 100000 ether);

        //State Change: Attempt to burn 10 tokens to user.
        assert(dev.try_burn(address(stathToken), address(dev), 10 ether));

        //Post-State check: Verify that amount burned has been subtracted from the wallet address.
        assertEq(stathToken.totalSupply(), 99990 ether);
        assertEq(stathToken.balanceOf(address(dev)), 99990 ether);
    } 

    function test_stathToken_burn_restrictions () public {
        //Dev cannot burn from address 0.
        assert(!dev.try_burn(address(stathToken), address(0), 10 ether));

        //Dev cannot mint 0 tokens.
        assert(!dev.try_burn(address(stathToken), address(69), 10 ether));
    }

}


