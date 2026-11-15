# Handoff N2312 — Separator N2222 proof fix

## What this slice did

Fixed the stale N2222 proof (`C07SeparatorUpdateTileProof`): seeded slag 1.0
on the sprite LIQUIDS meta (N2281 pattern) + 3 preloads. 1 file, +33/−14,
commit `3d22b2cf` on `slice/N2312-separator-n2222-proof-fix`.

## Key facts for the next agent

- N2252's REQUIRED slag row folds live-tick efficiency to 0 when the proof
  seeds no slag — the `live_tick_advances_progress_and_warmup` key asserted
  eff 0.5.
- Slag is a LIQUID (Liquids.slag) — seed on the liquids meta, NOT the items
  dict. Consumption/tick ≈ 0.033, so 1.0 has margin.
- Flagged by worker-N2281 (01:58 16/11), who seeded slag in the N2281 proof
  and noticed N2222 did not.
- Fix slice: no code, no SSOT, no DEFERRED change. Only the proof .gd changed.
- Expected values unchanged.

## Godot debt (this slice)

- RE-RUN of proof N2222 (`C07SeparatorUpdateTileProof`).
