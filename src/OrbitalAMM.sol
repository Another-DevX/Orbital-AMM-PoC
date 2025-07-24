// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract OrbitalAMM {
    using FixedPointMathLib for uint256;

    uint[3] public center; // r0, r1, r2: sphere center
    uint public R2; // constant: radius squared (invariant)
    uint[3] public reserves; // x0, x1, x2: AMM reserves
    mapping(address => uint[3]) public balances; // internal user balances

    constructor(uint[3] memory _center, uint[3] memory _initial) {
        center = _center;
        reserves = _initial;

        // Compute initial invariant: R² = sum((ri - xi)^2)
        for (uint i = 0; i < 3; i++) {
            uint dx = abs(center[i], reserves[i]);
            R2 += dx * dx;
        }
    }

    function deposit(uint i, uint amount) external {
        require(i < 3, "Invalid token index");
        balances[msg.sender][i] += amount;
        reserves[i] += amount;

        // Re-compute R² so the new point is on the sphere
        R2 = 0;
        for (uint n = 0; n < 3; n++) {
            uint dx = abs(center[n], reserves[n]);
            R2 += dx * dx;
        }
    }

    function swap(uint i, uint j, uint amountIn) external {
        require(i < 3 && j < 3 && i != j, "Invalid indices");
        require(balances[msg.sender][i] >= amountIn, "Insufficient balance");

        uint k = 3 - i - j;

        // Apply input
        reserves[i] += amountIn;
        balances[msg.sender][i] -= amountIn;

        // Updated distances to the center
        uint di = abs(center[i], reserves[i]);
        uint dk = abs(center[k], reserves[k]);
        uint dj = abs(center[j], reserves[j]);

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

    function abs(uint a, uint b) internal pure returns (uint) {
        return a > b ? a - b : b - a;
    }
}
