// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

/// @dev    This contract takes a stable coin from the Staking contract (Stake.sol).
///         This contract is able to depositRewards to Staking contract for distribution.
///         This contract has 3 types of users: Dev, Admin, Account Manager.
///         Account Managers are able to request a withdrawal amount.
///         Admins can approve withdrawals of Account Managers.
///         This contract has accounting capabilities (withdrawn, deposited, gains, amount staked).
///         TODO: TBD -
///         How do account managers get their funds?
///         Do we have multiple risk levels?
///         If so, do we need to keep track of them independently?

contract Treasury is Ownable {

    // ---------------
    // State Variables
    // ---------------

    address public stableCurrency;  /// @notice Stores contract address of stable coin being used to withdraw and deposit into contract.

    event CheckoutData (
        address manager,
        uint256 amount,
        uint256 checkoutTime

    );

    event CheckInData (
        address manager,
        uint256 amount,
        uint256 checkInTime

    );

    // -----------
    // Constructor
    // -----------

    constructor (
        address _stableCurrency
    ) {
        stableCurrency = _stableCurrency;
    }

    // ------
    // Events
    // ------
    
    // ---------
    // Modifiers
    // ---------
    
    // ---------
    // Functions
    // ---------


    //TODO: Talk with Aaron and figure out interact with account managers.
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////


    /// @notice This function returns the amount of stableCurrency is in contract.
    /// @return uint amount of stableCurrency
    function getBalanceOfStableCurrency() public view returns (uint) {

    }

    /// @notice This function is used by account managers to request funds from the treasury.
    /// @dev    Funds can only be withdrawn after an admin has pre-approved the transaction.
    /// @dev    After timeout any attempts to withdraw funds will be rejected.
    /// @dev    Managers may only withdraw the exact amount alloted.
    /// @dev    A log of who, when, and how many funds were checked out must be recorded each time.

    //TODO: Make a isManager
    function checkoutFunds() public {


    }

    /// @notice This function is used by admin to pre-approve a withdaw amount for a specified account manager.
    /// @param _manager The managers wallet who will be withdrawing funds.
    /// @param _amount The amount the given manager may withdraw.
    function enableWithdraw(address _manager, uint256 _amount) public onlyOwner() {


    }


    /// @dev    A log of who, when, and how many funds were deposited must be recorded each time.
    function checkInRewards() external onlyOwner() {

        
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}
