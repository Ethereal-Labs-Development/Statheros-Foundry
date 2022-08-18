// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

import { IERC20 } from "./interfaces/InterfacesAggregated.sol";

/// @dev    This contract takes a stable coin from the Staking contract (Stake.sol).
///         This contract has 2 types of users: Dev and Admin
///         Admins can withdraw funds from contract
///         This contract has accounting capabilities (withdrawn, deposited, gains, amount staked).

contract Treasury is Ownable {

    // ---------------
    // State Variables
    // ---------------

    address public admin;          /// @notice Stores address of admin wallet.
    address public stakingContract; /// @notice Stores the address of Stake.sol
    address public stableCurrency;  /// @notice Stores contract address of stable coin being used to withdraw and deposit into contract.


    // -----------
    // Constructor
    // -----------

    constructor (
        address _dev,
        address _admin,
        address _stableCurrency,
        address _stakingContract
    ) {
        transferOwnership(_dev);
        admin = _admin;
        stableCurrency = _stableCurrency;
        stakingContract = _stakingContract;
    }


    // ------
    // Events
    // ------

    event FundsWithdrawn(address recipient, uint256 amount);
    

    // ---------
    // Modifiers
    // ---------

    modifier isAdmin() {
        require(msg.sender == admin || msg.sender == owner(),
        "Locker.sol::isAdmin() msg.sender != admin");
        _;
    }
    

    // ---------
    // Functions
    // ---------

    /// @notice This function sends all staked funds from Stake.sol to the admin wallet.
    function withdrawStakedFunds() external isAdmin() {

    }

    /// @notice This function withdraws any amount of ERC20 token that is in this contract.
    /// @param  _token erc220 token to withdraw.
    function safeWithdrawERC20(address _token) external onlyOwner() {
        /// NOTE: _token != stableCurrency.
    }

    /// @notice This function is used to change the admin address in the admin global var.
    /// @param  _newAdmin the new admin wallet.
    function updateAdmin(address _newAdmin) public onlyOwner() {
        require(_newAdmin != address(0), "Treasury.sol::updateAdmin() _newAdmin == address(0)");
        require(_newAdmin != admin, "Treasury.sol::updateAdmin() _newAdmin == admin");

        emit OwnershipTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }

    /// @notice This function is used to update the staking contract.
    /// @param  _newStakingContract new staking contract address.
    function updateStakingContract(address _newStakingContract) public onlyOwner() {

    }


    // ~ View Functions ~


    /// @notice This function returns the amount of stableCurrency is in contract.
    /// @return uint amount of stableCurrency
    function getBalanceOfStableCurrency() public view returns (uint256) {
        return IERC20(stableCurrency).balanceOf(address(this));
    }
    
}
