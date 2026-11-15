# N2224 Fracker updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-2, integration branch `integration/wave-advances-2-n2224-n2228`, base `542b383e`).

## Source

- FrackerBuild.updateTile (Fracker.java:30-44): if efficiency > 0 → accumulator consume check (itemUseTime) → super.updateTile() → accumulator += delta() * efficiency; else branch: warmup decay + lastPump = 0 + dumpLiquid(result), NO super call.
- itemUseTime is 100f as the class default (Fracker.java:7) but the oil-extractor def overrides it to **60f** (Blocks.java:2974) — the driver uses the def constant 60.0.
- pumpAmount 0.25f (Blocks.java:2969); result oil (Blocks.java:2966); capacity 40f (Blocks.java:2971).
- consume() triggers only ConsumeItems overrides (ConsumeItems.java:44-48, multiplier 1f) — removes 1 sand.

## Implementation

- `SourceFrackerBuildState.gd`:
  - Frame keys: accumulator, warmup, pump_time, last_pump, max_pump, fraction (+ `items`, added by this slice).
  - Pure `source_fracker_update_tile_advance_state(frame, ...)` → 7 result symbols: accumulator, warmup, pump_time, last_pump, max_pump, fraction, items.
  - Reuses the pure N2220 SolidPump advance via preload with pump_amount 0.25f (the test asserts `assertNotIn` for the fraction maxf + liquid add, so the reuse is pinned, not duplicated).
  - consume() is DONE via `inventory.remove_item_state` (removes 1 sand when the accumulator reaches itemUseTime).
  - The else-branch dumpLiquid defers (no neighbor dump infra on this path); the sand item intake defers (no live fill for frame["items"] yet).

## Commits

- Slice `46f65f31` (worker-N2224, branch `slice/N2224-fracker-update-tile`, 5 files +1067/−19; đã push 16:56, remote tip 46f65f31).
- Integration cherry-pick `94be3ec4`; SSOT gộp `e76dd9c8` (wave advances-2): 11507/1669/1592/2975 (slice riêng +7/+1/+1/+2 → 11477/1665/1588/2967).

## Tests

- RED đúng mẫu trước GREEN (KeyError N2224 + thiếu function + Godot-absent).
- Targeted post-register: 3/4 PASS (registration, exact-evidence 60/60, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Siblings 9/9 non-proof PASS (Fracker power N2150 + gate N2207 family).
- Targeted wave (5 module): Ran 20, 15 PASS + 5 proof Godot-absent. Neighbours 12 module power+gate+link: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-2: Ran 5969 in 1029.991s, failures=169, skipped=5, 0 errors — 169/169 Godot-absent (164 inherited + 5 new proof tests N2224–N2228).

## SSOT / DEFERRED

- SSOT slice riêng +7/+1/+1/+2 → 11477/1665/1588/2967; audit 1336, legacy 0. 4 production shards đổi.
- DEFERRED 259 (258 − 1 resolved Fracker advance + 2 new: dumpLiquid else-branch + item intake; the fraction live fill is NOT a new entry — the old entry still covers it).
- DEFERRED gộp sau wave advances-2: 260 entries (258 − 8 resolved + 10 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07FrackerUpdateTileProof` — 6 keys: accumulator_advances_with_efficiency, consume_at_item_use_time, super_advance_pumps_oil, warmup_decays_when_no_efficiency, last_pump_zero_when_idle, frame_defaults_zero.
