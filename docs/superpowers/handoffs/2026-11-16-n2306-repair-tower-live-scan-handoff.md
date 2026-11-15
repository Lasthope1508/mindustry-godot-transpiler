# Handoff N2306 — RepairTower live scan

## What this slice did

Wired the RepairTower live scan: pure
`source_repair_tower_supplied_damaged_state(candidates, range, tower_x, tower_y)`
filters frame unit candidates by the Java predicates (damaged + within range +
hitSize/2); the tick stamps `frame["supplied_damaged"]` and the N2227 advance
consumes it. 5 files, +1103/−14, commit `3c2d6629` on
`slice/N2306-repair-tower-live-scan`.

## Key facts for the next agent

- Java "in range" is `unit.within(x, y, radius + unit.hitSize/2f)` (Units.java:
  445-451) with `within` a STRICT squared check (Position.java:44-46) — a unit
  exactly at range + hitSize/2 is OUT. Distance is CENTER distance.
- Missing `hit_size` → 0.0 (point unit); missing health/max_health/
  distance-or-x/y → EXCLUDED. Team filter is the caller's (Units.java:435-436).
- N2227 advance + N2213 gate untouched. `SOURCE_REPAIR_TOWER_RANGE := 100.0`.
- SSOT +5/+1/+1/+2, exactly as expected. DEFERRED 326 (entry 167 rewritten:
  scan clause dropped, heal application kept; +1 new: live unit-candidate
  query). The worker cited entry numbers 0-based.
- Flags: entry 157 was stale (dropped at integration); three RepairTower proofs
  (N2176/N2213/N2227) have stale live-tick keys since N2250 (no ozone seed) —
  fix slices in advances-11.

## Godot debt (this slice)

NEW proof `C07RepairTowerLiveScanProof` (6 keys) — never run.
