# Statheros Yield Farming

## What is Statheros?

Statheros is a DeFi automation platform. We generate yield by leveraging established DeFi protocols across multiple chains while using different strategies to maximize yield. This gives you access to the best yields in DeFi across all platforms while also giving you safer returns as we diversify across many chains.

### How Are We Different?

We use cross chain proven yield producing techniques to obtain the best and most secure returns. Such as, the delta neutral strategy combined with leverage yield farms and other proven techniques.

### How it Works

1. Stake your funds which then get deposited into the Treasury.
2. Our DeFi advisors then have access to move the funds into the best yield generating DeFi platforms across protocols on multiple chains.
3. As yields are produced they will be injected into the Treasury and distributed to stakeholders.

This repository contains the source code for the smart contracts that make up the Bloom Finance Protocol.

- [Treasury](./src/Treasury.sol) - Treasury.sol will serve to keep track of any funds being used by account managers as well as how many rewards should be distributed to which pools. The treasury will take funds accrued and deposit rewards into the staking contract for distribution to stakeholders.
  
- [Stake](./src/Stake.sol) - Stakeholders will stake their funds in the form of MATIC, USDT, or Stablecoins in return for an equal amount of $STATH minted by StathToken.sol. These funds deposited will then be converted to USDC and sent to the Treasury. Stake.sol handles all stakeholder data, timelocks, autocompounding, and reward distribution.
  
- [StathToken](./src/StathToken.sol) - This contract will be used to mint investors "soulbound" tokens which will act as their receipt for staking on the Statheros protocol. The investor will be minted the USD equivalent of their investment in STATH tokens.

**NOTE:** This codebase uses [Foundry](https://github.com/foundry-rs/foundry), a blazing fast, portable and modular toolkit for Ethereum application development. Built on top of Dapp Tools.

[![Homepage](https://img.shields.io/badge/Elevate%20Software-Homepage-brightgreen)](https://www.elevatesoftware.io/)