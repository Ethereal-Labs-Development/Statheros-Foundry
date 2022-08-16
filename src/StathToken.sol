// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./OpenZeppelin/Ownable.sol";

/// @dev    This ERC20 contract represents the soulbound Bloom Token.
///         This contract should support the following functionalities:
///         - Soulbound
///         - Mintable
///         - Burnable
///         To be determined:
///         - Which contracts should be allowed to mint/burn, and process for enabling mint/burn permissions.
///         - Keep track of given tokens on a per-project basis?

contract StathToken is Ownable {

    // TODO: Figure out which wallets need to be an exception
    //       Owner wallet and dead wallet only ???
    
    // ---------------
    // State Variables
    // ---------------

    // ERC20 Basic
    uint256 _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    // ERC20 Mappings
    mapping(address => uint256) balances;                       // Track balances.
    mapping(address => mapping(address => uint256)) allowed;    // Track allowances.

    // extra
    mapping (address => bool) exception;   // Mapping of wallets who are allowed to receive or send tokens.

    address public treasury;   // Stores the address of Treasury.sol

    // -----------
    // Constructor
    // -----------

    /// @notice Initialize the BloomToken.sol contract ($BLOOM).
    /// @param totalSupplyInput The initial supply of $BLOOM (0 ether).
    /// @param decimalsInput    The decimal precision of $BLOOM (18).
    /// @param nameInput        The name of BloomToken (BLOOM).
    /// @param symbolInput      The symbol of BloomToken (BLOOM).
    constructor(
        uint256 totalSupplyInput,
        uint8 decimalsInput,
        string memory nameInput,
        string memory symbolInput,
        address admin
    ) {
        _totalSupply = totalSupplyInput * 10**decimalsInput;
        _decimals = decimalsInput;
        _name = nameInput;
        _symbol = symbolInput;

        transferOwnership(admin);
        exception[admin] = true;

        balances[admin] = _totalSupply;
    }

    // ------
    // Events
    // ------

    /// @dev Emitted when approve() is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   
 
    /// @dev Emitted during transfer() or transferFrom().
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // ---------
    // Modifiers
    // ---------

    modifier isExceptionDual(address from, address to) {
        require(exception[from] == true || exception[to] == true,
        "BloomToken.sol::isException() token is soulbound. Sender nor receiver is an exception");
        _;
    }

    modifier isExceptionTri(address sender, address from, address to) {
        require(exception[sender] == true || exception[from] == true || exception[to] == true,
        "BloomToken.sol::isException() token is soulbound. Sender nor receiver is an exception");
        _;
    }

    modifier isTreasury(address sender) {
        require(treasury == sender,
        "BloomToken.sol::isTreasury() msg.sender is not Treasury");
        _;
    }


    // ---------
    // Functions
    // ---------

    // ~ ERC20 View ~
    
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return balances[_owner];
    }
 
    // ~ ERC20 transfer(), transferFrom(), approve() ~

    function approve(address _spender, uint256 _amount) external returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function transfer(address _to, uint256 _amount) external isExceptionDual(msg.sender, _to) returns (bool) {
        require(balances[msg.sender] >= _amount, "BloomToken.sol::transfer() balanceOf(msg.sender) is insufficient");
        require(_amount > 0, "BloomToken.sol::transfer() amount is insufficient");

        _transfer(msg.sender, _to, _amount);

        return true;
    }
 
    function transferFrom(address _from, address _to, uint256 _amount) external isExceptionTri(msg.sender, _from, _to) returns (bool) {
        require(balances[_from] >= _amount, "BloomToken.sol::transferFrom() balanceOf(_from) is insufficient");
        require(allowed[_from][msg.sender] >= _amount, "BloomToken.sol::transferFrom() allowance is too low");
        require(_amount > 0, "BloomToken.sol::transferFrom() amount is insufficient");

        allowed[_from][msg.sender] -= _amount;
        _transfer(_from, _to, _amount);

        return true;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal virtual {
        uint256 fromBalance = balances[_from];

        balances[_from] = fromBalance - _amount;
        balances[_to] += _amount;
        
        emit Transfer(_from, _to, _amount);
    }
    
    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // ~ ERC20 mint() and burn() ~

    // TODO: add mint() function

    /// @notice This function will create new tokens and adding them to total supply.
    /// @dev    Does not truncate so amount needs to include the 18 decimal points.
    /// @param  _wallet the account we're minting tokens to.
    /// @param  _amount the amount of tokens we're minting.
    function mint(address _wallet, uint256 _amount) external {
        require(_wallet != address(0), "StathToken.sol::mint() _wallet cannot be address 0");
        require(_amount > 0, "StathToken.sol::mint() cannot mint 0 tokens");

        _totalSupply += _amount;
        balances[_wallet] += _amount;

        emit Transfer(address(0), _wallet, _amount);
    }


    function burn(address _wallet, uint256 _amount) public {
        require(_wallet != address(0), "StathToken.sol::burn() _wallet cannot be address 0");
        require(balances[_wallet] >= _amount, "StathToken.sol::burn() burn amount exceeds balance");

        _totalSupply -= _amount;
        balances[_wallet] -= _amount;

        emit Transfer(_wallet, address(0), _amount);
    }


    // ~ Admin ~

    function updateException(address _wallet, bool _isAnException) external onlyOwner() {
        require(exception[_wallet] != _isAnException, "BloomToken.sol::updateException() wallet is already of bool _isAnException");
        exception[_wallet] = _isAnException;
    }

    function setTreasury(address _treasury) external onlyOwner() {
        treasury = _treasury;
    }

}