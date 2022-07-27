// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

import { IQuoter } from "./interfaces/InterfacesAggregated.sol";

/// @dev    This contract allows accounts to stake crypto assets from a whitelist of tokens.
///         This contract contains a whitelist of accepted assets.
///         This contract will distribute rewards to stakeholders at a dynamic APR.
///         Stakeholders can autocompound their rewards.
///         This contract will mint STATH "soulbound" tokens to stakeholders.
///         This contract can send stablecoin to the Treasury.sol upon a stake being created.
///         This contract swaps all staked crypto assets for a single stablecoin.
///         To Be Determined:
///          - Where we store a user telegram username, struct?
///          - How to mint STATH tokens from an external smart contract.
///          - Allow people to stake more assets when already staked. Solution: Force timelock
///          - Discuss timelocks - which timeframes
contract Stake is Ownable{

    // ---------------
    // State Variables
    // ---------------

    address public stableCurrency;  /// @notice Stores contract address of stable coin being used to swap and distribute in contract.
    address public treasury;        /// @notice Stores contract address of Treasury contract.
    address public soulboundToken;  /// @notice Stores contract address of Statheros soulbound token.
    uint public apr;                /// @notice Annual Return Rate. Used to calculate reward distribution.
    bool public stakingEnabled;     /// @notice Bool of whether or not the contract is enabled.

    mapping(address => bool) public tokenWhitelist; /// @notice whitelist of accepted assets to be staked.

    address Quoter = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;

    // TIMELOCKS
    // 1 = 1 month
    // 2 = 3 months
    // 3 = 6 months
    // 4 = 1 year

    // potentially replace staking library with individual stakes array in account data struct.
    StakeData[] stakingLibrary; /// @notice Declaring stakingLibrary to store all stakeData of currently staked patrons.


    /// @notice Stakeholder struct used to store all necessary data for a patron staking.
    /// @param wallet address associated with the staking account.
    /// @param username Telegram username associated with the staking account.
    /// @param amountStakedUSD amount of an asset staked in USD equivalent.
    /// @param rewardsClaimedUSD amount of rewards claimed in USD equivalent.
    /// @param rewardsRemainingUSD amount of rewards left to be claimed in USD equivalent.
    /// @param lockType timelock type associated with the amount staked.
    /// @param aprType apr type associated with the amount staked.
    /// @param stakeTime timestamp indicating when the stake began.
    /// @param stakeComplete boolean indicating whether the stake timelock has concluded. 
    struct StakeData {
        address wallet;
        string username;
        uint amountStakedUSD;
        uint rewardsClaimedUSD;
        uint rewardsRemainingUSD;
        uint lockType; // 1, 2, 3, 4
        uint aprType; // 1, 2, 3, 4
        uint stakeTime;
        bool stakeComplete; // If true, do not autocompound rewards, do not give rewards... until claim or restake.
    }

    // -----------
    // Constructor
    // -----------

    constructor (
        address _stableCurrency,
        address _treasury,
        address _soulboundToken,
        address _admin
    ) {
        stableCurrency = _stableCurrency;
        treasury = _treasury;
        soulboundToken = _soulboundToken;

        transferOwnership(_admin);

        stakingEnabled = false;
    }

    // ------
    // Events
    // ------

    // TODO: Add necessary events.
    
    // ---------
    // Modifiers
    // ---------

    // TODO: Add necessary modifiers.
    
    // ---------
    // Functions
    // ---------

    /// @notice This function changes the native stableCurrency state variable.
    /// @param _newStableCurrency is the address of the new stable currency  in the contract.
    function updateStableCurrency(address _newStableCurrency) public onlyOwner() {
        require(_newStableCurrency != stableCurrency, "Stake.sol::updateStableCurrency() new stable currency cannot be the same");
        require(_newStableCurrency != treasury, "Stake.sol::updateStableCurrency() new stable currency cannot be Treasury address");
        require(_newStableCurrency != soulboundToken, "Stake.sol::updateStableCurrency() new stable currency cannot be $STATH address");
        require(_newStableCurrency != address(this), "Stake.sol::updateStableCurrency() new stable currency cannot be Stake.sol address");
        stableCurrency = _newStableCurrency;
    }

    /// @notice This function changes the local treasury state variable, new treasury cannot be the old one.
    /// @dev Should be the contract address of the new Treasury Contract. Funds will be sent here when staked.
    /// @param _newTreasury contract address of new Treasury Contract.
    function updateTreasury(address _newTreasury) public onlyOwner() {
        require(_newTreasury != treasury, "Stake.sol::updateTreasury() new treasury contract cannot be the same");
        require(_newTreasury != stableCurrency, "Stake.sol::updateTreasury() new treasury contract cannot be stable currency address");
        require(_newTreasury != soulboundToken, "Stake.sol::updateTreasury() new treasury contract cannot be $STATH address");
        require(_newTreasury != address(this), "Stake.sol::updateTreasury() new treasury contract cannot be Stake.sol address");
        treasury = _newTreasury;
    }

    /// @notice Updates the tokenWhitelist mapping.
    /// @param _token contract address of token being updated in whitelist.
    /// @param _whitelisted bool of whether or not this token is whitelisted.
    function updateTokenWhitelist(address _token, bool _whitelisted) public onlyOwner() {
        require(_token != address(this), "Stake.sol::updateTokenWhitelist() whitelist cannot contain Stake.sol address");
        require(_token != treasury, "Stake.sol::updateTokenWhitelist() whitelist cannot contain Treasury address");
        require(_token != soulboundToken, "Stake.sol::updateTokenWhitelist() whitelist cannot contain $STATH address");
        tokenWhitelist[_token] = _whitelisted;
    }

    /// @notice Called when an account is staking, creating a stake.
    /// @dev should send assets to swap then to the Treasury.
    /// @param _staked amount of a whitelisted token to be staked.
    /// @param _wallet account that is staking the assets.
    /// @param _timelock type of timelock designated by 1, 2, 3, or 4.
    /// @param _username Telegram username associated with the address.
    function stake(uint _staked, address _wallet, uint _timelock, string calldata _username) public {

    }

    /// @notice Called when an account is unstaking, removing their assets.
    /// @param _wallet account that is staking the assets.
    function unStake(address _wallet) public {

    }

    /// @notice Used to return all active stakeholders.
    /// @return address returns an array of addresses.
    function getStakeholders() public returns (address[] memory){

    }

    /// @notice Used to return amount of stakeholders.
    /// @return uint returns num of stakeholders.
    function getNumOfStakeholders() public view returns (uint) {

    }

    /// @notice Used for a wallet to claim their rewards.
    /// @param _wallet account that is claiming rewards.
    function claimRewards(address _wallet) public {

    }

    /// @notice Used to auto-compound rewards if either left unclaimed or manually compounded.
    /// @param _staked amount the account originally staked.
    /// @param _reward amount the account is rewarded for staking.
    /// @param _wallet account to receive the reward. 
    function autoCompound(uint _staked, uint _reward, address _wallet) public {

    }

    /// @notice Used to get username of a specific wallet address, if any
    /// @param _wallet address associated with the Telegram username.
    function getUsername(address _wallet) public view {
        
    }

    /// @notice This is a view function to get the Usd amount of any amount of tokens.
    /// @param  _tokenIn holds the token erc20 address going in.
    /// @param  _amount holds the amount of that token.
    function getUsdAmountOutSingle(address _tokenIn, uint _amount) public returns (uint256) {
        uint256 amountOut = 
        IQuoter(Quoter).quoteExactInputSingle(
            _tokenIn,
            stableCurrency,
            500, //0.05%
            _amount,
            0
        );

        return amountOut;
    }

    /// @notice This is a view function to get the Usd amount of any amount of tokens.
    function getUsdAmountOutMulti(bytes memory path, uint _amount) public returns (uint256) {
        uint256 amountOut = 
        IQuoter(Quoter).quoteExactInput(
            path,
            _amount
        );

        return amountOut;
    }

    /// @notice Used to mint stakeholders soulbound tokens upon staking.
    /// @param _wallet account that we're minting tokens for.
    /// @param _amount amount of tokens being minted to account.
    function mintTokens(address _wallet, uint _amount) internal {

    }

    /// @notice Used to burn soulbound tokens of an account upon unstaking.
    /// @param _wallet account that we're burning tokens from.
    /// @param _amount amount of tokens being burned from account.
    function burnTokens(address _wallet, uint _amount) internal {

    }

    /// @notice Deposit rewards for distribution.
    /// @dev Should only be called by Treasury.
    /// @param _amount amount of assets being distributed in stableCurrency.
    function depositRewards(uint _amount) external {

    }

    /// @notice Distribute rewards to stakeholders.
    /// @dev should only be called manually or by python bot.
    function distributeRewards() external {

    }

    /// @notice Uses CRV Protocol to swap assets being staked to stableCurrency.
    /// @param _wallet account that is staking.
    /// @param _amount amount of tokens they're staking.
    /// @param baseToken asset being staked.
    function swapAssets(address _wallet, uint _amount, address baseToken) internal {

    }

    // TODO: Add enable/disable functions
    // TODO: Add accounting functions
    //      - getBalanceOfStable
    //      - getBalanceOfToken - any token
    //      - withdraw
}
