# Handoff N2311 — RepairTower N2227 proof fix

## What this slice did

Fixed the stale N2227 proof (`C07RepairTowerUpdateTileProof`): seeded ozone
0.1 (N2250 Tower B fill / N2306 pattern) + 3 preloads; comment :98–102
rewritten. 1 file, +17/−3, commit `016da108` on
`slice/N2311-repair-tower-n2227-proof-fix`.

## Key facts for the next agent

- N2250's REQUIRED ozone row folds live-tick efficiency to 0 when the proof
  seeds no ozone — the `warmup_approaches_efficiency_when_healing` key asserted
  eff 0.5.
- Pure-call keys (:48–82) untouched — only live-tick keys go stale this way
  (N2300 precedent).
- Fix slice: no code, no SSOT, no DEFERRED change. Only the proof .gd changed.
- Expected values unchanged (eff 0.5, warmup 0.04, total_progress 1/120,
  heal [0.75]).

## Godot debt (this slice)

- RE-RUN of proof N2227 (`C07RepairTowerUpdateTileProof`).
