# Orbital AMM — 3-Token PoC

This is a minimal implementation of the [Orbital AMM](https://www.paradigm.xyz/2025/06/orbital) invariant for exactly **3 stablecoins**, using a simplified hypersphere constraint.

## Invariant

We define reserves `x = [x₀, x₁, x₂]` and a shared scalar center `r`.  
The system enforces:

```
(r - x₀)² + (r - x₁)² + (r - x₂)² = r²
```

This keeps all reserves on a sphere of radius `r` centered at `(r, r, r)`.

## Swap Rule

To swap in `Δxᵢ` of token `i` and receive `Δxⱼ` of token `j`, while keeping token `k` fixed:

```
Δxⱼ = sqrt( r² - (r - xₖ)² - (r - xᵢ - Δxᵢ)² ) - (r - xⱼ)
```

Only three tokens are supported. No fees, no liquidity management — just the core math.

## Notes

- PoC only: no safety checks or rounding protections.
- Trades adapt to reserve imbalances via spherical curvature.
