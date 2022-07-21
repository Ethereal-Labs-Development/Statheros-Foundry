// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

import { IERC20 } from "../interfaces/InterfacesAggregated.sol";

contract Actor {

    /************************/
    /*** DIRECT FUNCTIONS ***/
    /************************/

    // function transferToken(address token, address to, uint256 amt) external {
    //     IERC20(token).transfer(to, amt);
    // }

    /*********************/
    /*** TRY FUNCTIONS ***/
    /*********************/

    function try_updateTreasury(address stake, address _newTreasury) external returns (bool ok) {
         string memory sig = "updateTreasury(address)";
         (ok,) = address(stake).call(abi.encodeWithSignature(sig, _newTreasury));
    }

    function try_updateTokenWhitelist(address stake, address _token, bool _whitelisted) external returns (bool ok) {
         string memory sig = "updateTokenWhitelist(address,bool)";
         (ok,) = address(stake).call(abi.encodeWithSignature(sig, _token, _whitelisted));
    }
    
    function try_updateStableCurrency(address stake, address _token) external returns (bool ok) {
          string memory sig = "updateStableCurrency(address)";
          (ok,) = address(stake).call(abi.encodeWithSignature(sig, _token));
    }

}