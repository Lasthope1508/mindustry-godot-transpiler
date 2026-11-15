# N2228 RegenProjector updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-2, integration branch `integration/wave-advances-2-n2224-n2228`, base `542b383e`).

## Source

- RegenProjectorBuild.updateTile (RegenProjector.java:**122–179** — scope said 123-179, corrected by grep): tileChanges → updateTargets indexer.eachBlock range 28; warmup approachDelta toward didRegen?1:0 1/70f; totalTime += warmup*Time.delta; didRegen=false; anyTargets=false; checkSuppression → return; anyTargets = targets.contains(damaged); optionalTimer += edelta()*optionalEfficiency, >= optionalUseTime 60f*8f → consume(); healAmount = lerp(1, optionalMultiplier 2f, optionalEfficiency)*healPercent 4f/60f; mendMap[pos] = min(max(value, healAmount*edelta()*block.health/100), block.health - build.health); mendMap flush on lastUpdateFrame change → build.heal + recentlyHealed + clear.
- Pin-drift verified by grep (cites in the N2160 driver / scope were all wrong; this slice cites correctly): updateTile 122-179 (not 123-179); heal gate :141 (not :142); healAmount :147 (not :148); suppression return :135-137; optionalMultiplier/UseTime :29-30 (not :36-37); mendMap/taken/lastUpdateFrame :22-24 (not :29-31); effectChance :35 (not :40-41); class at :20 (not :29); `range = 28` Blocks.java:2012 (not :2011); `healPercent = 4f/60f` Blocks.java:2019 (not :2018). The stale cites in the N2160 driver are NOT fixed here (they belong to the coordinator cite-cleanup slice).
- mendMap is **static-shared** across projectors (RegenProjector.java:23). `tileChanges` initial value is 1 (World.java:35).

## Implementation

- `SourceRegenProjectorBuildState.gd`:
  - Pure `source_regen_projector_update_tile_advance_state(frame, ...)` → 9 result symbols: last_change, warmup, total_time, optional_timer, did_regen, any_targets, mend_map, heal_amount, consumed.
  - Frame inputs: `targets` (each entry pos/block_health/health/damaged/heal_suppressed, default []), `heal_suppressed` (default false, N2215 precedent), `tile_changes` (default **1** = the Java init value, World.java:35; lastChange −2 so the first tick always refreshes). `_initial_frame` extended with 7 keys with Java defaults.
  - **Integration fix `f240da22`**: the slice originally used the frame key `suppressed`; the coordinator renamed it to `heal_suppressed` (driver + test + register + proof, 4 files, 13 lines) because N2215 BuildTurret already uses `heal_suppressed` (verified SourceBuildTurretBuildState.gd:48/:74-75) and AGENTS.md says to normalize to the SSOT name instead of adding a synonym. N2227 uses `heal_suppressed` too — the wave is now consistent.
  - `heal_percent`/`optionalMultiplier`/`optionalUseTime` are driver constants (single def; the catalog has no healPercent): 4f/60f (def, Blocks.java:2019), 2f, 480f.
  - optionalTimer `consume()`: DEFERRED (only the advance + reset are modeled). `consume()` triggers EVERY consumer (BuildingComp.java:1911-1915) and `ConsumeItems.trigger` removes phaseFabric (ConsumeItems.java:44-48), but the frame has no items — N2193 precedent. The threshold tick is reported via the pure result `consumed` (N2223 `offloaded` precedent).
  - MendMap flush: DEFERRED whole (application + cadence). Per-frame flush is wrong semantics because mendMap is static-shared (projector A would flush B's amounts); flush needs `world.build(pos)` live frames that do not exist in the port; the port has no `state.updateId` source. The port tracks a **per-building mend_map** (documented deviation). Accumulation uses Math.max + cap, so the map converges instead of diverging while unflushed.
  - `consumed` and `heal_amount` are persisted into the frame like N2223 persists `offloaded`/`eff` (pure result, not Java state).
  - A live projector with no targets fill reads `any_targets=false` and does not consume (same behavior N2214 described).

## Commits

- Slice `d84414e8` (worker-N2228, branch `slice/N2228-regen-projector-update-tile`, 5 files +929/−19; đã push 16:59, remote tip d84414e8).
- Integration cherry-pick `741652ea` + coordinator fix `f240da22` (rename frame key `suppressed` → `heal_suppressed`); SSOT gộp `e76dd9c8` (wave advances-2): 11507/1669/1592/2975 (slice riêng +9/+1/+1/+2 → 11479/1665/1588/2967).

## Tests

- RED đúng mẫu trước GREEN (failures=2, errors=2: KeyError N2228 ×2 + thiếu pure function + proof Godot-absent).
- Targeted post-register: 3/4 PASS (registration, exact-evidence 67/67, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sanity check 2 module regen cũ (N2160 power + N2214 gate): 6/8 PASS, 2 fail đều là proof Godot-absent — **không regression**. Phân tích bằng tay: proof N2160 tick 2 vẫn ra efficiency 0 (qua gate thay vì qua power, cùng giá trị); proof N2214 re-seed `any_targets=true` trước tick 2 nên an toàn. Coordinator đã kiểm tra lại ở integration qua neighbours (xem dưới).
- Targeted wave (5 module): Ran 20, 15 PASS + 5 proof Godot-absent. Neighbours 12 module power+gate+link: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-2: Ran 5969 in 1029.991s, failures=169, skipped=5, 0 errors — 169/169 Godot-absent (164 inherited + 5 new proof tests N2224–N2228).

## SSOT / DEFERRED

- SSOT slice riêng +9/+1/+1/+2 → 11479/1665/1588/2967; audit 1336, legacy 0. Defense shards đổi: `defense_slices` + `defense_api_contracts` (tiền lệ N2214; không có defense_symbols/defense_state_schema shards). `source_ssot_modules.json` không đổi.
- DEFERRED 258 (258 − 1 resolved RegenProjector advance + 1 new "RegenProjector updateTile live fill"). Entry "RegenProjector targets computation live fill" GIỮ NGUYÊN verbatim theo tiền lệ N2223 (nửa live-fill vẫn đúng; nửa contains-damaged fold nay đã live — ghi rõ trong test comment).
- DEFERRED gộp sau wave advances-2: 260 entries (258 − 8 resolved + 10 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07RegenProjectorUpdateTileProof` — 6 keys: any_targets_folds_damaged_targets, mend_map_accumulates_heal_amount, warmup_approaches_one_when_regen (incl. total_time 35.5 after 70 ticks / 34.5 when decaying), optional_timer_advances_and_resets, no_heal_when_suppressed, live_tick_advances_regen_frame (fresh-frame defaults + tick 1: eff 0.5, mend[7] 0.5, timer 0.25; tick 2: warmup 1/70, timer 0.5) — live-tick key thay cho `frame_defaults_zero`.
