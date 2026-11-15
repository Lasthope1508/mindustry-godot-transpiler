# N2234 UnitCargoLoader updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-3, integration branch `integration/wave-advances-3-n2229-n2234`, base `ff82ab1d`).

## Source

- UnitTransportSourceBuild.updateTile (UnitCargoLoader.java:92-125, build class UnitTransportSourceBuild :85, file in `blocks/units/` NOT `blocks/payloads/`): lost clear — dead/!isAdded unit → null (:94-99); readUnitId unbox via Groups.unit.getByID (:100-101); warmup/readyness approachDelta 1/60f (:104-105); unit == null && canCreate → buildProgress += edelta() / unitBuildTime 480f, totalProgress += edelta (:107-114); >= 1f → spawn manifold (unit.set, rotation 90, Call.unitTetherBlockSpawned) + buildProgress = 0 via spawned() (:127-133).
- Cite corrections: build class :84 (not :85), readUnitId :86, progress :87, warmup :88, unit :89.
- **manifold does NOT set `useUnitCap = false`** — that line at UnitTypes.java:4612 belongs to assemblyDrone; the default `useUnitCap = true` (UnitType.java:205) applies → canCreate is a genuinely live cap check (Units.canCreate(team, unitType)).
- Def unit-cargo-loader (Blocks.java:2270-2282, single def): size 3, unitBuildTime 480f (= class default), consumePower 8f/60f, consumeLiquid nitrogen 10f/60f (second consumer — NOT in this slice), itemCapacity 200; unitType manifold (class default :24, def doesn't override).

## Implementation

- `SourceUnitCargoLoaderBuildState.gd`:
  - Pure `source_unit_cargo_loader_update_tile_advance_state(frame, source_delta, time_scale, found_unit=null, can_create=true)` → 7 result symbols: unit, read_unit_id, warmup, readyness, build_progress, total_progress, spawned_unit.
  - spawned_unit dict adds dead/added flags to round-trip the lost check. Gate reads the PRE-advance unit so a spawn closes the INVERTED N2211 gate the NEXT tick (single ticks never spawn — verified at integration via neighbours: N2165 + N2211 6/8 PASS, 2 proof Godot-absent).

## Commits

- Slice `a0b5eac9` (worker-N2234 re-spawn after VM restart 4, branch `slice/N2234-unit-cargo-loader-update-tile`, 5 files +860/−6; đã push 17:40, remote tip a0b5eac9).
- Integration cherry-pick `e246e650`; SSOT gộp `b5129382` (wave advances-3): 11568/1675/1598/2987 (slice riêng +7/+1/+1/+2 → 11514/1670/1593/2977).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 50/50, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2165 power + N2211 gate: 6/8 PASS, 2 fail đều là proof Godot-absent — không regression.
- Targeted wave (6 module): Ran 24, 18 PASS + 6 proof Godot-absent. Neighbours 12 module power+gate: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-3: Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors — 175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).

## SSOT / DEFERRED

- SSOT slice riêng +7/+1/+1/+2 → 11514/1670/1593/2977; audit 1336, legacy 0. **NO shard changes** (unit_building_slices only matches UnitFactory.java).
- DEFERRED 259 (260 − 3 resolved: advance + unit spawn rows + "live unit fill" (no longer true verbatim since the advance sets frame["unit"]) + 2 new: live unit fill (Groups.unit.getByID live query + live unit creation/application), live canCreate check).
- DEFERRED gộp sau wave advances-3: 265 entries (260 − 14 resolved + 19 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07UnitCargoLoaderUpdateTileProof` — 6 keys: lost_unit_clears, readyness_folds_unit_presence, warmup_approaches_efficiency, build_progress_advances_when_empty, spawn_at_build_complete, live_tick_advances_cargo_frame (replaces frame_defaults_zero, N2228 precedent).
