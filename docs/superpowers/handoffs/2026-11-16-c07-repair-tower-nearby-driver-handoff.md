# Handoff — N2211 RepairTower Units.nearby driver integration

Date: 2026-11-16. Batch: N2211 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~15:15 +07 — gate Ran 5937 in 1204.237s, failures=161, skipped=5, 0 errors, all 161 verified Godot-absent). Slice 978de467, docs + GOAL + hash-naming + handoff-status commits below; push to origin main in this tick.**

## Scope

RepairTower Units.nearby driver integration — the next item from the N2210 handoff ("Next: RepairTower Units.nearby driver integration (the slice that stamps `nearby_damaged_units` live on refresh)"). N2210 ported the live query that produces the `nearby_damaged_units` observation but wired NO driver tick line to call it (the N2208/N2209 precedent: a query, not a tick write), so the N2190 refresh still reads a stale or absent observation and the N2191 shouldConsume gate still reads a stale or absent `targets_count`. N2211 is the driver integration and nothing else: one tick line in the existing `source_repair_tower_tick_buildings_state` that calls the N2210 pure function `source_units_nearby_damaged_count_state` and stamps `nearby_damaged_units` live on the RepairTower frame, so the refresh block consumes a live observation at every expiry.

Java (verbatim, from the register's EXACT_EXPRS):

- Refresh block (RepairTower.java:59-66): `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){` / `targets.clear();` / `refresh = 0f;` / `Units.nearby(team, x, y, range, u -> {` / `if(u.damaged()){` / `targets.add(u);`.
- Circle overload (Units.java:444-451): `public static void nearby(@Nullable Team team, float x, float y, float radius, Cons<Unit> cons){` / `nearby(team, x - radius, y - radius, radius*2f, radius*2f, unit -> {` / `if(unit.within(x, y, radius + unit.hitSize/2f)){` / `cons.get(unit);`.
- `damaged()` (HealthComp.java:48): `return health < maxHealth - 0.001f;`.
- Range: class default `public float range = 80f;` (RepairTower.java:21), per-def `range = 100f;` (Blocks.java:6579, unit-repair-tower; catalog captures `range: 100.0`).
- Tick inputs: the game object carries the placed buildings (`public final Building newBuilding(){`, Block.java:1002); the tick's `seconds` is Time.delta (`return efficiency * delta();`, BuildingComp.java:1928).
- Order: updateConsumption before updateTile (BuildingComp.java:2274 before :2277); `potentialEfficiency = efficiency;` (BuildingComp.java:1989).

Driver design (pinned in the test, GREEN implements exactly this):

- One call + stamp in `source_repair_tower_tick_buildings_state`, INSIDE the existing `if has_power_consumer and enabled and not cheating:` block, AFTER `apply_update_consumption_state` and BEFORE the `source_repair_tower_refresh_targets_state(frame, seconds)` call:
  - `const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")` (the file's existing preload pattern; SourceUnitFactoryBuildState.gd:18 precedent).
  - `if float(frame.get("potential_efficiency", 0.0)) > 0.0:` (the Java gate, RepairTower.java:59 — at no power no observation is stamped and the refresh cannot fire anyway).
  - `var nearby_result: Dictionary = source_unit_runtime_state.source_units_nearby_damaged_count_state(frame.get("units", []), team_id, sprite.position.x, sprite.position.y, float(block.properties.get("range", 80.0)))`
  - `frame["nearby_damaged_units"] = nearby_result.get("nearby_damaged_units", 0)`

RED decisions (pinned in the test):

- Units list is the frame's `units` key (`frame.get("units", [])`, the N2141/N2144 precedent — no live units list is stamped on any frame yet, so the count stays 0 until a unit-list slice lands).
- Centre is the tower's world position (`sprite.position`, the turret-targeting precedent, SourceTurretCombatState.gd:96 — Java passes the Building's own x, y). The proof reads `tower.position` at runtime instead of assuming coordinates.
- Radius is the per-def range (`block.properties.get("range", 80.0)` — 100f for unit-repair-tower, falling back to the class default 80f).
- The query runs every powered tick, not only on refresh expiry (Java evaluates it inside the expiry branch — the stamped count at expiry is the same value Java computes, because the refresh consumes the current tick's observation; the only cost is the per-tick query on non-expiry ticks).
- One new result symbol, owned by the tick function (the N2109/N2103 precedent): `source_repair_tower_tick_buildings_state_result.nearby_damaged_units` (RepairTower.java, `Units.nearby(team, x, y, range, u -> {`). No new pure function, no new frame meta key, no SOURCE_CONSUMER_FRAME_META_KEYS change, no simulate_factory wiring change.
- Expected SSOT after GREEN (verify at the GREEN register run, do not trust the estimate): **11436/1661/1583/2957** (symbols +1, ledger +1, contracts +1, schemas +2 — the tick input + result schemas; audit 1335). NO shard change expected (RepairTower.java matches no shard selector, N2188/N2209 precedent).

Deferred (NOT N2211): the live units list on frames (the unit-list slice — until then the driver count stays 0 in live play); the heal loop + warmup lerp + totalProgress advance (RepairTower.java:67-86); the ozone liquid consumer (Blocks.java:6583); suppression coupling (RepairTower.java:31, 69-72).

## RED (14:31 cron worker, ~14:4x +07)

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_tower_nearby_driver.py` (12,530 bytes, 4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_tower_nearby_driver.py` (12,509 bytes; DEFERRED imported from the N2210 register script, never retyped), proof `godot-mindustry/tools/runtime_proofs/C07RepairTowerNearbyDriverProof.gd` (7,388 bytes) + `.tscn` (224 bytes).
- Targeted Ran 4, FAILED (failures=2, errors=2) — classic RED (KeyError 'N2211' x2, missing driver tick line, proof matches:false with the 5 driver keys false). Log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2211-red.log` (Ran 4 in 17.608s). Port 7777 was FREE at run start (no listener; the one pgrep hit was the worker's own shell command line, the N2190 false-positive pattern). javalang 0.13.0 importable (verified at run start, no reinstall needed). Godot 4.6.2 via `PATH="$HOME/workspace/godot-bin:$PATH"`.
- Proof detail at RED (the proof .gd parses and runs — it calls only existing functions): 5 driver keys false, `live_count_not_stamped_at_no_power` TRUE (correctly true even at RED — with no driver line no observation is ever stamped), registry keys true, matches:false. The proof scene runs 5 towers on the real Main scene (A stamps + refresh-consumes, B stamps zero, C proves the per-def range at 90, D proves the no-power gate, E proves the tower-centred query).
- Register --verify 25/25 exprs present (22 exact + 2 inputs + 1 output), exit 0. All 22 exact exprs checked verbatim against Java (RepairTower.java / Units.java / HealthComp.java / Blocks.java / Block.java / BuildingComp.java).
- SSOT unchanged at RED: **11435/1660/1582/2955**, audit 1335. N2211 not yet in the ledger. Nothing staged, nothing committed, no gate launched.

## GREEN (14:45 cron run, ~14:5x +07)

- Driver tick line implemented exactly as pinned in the test: preload const `source_unit_runtime_state` + PE gate `if float(frame.get("potential_efficiency", 0.0)) > 0.0:` + query call + `frame["nearby_damaged_units"]` stamp, AFTER `apply_update_consumption_state` and BEFORE the refresh call, in `SourceRepairTowerBuildState.gd`. No gameplay change — one tick line + comments only. `git diff --check` clean.
- GREEN fix (proof harness ONLY, user boundary respected — gameplay untouched): the first GREEN run was 3/4 — proof key `live_query_centred_on_tower` false, the other 5 keys true. Root cause: the proof's raw `Sprite2D.new()` towers never pass through the texture path (`SourceTextureRuntimeState.configure_block_sprite`, which assigns `sprite.position = game.source_block_sprite_base_position(block, cell)`), so all five towers sat at the origin (0, 0) and E's unit at absolute (10, 0) counted as in-range. Fix: the proof now seeds each tower's position exactly the way the game does (`tower.position = game.source_block_sprite_base_position(blocks_by_id["unit-repair-tower"], cell)` right after `record_placed_block`). No test change, no driver change.
- Targeted **4/4 OK in 15.470s** (re-run, log `~/workspace/goals/mindustry-c06-factory-to-defense-work/hidden_files/n2211-green.log`), including the Godot proof test. Proof `C07RepairTowerNearbyDriverProof`: **6 semantic keys / 9 in JSON, matches:true, 0 false** (JSON `godot-mindustry/tools/runtime_proofs/C07RepairTowerNearbyDriverProof.json` — untracked, never staged per .gitignore:6). Port 7777 was FREE at every proof run. Register --verify 25/25 exprs present, exit 0.
- Family RepairTower + Units **20/20 OK in 76.078s** (N2176 power + N2190 refresh + N2191 shouldConsume + N2210 nearby + N2211 driver; log `n2211-family.log`). Wiring-standard set **32/32 OK in 136.906s** (same 9 modules as N2209/N2210; log `n2211-wiring.log`). **GREEN total 56/56.**
- SSOT 11435/1660/1582/2955 → **11436/1661/1583/2957** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (no diff under `source_modules/` — RepairTower.java matches no shard selector, N2188/N2209 precedent).
- Full gate NOT launched in this run: gates launched by a worker die with the worker's session (11 precedents) — **the main thread must launch it** (`python3 -m unittest discover -s tests` from `tools/mindustry_godot_transpiler`, detached via `nohup setsid`, log `tools/mindustry_godot_transpiler/full-suite-n2211-gate.log`). No Godot on PATH in the gate (the established pattern). Expected: Ran ~5937, failures ~161, skipped 5, 0 errors — the only new failure vs N2210's 5933/160 should be the N2211 proof test itself, Godot-absent in the gate by design.
- origin/main MOVED since N2210: now **9a68eee3** "Merge PR #9: wave20 Godot validation evidence and pending Separator RED" (validation agent's merge) vs local HEAD 343e9865 — **fast-forward/rebase first before pushing**, N2207/N2208 precedent. Do NOT start another gate while the N2211 gate is running; verify its result before commit/push.

## Commits

Classic 5-commit pattern (slice / docs / GOAL / hash-naming / handoff-status), then push to origin main. Slice `978de467` (9 files) → docs `43116028` → GOAL `77591d53` → hash-naming commit → handoff-status commit → push to origin main in this tick. Check origin/main before push (validation agent merges hourly). Spec Done 1660 → 1661 — CHECK the total in the docs commit. GOAL.md §5 debt line for N2211. Proof .json is gitignored — never stage it.

## Gate (VERIFIED 2026-11-16 ~15:15 +07)

Full gate (main thread, PID 6653, ~14:55): **Ran 5937 tests in 1204.237s — FAILED (failures=161, skipped=5), 0 errors, 0 `ERROR:` lines.** All 161 failures verified Godot-absent: 161 × `AssertionError: unexpectedly None`, 161 `^FAIL:` lines, zero non-None AssertionErrors. +4 tests / +1 failure vs N2210's 5933/160: the new N2211 proof test, Godot-absent in the gate by design. Log `tools/mindustry_godot_transpiler/full-suite-n2211-gate.log` (untracked, never staged). No duplicate gate this run. origin/main 9a68eee3 — fast-forwarded before the 5 commits, no rebase needed.

## Next

After N2211: RepairTurret target acquisition / heal advance, ImpactReactor impactPower event, Accelerator battery side. (Do NOT start the C08 inventory unless the user asks.)

## GREEN verification + gate (main thread, ~14:55 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 17.066s; family log Ran 20 OK (76.078s, RepairTower + Units); wiring log Ran 32 OK (136.906s). GREEN total 56/56. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 25/25 exprs present, exit 0.
- Proof-harness fix (worker, during GREEN — no gameplay change): first GREEN run 3/4, key `live_query_centred_on_tower` false because all 5 proof towers sat at (0,0) — `Sprite2D.new()` never goes through the texture path, so `sprite.position` was never assigned. Seeded `tower.position` from `game.source_block_sprite_base_position`, as the real game does.
- Driver line `SourceRepairTowerBuildState.gd:150` — calls `source_units_nearby_damaged_count_state(frame.get("units", []), team_id, sprite.position.x, sprite.position.y, float(block.properties.get("range", 80.0)))` after `apply_update_consumption_state`, before the refresh call, PE-gated.
- SSOT 11435/1660/1582/2955 → **11436/1661/1583/2957** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (verify at completion).
- Gate (main thread, PID 6653, SID 6653, ~14:55): godot NOT on PATH, javalang OK, no stray gate before launch, log fresh and growing (dots + s + F's only, 259 bytes at launch check). Parent subshell PID 6647 stays alive. Expected: Ran ~5937, failures ~161, skipped 5, 0 errors.
- origin/main moved: 343e9865 → **9a68eee3** ("Merge PR #9: wave20 Godot validation evidence and pending Separator RED"). Fast-forward/rebase the 5 N2211 commits onto 9a68eee3 before pushing (N2206/N2207/N2208/N2210 precedent).
