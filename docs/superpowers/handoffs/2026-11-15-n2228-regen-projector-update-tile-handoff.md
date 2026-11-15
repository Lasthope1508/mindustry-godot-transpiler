# Handoff N2228 — RegenProjector updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-2). Slice `d84414e8` trên branch `slice/N2228-regen-projector-update-tile` (base `542b383e`, đã push 16:59, remote tip d84414e8). Integration `integration/wave-advances-2-n2224-n2228`: cherry-pick `741652ea` + coordinator fix `f240da22` (đổi key `suppressed` → `heal_suppressed`) + SSOT gộp `e76dd9c8` (11507/1669/1592/2975).

## What changed

- `SourceRegenProjectorBuildState.gd`: pure `source_regen_projector_update_tile_advance_state(frame, ...)` → 9 result symbols (last_change, warmup, total_time, optional_timer, did_regen, any_targets, mend_map, heal_amount, consumed); frame inputs targets / heal_suppressed / tile_changes (default 1, World.java:35); `_initial_frame` mở rộng 7 keys; driver constants healPercent 4f/60f, optionalMultiplier 2f, optionalUseTime 480f.
- New: `test_c07_regen_projector_update_tile.py`, `register_c07_regen_projector_update_tile.py`, `C07RegenProjectorUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

RegenProjectorBuild.updateTile (RegenProjector.java:**122–179** — scope said 123-179, corrected by grep). warmup approachDelta toward didRegen?1:0 1/70f; totalTime += warmup*Time.delta; checkSuppression → return; anyTargets = targets.contains(damaged); optionalTimer += edelta()*optionalEfficiency, >= optionalUseTime 480f → consume(); healAmount = lerp(1, 2f, optionalEfficiency)*4f/60f; mendMap[pos] = min(max(value, healAmount*edelta()*block.health/100), block.health − build.health). mendMap là **static-shared** (RegenProjector.java:23) — port track per-building mend_map (deviation đã ghi).

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +9/+1/+1/+2 → 11479/1665/1588/2967 (slice riêng), audit 1336, legacy 0. Exact exprs 67. DEFERRED 258. Defense shards đổi (defense_slices + defense_api_contracts). N2160 + N2214 6/8 (2 proof Godot-absent) — không regression.
- **Integration fix `f240da22`**: slice dùng frame key `suppressed`; coordinator đổi sang `heal_suppressed` (4 files, 13 dòng) vì N2215 BuildTurret đã dùng `heal_suppressed` (SourceBuildTurretBuildState.gd:48/:74-75) + AGENTS.md normalize. N2227 cũng dùng `heal_suppressed` — wave thống nhất.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07RegenProjectorUpdateTileProof` — 6 keys: any_targets_folds_damaged_targets, mend_map_accumulates_heal_amount, warmup_approaches_one_when_regen, optional_timer_advances_and_resets, no_heal_when_suppressed, live_tick_advances_regen_frame.

## Deferred (không trong slice này)

- consume() (chỉ model advance + reset; tick chạm ngưỡng báo qua pure result `consumed`); mendMap flush CẢ application + cadence (static-shared, cần world.build(pos) live frames + state.updateId); updateTargets live query; effect chance (no RNG trong pure advance); suppression live fill; disabled early return.
