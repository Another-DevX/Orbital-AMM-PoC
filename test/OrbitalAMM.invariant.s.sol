// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/OrbitalAMM.sol";
import {console} from "forge-std/console.sol";

contract OrbitalInvariantTest is Test {
    OrbitalAMM amm;

    function setUp() public {
        uint[3] memory initial = [uint(1e18), 2e18, 3e18];
        uint[3] memory r = [uint(4e18), 4e18, 4e18]; // Corrected to match constructor
        amm = new OrbitalAMM(r, initial);
    }

    function testInvariantHoldsAfterSwap() public {
        // Give user some balance to swap
        amm.deposit(0, 1e18);
        
        // After deposit, R2 should be recalculated, so invariant should match
        assertEq(sphericalInvariant(), amm.R2());
        
        // Now test that swap preserves the invariant (with small tolerance for rounding)
        uint beforeInvariant = amm.R2();
        amm.swap(0, 1, 5e17);
        uint afterInvariant = sphericalInvariant();
        
        // Allow small rounding error (less than 0.001%)
        uint tolerance = beforeInvariant / 100000; // 0.001%
        assertLe(diff(afterInvariant, beforeInvariant), tolerance);
    }

    function sphericalInvariant() internal view returns (uint) {
        (uint x0, uint x1, uint x2) = getReserves();

        uint d0 = abs(amm.center(0), x0);
        uint d1 = abs(amm.center(1), x1);
        uint d2 = abs(amm.center(2), x2);

        return d0 * d0 + d1 * d1 + d2 * d2;
    }

    function abs(uint a, uint b) internal pure returns (uint) {
        return a > b ? a - b : b - a;
    }

    function getReserves() internal view returns (uint, uint, uint) {
        return (amm.reserves(0), amm.reserves(1), amm.reserves(2));
    }

    function diff(uint a, uint b) internal pure returns (uint) {
        return a > b ? a - b : b - a;
    }
}
