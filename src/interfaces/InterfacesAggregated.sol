// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWETH {
    function deposit() external payable;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}