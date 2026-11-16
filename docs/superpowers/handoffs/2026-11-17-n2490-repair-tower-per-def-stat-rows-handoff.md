# Handoff N2490 — RepairTower per-def stat rows

## What this slice did

One pure-only stats pure (N2304 / N2442 verification-slice
precedent): `source_repair_tower_per_def_stats_state` returns
{size, range, heal_amount, requirements} — the def's rows for
unit-repair-tower, CLASS defaults for an unknown def id. 5
files, +715/−1, commit `ddfa5a197` on
`slice/N2490-repair-tower-per-def-stat-rows`.

## Key facts for the next agent

- Def (Blocks.java:6575-6583): size 2, range 100f, healAmount
  1.5f, requirements graphite 90 / silicon 90 / tungsten 80.
  The ONLY RepairTower def — no family split.
- Class fallback: size 1 (Block.java:215) / range 80f
  (RepairTower.java:21) / healAmount 1f (:24) / requirements
  {} (Block.java:356).
- Requirements dict is {item: amount} (Accelerator
  capacities precedent); catalog carries the same rows as an
  Array of {item, amount} dicts.
- Blocks.load():188 is the real enclosing method for the
  ledger entry.
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #36 resolved
  (231→230).

## Godot debt (this slice)

- NEW proof `C07RepairTowerPerDefStatRowsProof` (6 keys)
  — never run.
