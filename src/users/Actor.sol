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

     function try_mint(address _token, address _wallet, uint256 _amount) external returns (bool ok) {
          string memory sig = "mint(address,uint256)";
          (ok,) = address(_token).call(abi.encodeWithSignature(sig, _wallet, _amount));
    }

     function try_burn(address _token, address _wallet, uint256 _amount) external returns (bool ok) {
          string memory sig = "burn(address,uint256)";
          (ok,) = address(_token).call(abi.encodeWithSignature(sig, _wallet, _amount));
    }

     function try_updateAdmin(address _treasury, address _newAdmin) external returns (bool ok) {
          string memory sig = "updateAdmin(address)";
          (ok,) = address(_treasury).call(abi.encodeWithSignature(sig, _newAdmin));
    }

    function try_safeWithdrawERC20(address treasury, address _token) external returns (bool ok) {
        string memory sig = "safeWithdrawERC20(address)";
        (ok,) = address(treasury).call(abi.encodeWithSignature(sig, _token));
    }

}