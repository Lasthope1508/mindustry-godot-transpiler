# Report — N2211: RepairTower Units.nearby driver integration (RepairTower.java:59-66, Units.java:444-451, C07)

Date: 2026-11-16. Batch: N2211 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~15:15 +07 — targeted 4/4, family 20/20, wiring 32/32; full gate Ran 5937, failures=161, skipped=5, 0 errors, all 161 verified Godot-absent). Ready to push (origin/main 9a68eee3 — fast-forwarded before committing, no rebase needed).**

## What changed

N2210 is DONE + PUSHED (main 343e9865); this tick finishes the RepairTower Units.nearby driver integration — the next item the N2210 report names ("RepairTower Units.nearby driver integration (the slice that stamps `nearby_damaged_units` live on refresh)"). Java: the refresh block `if(potentialEfficiency > 0 && (refresh += Time.delta) >= refreshInterval){ targets.clear(); refresh = 0f; Units.nearby(team, x, y, range, u -> { if(u.damaged()){ targets.add(u); } })` (RepairTower.java:59-66) over the circle overload `Units.nearby(team, x, y, radius, cons)` (Units.java:444-451) — yet the port had the N2210 live query but no driver tick line calling it, so the N2190 refresh still read a stale or absent observation and the N2191 shouldConsume gate still read a stale or absent `targets_count`. No gameplay change; slice committed in this tick, docs + push below.

What N2211 adds (9 files):

- **One driver tick line, no new pure function** in the existing `source_repair_tower_tick_buildings_state` (`SourceRepairTowerBuildState.gd:150`): preload const `source_unit_runtime_state` + PE gate `if float(frame.get("potential_efficiency", 0.0)) > 0.0:` + query call `source_units_nearby_damaged_count_state(frame.get("units", []), team_id, sprite.position.x, sprite.position.y, float(block.properties.get("range", 80.0)))` + stamp `frame["nearby_damaged_units"]`, AFTER `apply_update_consumption_state` and BEFORE the `source_repair_tower_refresh_targets_state` call. One new result symbol, owned by the tick function (N2109/N2103 precedent): `source_repair_tower_tick_buildings_state_result.nearby_damaged_units`. Units list is the frame's `units` key (N2141/N2144 precedent — no live units list is stamped on any frame yet, so the count stays 0 until a unit-list slice lands); centre is the tower's world position (`sprite.position`, turret-targeting precedent); radius is the per-def range (100f for unit-repair-tower, Blocks.java:6579, falling back to the class default 80f, RepairTower.java:21). The query runs every powered tick, not only on refresh expiry — the stamped count at expiry is the same value Java computes.
- **Test module + register script** `test_c07_repair_tower_nearby_driver.py` + `register_c07_repair_tower_nearby_driver.py` (register DEFERRED imported from the N2210 register script, never retyped). SSOT baseline re-verified from disk: 11435/1660/1582/2955, audit 1335. After GREEN: **11436/1661/1583/2957** (+1/+1/+1/+2, exactly as expected at RED), audit 1335. No shard change (no shard selection matches RepairTower.java, N2188/N2209 precedent).
- **Proof scene** `C07RepairTowerNearbyDriverProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2208 pure-function proof shape. 6 semantic keys: 5 towers on the real Main scene (A stamps + refresh-consumes, B stamps zero, C proves the per-def range at 90, D proves the no-power gate, E proves the tower-centred query).
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-repair-tower-nearby-driver-handoff.md` — design, RED decisions (all pinned), Java evidence (25 exprs), scope, gate result.

## RED

Tests written first per the slice process (4 targeted: input evidence exact; registration; state; reference graph + actual incl. Godot proof). Targeted run: **Ran 4, FAILED (failures=2, errors=2) — classic RED** (log `n2211-red.log`, 14:31 cron worker): registration ERROR KeyError 'N2211' (register runs at GREEN); evidence ERROR KeyError 'N2211'; state FAIL missing driver tick line; proof FAIL matches:false with the 5 driver keys false. Register --verify: **25/25 exprs present, exit 0** (22 exact + 2 inputs + 1 output). Port 7777 was FREE at run start. VM restart #23 ~14:18 wiped javalang — worker reinstalled 0.13.0, imports OK. `git diff --check` clean.

## GREEN (2026-11-16 ~14:5x +07; main-thread verified ~14:55)

Driver tick line implemented exactly as pinned in the test. One proof-harness fix along the way (no gameplay change): the first GREEN run was 3/4 — proof key `live_query_centred_on_tower` false, the other 5 keys true. Root cause: the proof's raw `Sprite2D.new()` towers never pass through the texture path (`SourceTextureRuntimeState.configure_block_sprite`, which assigns `sprite.position = game.source_block_sprite_base_position(block, cell)`), so all five towers sat at the origin (0, 0) and E's unit at absolute (10, 0) counted as in-range. Fix: the proof now seeds each tower's position exactly the way the game does (`tower.position = game.source_block_sprite_base_position(blocks_by_id["unit-repair-tower"], cell)` right after `record_placed_block`). No test change, no driver change. `git diff --check` clean. Targeted GREEN **Ran 4 OK in 15.470s** (log `n2211-green.log`, includes the Godot proof run); family RepairTower + Units **20/20 OK in 76.078s** (log `n2211-family.log` — N2176 power + N2190 refresh + N2191 shouldConsume + N2210 nearby + N2211 driver); wiring **32/32 OK in 136.906s** (9 modules; log `n2211-wiring.log`). **GREEN tổng 56/56**. Proof `C07RepairTowerNearbyDriverProof.json` (9 keys: 6 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM. Register --verify 25/25 exprs present, exit 0. Port 7777 free at every proof run. Main-thread re-verified GREEN: targeted re-run Ran 4 OK in 17.066s; family log Ran 20 OK; wiring log Ran 32 OK.

## Gate (VERIFIED 2026-11-16 ~15:15 +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 6653, SID 6653, ~14:55; godot NOT on PATH, javalang OK). Finished: **Ran 5937 tests in 1204.237s — FAILED (failures=161, skipped=5), 0 errors, 0 `ERROR:` lines.** All 161 failures verified Godot-absent: 161 × `AssertionError: unexpectedly None` (plain `assertIsNotNone(godot)`), 161 `^FAIL:` lines, zero non-None AssertionErrors. +4 tests / +1 failure vs N2210's 5933/160: the new N2211 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN; same pattern as the N2210 proof test already in the failure list). No failure names any N2211 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2211-gate.log` (untracked, never staged). No duplicate gate this run.

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1660 → 1661 + N2211 row) → GOAL.md §5 (Windows proof stays debt). Slice `978de467` (9 files, fast-forwarded to origin/main 9a68eee3 first — validation merge PR #9 wave20 landed since N2210, docs-only, no rebase needed) → docs `43116028` + GOAL `77591d53` → this hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main re-checked before push). Post-commit sanity: targeted re-run planned after push.

## Deferred (NOT this slice)

- The live units list on frames (the unit-list slice — until then the driver count stays 0 in live play).
- The heal loop + warmup lerp + totalProgress advance (RepairTower.java:67-86).
- The ozone liquid consumer (Blocks.java:6583).
- Suppression coupling (RepairTower.java:31, 69-72).
- RepairTurret target acquisition / heal advance, ImpactReactor impactPower event, Accelerator battery side.
- Windows Godot proof — debt in GOAL.md §5, same as N2175–N2210.
