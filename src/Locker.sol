// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

// Epoch Calculator: https://www.unixtimestamp.com/

/// @dev    This contract holds rewards in escrow until it's time distribute rewards to stakeholders.
///         This contract will calculate APR for stakeholders upon reward distribution.
///         This contract will also calculate the stablecoin amount that is needed to meet the ceiling APR at that time.
///         This contract will hold funds in a float when the ceiling amount is met.
contract Locker is Ownable{

    // ---------------
    // State Variables
    // ---------------

    address private admin;          /// @notice Stores address of admin wallet.
    uint256 private floatAmount;    /// @notice Stores the amount of funds that is set aside to float.
    uint256 private rewardsAmount;  /// @notice Stores the amount of funds that is used for rewards, upon distribution.
    address public stableCurrency;  /// @notice Stores the address of the stablecurrency used to deposit and distribute rewards.

    address[] accountManagers;  /// @notice Stores an array of verified account managers.
    AprData[4] aprLibrary;      /// @notice Stores size:4 array of different apr amounts with their associated timelock.

    // TIMELOCKS && APRs
    // 1  =>  1  month   =>  12%
    // 2  =>  3  months  =>  16%
    // 3  =>  6  months  =>  20%
    // 4  =>  12 months  =>  25%

    struct AprData {
        uint8 lockType;    //  1        2        3         4
        uint256 timeUnix;  //  2629743  7889229  15778458  3115569116
        uint256 apr;       //  1200     1600     2000      2500
    }


    // -----------
    // Constructor
    // -----------

    constructor (
        address _dev,
        address _admin
    ) {
        transferOwnership(_dev);
        admin = _admin;

        setBaseAprData();
    }


    // ------
    // Events
    // ------

    event RewardsDistributed(uint256 amount);

    event AdminUpdated(address oldAdmin, address newAdmin);

    event AprLibraryUpdated(uint8 lockType, uint256 oldTimeUnix, uint256 newTimeUnix, uint256 oldApr, uint256 newApr);
    

    // ---------
    // Modifiers
    // ---------

    modifier isAccountManager() {
        require(accountManagerExists(msg.sender) || msg.sender == admin,
        "Locker.sol::isccountManager() msg.sender is not an account manager");
        _;
    }

    modifier isAdmin() {
        require(msg.sender == admin || msg.sender == owner(),
        "Locker.sol::isAdmin() msg.sender != admin");
        _;
    }
    

    // ---------
    // Functions
    // ---------

    /// @notice Called by the constructor to set the initial values inside the aprLibrary array.
    /// @dev    Values are static, but can change upon deployment.
    function setBaseAprData() internal {
        aprLibrary[0].lockType = 1;
        aprLibrary[0].timeUnix = 2629743;
        aprLibrary[0].apr = 1200;

        aprLibrary[1].lockType = 2;
        aprLibrary[1].timeUnix = 7889229;
        aprLibrary[1].apr = 1600;

        aprLibrary[2].lockType = 3;
        aprLibrary[2].timeUnix = 15778458;
        aprLibrary[2].apr = 2000;

        aprLibrary[3].lockType = 4;
        aprLibrary[3].timeUnix = 3115569116;
        aprLibrary[3].apr = 2500;
    }

    /// @notice This function will distribute rewards to the stakeholders
    /// @dev    Funds are sent to stake.sol
    ///         If the funds that are being distributed is over the getBaseRewardsNeeded value, it goes into float.
    function distributeRewards() public {
    
    }

    /// @notice This function allows an account manager to deposit funds into this contract to later be distributed as rewards.
    function depositFunds() public isAccountManager() {

    }

    /// @notice This function allows an admin to withdraw from the amount of funds deposited for rewards.
    /// @dev    Should only be done by an admin in serious cases.
    /// @param  _amount amount to withdraw from rewardsAmount.
    function withdrawRewards(uint256 _amount) public isAdmin() {

    }

    /// @notice This function withdraws an amount of funds from the float amount to the admin wallet.
    /// @param  _amount amount to withdraw.
    function withdrawFloat(uint256 _amount) public isAdmin() {
        /// NOTE:_amount should not be greater than floatAmount.
    }

    /// @notice withdraws any erc20 token from the contract where blanceOf(address(this)) > 0 to the owner wallet.
    /// @param  _token erc20 token to withdraw
    function safeWithdraw(address _token) public onlyOwner() {
        /// NOTE: _token != stableCurrency && IERC20(_token).balanceOf(address(this)) > 0.
    }

    /// @notice This function adds a wallet address to the accountManagers array.
    /// @param  _account wallet address to add to the accountManagers array.
    function addAccountManager(address _account) public isAdmin() {

    }

    /// @notice This function removes a wallet address from the accountManagers array.
    /// @param  _account wallet address to remove from accountManagers.
    function removeAccountManager(address _account) public isAdmin() {

    }

    /// @notice This function is used to change the admin address in the admin global var.
    /// @param  _newAdmin the new admin wallet.
    function updateAdmin(address _newAdmin) public onlyOwner() {

    }

    /// @notice This function updates the aprLibrary array.
    /// @param  _lockType    specifies which aprData to edit. Must be 1, 2, 3, or 4.
    /// @param  _newTimeUnix amount of seconds in timelock. Uses epoch unix.
    /// @param  _newApr      new percent apr for lock type. Use 2 basis points (i.e. 1200 = 12%).
    function updateBaseApr(uint8 _lockType, uint256 _newTimeUnix, uint256 _newApr) public isAdmin() {
        require(isValidLockType(_lockType), "Locker.sol::updateBaseApr(), _lockType provided not valid.");
        emit AprLibraryUpdated(_lockType, aprLibrary[_lockType - 1].timeUnix, _newTimeUnix, aprLibrary[_lockType - 1].apr, _newApr);

        aprLibrary[_lockType - 1].timeUnix = _newTimeUnix;
        aprLibrary[_lockType - 1].apr = _newApr;
    }


    // ~ View Functions ~


    /// @notice Used to calculate the APR with x amount of funds given the current staking pool.
    /// @param  _amountOfRewards the amount that would be distributed as rewards via distributeRewards (theoretically).
    /// @return apr1 is the apr calculated for lock type 1.
    /// @return apr2 is the apr calculated for lock type 2.
    /// @return apr3 is the apr calculated for lock type 3.
    /// @return apr4 is the apr calculated for lock type 4.
    function AprCalculator(uint256 _amountOfRewards) public view returns (uint256 apr1, uint256 apr2, uint256 apr3, uint256 apr4) {

    }

    /// @notice This function returns the amount of funds needed to hit the base APR given the current staking pool.
    /// @dev    Base apr is stored in the aprLibrary array.
    /// @return uint256 amount of funds needed to hit base apr.
    function getBaseRewardsNeeded() public view returns (uint256) {

    }

    /// @notice This function returns whether or not a wallet address is stored in accountManagers.
    /// @param  _account wallet that's being checked if an account manager or not.
    /// @return bool true if _account is an account manager otherwise false.
    function accountManagerExists(address _account) public view returns (bool) {
        for (uint i = 0; i < accountManagers.length; i++) {
            if (_account == accountManagers[i]) {
                return true;
            }
        }
        return false;
    }

    /// @notice returns the apr of a given lock type inside the aprLibrary.
    /// @dev    lock type is not index.
    /// @param  _lockType lock type of aprLibrary.
    /// @return uint256 returns apr of lock type.
    function getApr(uint8 _lockType) public view returns (uint256) {
        require(isValidLockType(_lockType), "Locker.sol::getApr(), _lockType provided not valid.");
        return aprLibrary[_lockType - 1].apr;
    }

    /// @notice This function returns the time unix of lock time of lock type.
    /// @param  _lockType lock type of aprLibrary.
    /// @return uint256 returns the timeunix of lock time.
    function getLockTimeUnix(uint8 _lockType) public view returns (uint256) {
        require(isValidLockType(_lockType), "Locker.sol::getLockTimeUnix(), _lockType provided not valid.");
        return aprLibrary[_lockType - 1].timeUnix;
    }

    function isValidLockType(uint8 _lockType) internal pure returns (bool) {
        if (_lockType == 1 || _lockType == 2 || _lockType == 3 || _lockType == 4) { return true; }
        return false;
    }
}
