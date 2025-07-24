# Orbital AMM — 3-Token PoC

This is a minimal implementation of the [Orbital AMM](https://www.paradigm.xyz/2025/06/orbital) invariant for exactly **3 stablecoins**, using a simplified hypersphere constraint.

## Invariant

Define reserves $x = [x_0, x_1, x_2]$ and a shared scalar center $r$.
The system enforces:

$$
(r - x_0)^2 + (r - x_1)^2 + (r - x_2)^2 = r^2
$$

This keeps all reserves on a sphere of radius $r$ centered at $(r, r, r)$.

## Swap Rule

To swap in $\Delta x_i$ of token $i$ and receive $\Delta x_j$ of token $j$, while keeping token $k$ fixed:

$$
\Delta x_j = \sqrt{ r^2 - (r - x_k)^2 - (r - x_i - \Delta x_i)^2 } - (r - x_j)
$$

Only three tokens are supported. No fees, no liquidity management—just the core math.

## Notes

* **PoC only**: no safety checks or rounding protections.
* Trades adapt to reserve imbalances via spherical curvature.
