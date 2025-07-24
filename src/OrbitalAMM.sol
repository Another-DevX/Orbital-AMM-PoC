// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract OrbitalAMM {
    using FixedPointMathLib for uint256;

    uint[3] public center;     // r0, r1, r2: sphere center
    uint public R2;            // constant: radius squared (invariant)
    uint[3] public reserves;   // x0, x1, x2: AMM reserves
    mapping(address => uint[3]) public balances; // internal user balances

    constructor(uint[3] memory _center, uint[3] memory _initial) {
        center = _center;
        reserves = _initial;

        // Compute initial invariant: R² = sum((ri - xi)^2)
        for (uint i = 0; i < 3; i++) {
            uint dx = center[i] - reserves[i];
            R2 += dx * dx;
        }
    }

    function deposit(uint i, uint amount) external {
        require(i < 3, "Invalid token index");
        balances[msg.sender][i] += amount;
        reserves[i] += amount;
    }

    function swap(uint i, uint j, uint amountIn) external {
        require(i < 3 && j < 3 && i != j, "Invalid indices");

        uint k = 3 - i - j;

        // Apply input
        reserves[i] += amountIn;
        balances[msg.sender][i] -= amountIn;

        // Updated distances to the center
        uint di = center[i] - reserves[i];
        uint dk = center[k] - reserves[k];
        uint dj = center[j] - reserves[j]; // remains the same, used for deltaOut

        // Spherical invariant: (di)^2 + (dj + deltaOut)^2 + (dk)^2 = R^2
        // => (dj + deltaOut)^2 = R² - di² - dk²
        uint inner = R2 - (di * di) - (dk * dk);
        require(inner > dj * dj, "Insufficient output");

        uint deltaOut = inner.sqrt() - dj;
        require(reserves[j] >= deltaOut, "Not enough liquidity");

        // Update state
        reserves[j] -= deltaOut;
        balances[msg.sender][j] += deltaOut;
    }
}
