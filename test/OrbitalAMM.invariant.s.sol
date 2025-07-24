// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/OrbitalAMM.sol";
import {console} from "forge-std/console.sol";

contract OrbitalInvariantTest is Test {
    OrbitalAMM amm;
    uint256 expectedInvariant; // Ghost variable to track expected invariant

    function setUp() public {
        uint[3] memory initial = [uint(1e18), 2e18, 3e18];
        uint[3] memory r = [uint(4e18), 4e18, 4e18];
        amm = new OrbitalAMM(r, initial);
        
        // Single deposit to establish liquidity and set expected invariant
        amm.deposit(0, 1e18);
        expectedInvariant = amm.R2();
        
        // Verify initial state
        assertEq(sphericalInvariant(), expectedInvariant);
        
        // Exclude deposit function from fuzzing - we only want to test swaps
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = amm.deposit.selector;
        excludeSelector(FuzzSelector({
            addr: address(amm),
            selectors: selectors
        }));
    }

    function invariant_sphericalInvariantHolds() public {
        // Test that the spherical invariant is preserved (with small tolerance for rounding)
        uint currentInvariant = sphericalInvariant();
        uint tolerance = expectedInvariant / 100000; // 0.001%
        assertLe(diff(currentInvariant, expectedInvariant), tolerance);
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
