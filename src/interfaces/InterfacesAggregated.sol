// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;
pragma abicoder v2;

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

// V3 Uniswap IQuoter.sol
// Deployed: https://polygonscan.com/address/0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6#contracts
// Docs: https://docs.uniswap.org/protocol/reference/periphery/interfaces/IQuoter

interface IQuoter {
    /// @notice Returns the amount out received for a given exact input swap without executing the swap
    /// @param path The path of the swap, i.e. each token pair and the pool fee
    /// @param amountIn The amount of the first token to swap
    /// @return amountOut The amount of the last token that would be received
    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);

    /// @notice Returns the amount out received for a given exact input but for a swap of a single pool
    /// @param tokenIn The token being swapped in
    /// @param tokenOut The token being swapped out
    /// @param fee The fee of the token pool to consider for the pair
    /// @param amountIn The desired input amount
    /// @param sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
    /// @return amountOut The amount of `tokenOut` that would be received
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);

    /// @notice Returns the amount in required for a given exact output swap without executing the swap
    /// @param path The path of the swap, i.e. each token pair and the pool fee. Path must be provided in reverse order
    /// @param amountOut The amount of the last token to receive
    /// @return amountIn The amount of first token required to be paid
    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);

    /// @notice Returns the amount in required to receive the given exact output amount but for a swap of a single pool
    /// @param tokenIn The token being swapped in
    /// @param tokenOut The token being swapped out
    /// @param fee The fee of the token pool to consider for the pair
    /// @param amountOut The desired output amount
    /// @param sqrtPriceLimitX96 The price limit of the pool that cannot be exceeded by the swap
    /// @return amountIn The amount required as the input for the swap in order to receive `amountOut`
    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);
}

// V3 Uniswap UniswapV3Factory.sol
// Deployed: https://polygonscan.com/address/0x1F98431c8aD98523631AE4a59f267346ea31F984#code
// Docs: https://docs.uniswap.org/protocol/reference/core/interfaces/IUniswapV3Factory

interface IUniswapV3Factory {

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

}

// V3 Uniswap UniswapV3Pool.sol
// Deployed: https://polygonscan.com/address/0x1F98431c8aD98523631AE4a59f267346ea31F984#code
// Docs: https://docs.uniswap.org/protocol/reference/core/interfaces/IUniswapV3Factory

interface IUniswapV3Pool {

    function observe(uint32[] calldata secondsAgos)
    external
    view
    returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

}

// V3 Uniswap ISwapRouter.sol
// Deployed: https://polygonscan.com/address/0xE592427A0AEce92De3Edee1F18E0157C05861564#code
// Docs: https://docs.uniswap.org/protocol/reference/periphery/interfaces/ISwapRouter
// https://docs.uniswap.org/protocol/guides/swaps/single-swaps

interface ISwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

}