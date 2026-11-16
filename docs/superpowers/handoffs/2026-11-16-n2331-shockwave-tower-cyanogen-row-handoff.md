# Handoff N2331 — ShockwaveTower cyanogen ConsumeLiquids row

## What this slice did

Wired the ShockwaveTower cyanogen liquid row: ConsumeLiquids.efficiency
folds as a REQUIRED row into the first-pass min alongside power, + second-
pass removal via the shared `source_remove_state`. 5 files, +1107/−2,
commit `9a6c18de` on `slice/N2331-shockwave-cyanogen-row`.

## Key facts for the next agent

- Pure `source_shockwave_tower_liquid_consumer_row_state`:
  ConsumeLiquids.efficiency (ConsumeLiquids.java:52-60, min over stacks
  from 1f; single-stack def collapses to min(cyanogen / (0.025·ed·mult),
  1f)) + second-pass removal (ConsumeLiquids.java:44-49, only when update
  && efficiency > 0). ConsumeLiquids extends Consume DIRECTLY (:11) — a
  different class from ConsumeLiquidBase; the port follows the
  ConsumeLiquids lines (the single-stack numbers coincide with
  ConsumeLiquid's).
- The tick syncs the sprite liquids meta into the frame before the fold and
  lazily initializes the store when missing (LiquidBridge precedent) —
  REQUIRED because the shockwave-tower catalog entry has NO
  consumeLiquid/consumeLiquids property, so PortGame binds no store at
  placement (PortGame.gd:30-34). The proof initializes the store explicitly
  before seeding.
- Ledger java_source kept as ShockwaveTower.java per the N2255 lesson (no
  consumer_slices shard failure). Shards changed: defense_* only.
- **⚠️ STALENESS FLAG (fix slice needed):** the required row folds eff 0 for
  old proofs ticking live without seeded cyanogen — N2177 PowerStatus,
  N2187 ShouldConsume (2 keys), N2318 TimerCheck (2 keys), N2327 BulletScan
  (live tick: no fire). N2247 is NOT stale (heat decay unconditional).
  Fix = seed cyanogen in the sprite liquids store in those proofs (DEFERRED
  entry recorded).
- Scope corrections: the brief's Fracker guard cite :221 is WRONG (:221 is a
  docstring comment; guard code :170 shouldConsume + :279 liquid-row guard
  — the driver cites :279); "Fracker:361" frame sync is now at :623.
- SSOT +2/+1/+1/+2 (2 symbols: row + has_liquid_row). DEFERRED 329→332
  (−1 #76 + 4 new).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerCyanogenRowProof` (6 keys) — never run.
