// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;

import "../src/users/Actor.sol";

contract AvaxToolbox {

    /*******************************/
    /*** AVAX Contract Addresses ***/
    /*******************************/

    address constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;  // https://snowtrace.io/token/0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7  Decimals: 18
    address constant DAI   = 0xd586E7F844cEa2F87f50152665BCbc2C279D8d70;  // https://snowtrace.io/token/0xd586e7f844cea2f87f50152665bcbc2c279d8d70
    address constant USDC  = 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E;  // https://snowtrace.io/token/0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e
    address constant USDT  = 0xc7198437980c041c805A1EDcbA50c1Ce5db95118;  // https://snowtrace.io/token/0xc7198437980c041c805a1edcba50c1ce5db95118
    address constant WETH  = 0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB;  // https://snowtrace.io/token/0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab <-- Double check
    address constant WBTC  = 0x50b7545627a5162F82A992c33b87aDc75187B218;  // https://snowtrace.io/token/0x50b7545627a5162f82a992c33b87adc75187b218 <-- Double check

    /**************/
    /*** Actors ***/
    /**************/

    Actor  dev = new Actor(); // Owner/Dev
    Actor  arn = new Actor(); // Aaron/Admin
    Actor  mgr = new Actor(); // Account Manager
    Actor  joe = new Actor(); // Normal User

    /*****************/
    /*** Constants ***/
    /*****************/
    
    uint256 constant USD = 10 ** 6;
    uint256 constant BTC = 10 ** 8;
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

}