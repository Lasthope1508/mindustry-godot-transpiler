# Handoff — N2220 RepairTurret drawSelect/drawPlace range state (C07)

## Status: GREEN (this run, 01:30–01:4x +07). Gate + commit/push pending on the main thread.

## GREEN

- Implemented the two pure functions + `_block_offset_for_block_id` in `SourceRepairTurretBuildState.gd` (after the N2219 draw_beam functions, before `REPAIR_TURRET_SAVE_VERSION`): `source_repair_turret_draw_select_state(x, y, repair_radius)` returning `{"center": Vector2(x, y), "radius": repair_radius, "color": "Pal.accent"}`, `source_repair_turret_draw_place_state(tile_x, tile_y, repair_radius, tilesize, block_offset)` with the pinned center line, and `_block_offset_for_block_id` (4.0 repair-turret, 0.0 otherwise). NO driver tick line (UI, not per-tick).
- Register (NOT --verify) ran: N2220 in ledger, status done. SSOT after: 11467/1670/1595/2981 (symbols +6, Done +1, contracts +2, schema +4). NO shard change (`source_ssot_modules.json` untouched).
- Targeted GREEN: Ran 4 in 13.550s, OK (log `hidden_files/n2220-green.log`) — includes the Godot proof test (8 semantic keys / 11 in JSON, matches:true).
- Family RepairTurret: Ran 40 in 135.635s, OK (log `hidden_files/n2220-family.log`).
- Wiring-standard: Ran 32 in 122.978s, OK (log `hidden_files/n2220-wiring.log`).
- Total: targeted 4/4 + family 40/40 + wiring 32/32 = 76/76. `git diff --check` clean.
- Port 7777 free before the proof run. No VM restart during this run (javalang 0.13.0 importable). origin/main == HEAD == 03816a8d (N2219 DONE + PUSHED); slice files uncommitted.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_draw_select_place.py` (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_draw_select_place.py`, proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretDrawSelectPlaceProof.gd` + `.tscn` (both exist at RED, N2219 pattern).
- Targeted RED (this run, log `hidden_files/n2220-red.log` in the repo root): Ran 4 in 9.534s, FAILED (failures=2, errors=2) — KeyError 'N2220' ×2 (registration + input-evidence tests, slice not yet in the ledger), state-test FAIL (missing `source_repair_turret_draw_select_state`), reference-test FAIL (Godot parse errors: `Static function "source_repair_turret_draw_select_state()" not found in base "SourceRepairTurretBuildState"` + the same for `source_repair_turret_draw_place_state()` and `_block_offset_for_block_id()` — the proof scene runs and fails on the missing functions, the correct RED signal).
- Register --verify 21/21 exprs present, exit 0. This script DOES implement --verify (`def verify()`, `if '--verify' in sys.argv`) — checked first, per the N2218 lesson (never run a register script with --verify unless the file implements it). Do NOT run the register script without --verify until GREEN (it writes SSOT).
- SSOT before: 11461/1669/1593/2977 (verified from disk at RED), audit 1335. N2220 NOT in the ledger. No shard change expected (RepairTurret matches no shard — N2219 precedent; verify from `git status` at GREEN).
- No VM restart during this run (javalang 0.13.0 importable). Port 7777 free before the proof run and after (checked). origin/main == HEAD == 03816a8d (N2219 DONE + PUSHED).

## Scoping pinned in RED (do not re-decide in GREEN)

- N2212-N2215 made the repair turret live (target acquire, heal advance, rotation slerp, strength lerp), N2217 persisted its rotation and N2219 captured the beam state draw() draws each frame — but nothing in the port captured what the selection / placement UI draws. N2220 captures the deterministic dash-circle state; rendering itself stays out of the game, per the user boundary.
- Java: RepairPointBuild.drawSelect() draws one dash circle around the building (`Drawf.dashCircle(x, y, repairRadius, Pal.accent);`, RepairTurret.java:178, inside `public void drawSelect(){`, :177). RepairTurret.drawPlace() draws the same circle at the ghost position (`Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, repairRadius, Pal.accent);`, :98, inside `public void drawPlace(int x, int y, int rotation, boolean valid){`, :95, after `super.drawPlace(x, y, rotation, valid);`, :96).
- Two pure functions on the same family file N2174/N2188/N2209/N2212-N2215/N2217/N2219 built:
  - `static func source_repair_turret_draw_select_state(x: float, y: float, repair_radius: float) -> Dictionary:` returning `{"center": Vector2(x, y), "radius": repair_radius, "color": "Pal.accent"}`.
  - `static func source_repair_turret_draw_place_state(tile_x: int, tile_y: int, repair_radius: float, tilesize: float, block_offset: float) -> Dictionary:` with `var center: Vector2 = Vector2(float(tile_x) * tilesize + block_offset, float(tile_y) * tilesize + block_offset)` returning `{"center": center, "radius": repair_radius, "color": "Pal.accent"}`.
  - Per-def helper `_block_offset_for_block_id(block_id)` returning 4.0 for repair-turret, 0.0 otherwise (Block.offset `offset = ((size + 1) % 2) * tilesize / 2f;`, Block.java:761, tilesize 8, Vars.java:135; repair-turret size 2, Blocks.java:6398; repair-point size 1, no size override in Blocks.java:6386).
  - Radius is the per-def repairRadius resolved by the caller through the EXISTING `_repair_radius_for_block_id` helper (N2212): repair-point 60f (Blocks.java:6389), repair-turret 145f (Blocks.java:6401), class default 50f (`public float repairRadius = 50f;`, RepairTurret.java:32).
  - Color is Pal.accent in both call sites, represented as the string "Pal.accent" (SourceBlockDrawState.gd:182 precedent).
  - NO driver tick line: drawSelect / drawPlace are selection / placement UI, not per-tick — the functions are called from selection / placement code, not from the frame loop.
  - The drawPlace super call (`super.drawPlace(x, y, rotation, valid);`, :96) draws the block itself, not the circle — out of scope.
- Six new result symbols: `source_repair_turret_draw_select_state_result.center`, `.radius`, `.color`, `source_repair_turret_draw_place_state_result.center`, `.radius`, `.color`.
- Proof math pinned (8 semantic keys): select_center_at_building_position / select_radius_repair_point_60 / select_radius_repair_turret_145 / select_color_is_accent / place_center_converts_tile_to_world (tile 10,12, tilesize 8, offset 0.0 → center 80,96) / place_center_applies_block_offset (tile 10,12, tilesize 8, offset 4.0 → center 84,100) / place_radius_repair_turret_145 / place_color_is_accent. Proof output line prefix `C_07_REPAIR_TURRET_DRAW_SELECT_PLACE_PROOF `, scene `tools/runtime_proofs/C07RepairTurretDrawSelectPlaceProof.tscn`.

## GREEN plan (next run) — DONE this run, 01:30–01:4x +07

1. ~~Implement the two pure functions + `_block_offset_for_block_id` in `SourceRepairTurretBuildState.gd` with the EXACT lines the test pins (place after the N2219 draw_beam functions, before `REPAIR_TURRET_SAVE_VERSION`).~~ DONE.
2. ~~Run register (NOT --verify) to add N2220 to SSOT, targeted GREEN 4/4, family RepairTurret (expect 40/40: 36 + 4 new), wiring-standard 32/32, Godot proof (11 keys, matches:true).~~ DONE — 76/76 total, SSOT 11467/1670/1595/2981, no shard change.
3. Check port 7777 free before any proof run; never run proof scenes in parallel with another run. NOTE: godot is NOT on PATH in this shell — the binary lives at `~/workspace/godot-bin/godot`; run the reference/proof tests with `PATH=~/workspace/godot-bin:$PATH`, otherwise the reference test fails with `godot is None`.
4. The register script DOES implement --verify (checked at RED) — but it must NOT be re-run at GREEN. Do not generalize: check every new register script for 'verify' first (N2218 lesson).

## Remaining (main thread)

1. Full gate from the main thread only after GREEN (worker-launched gates die with the worker session — N2214/N2219 lesson).
2. The classic 5-commit pattern + push after the gate footer is verified (spec Done 1669 → 1670 + N2220 row; GOAL.md §5 Windows debt line for N2220 names the slice commit hash).
3. Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2220

Next deferred C07 item per backlog: RepairTurret shouldAmbientSound (RepairTurret.java:181-184) / status() (RepairTurret.java:225-228), or the next family. (Do NOT start the C08 inventory unless the user asks.)

## Commits

- Slice: `c2f81746` (C07: N2220 RepairTurret drawSelect/drawPlace — 9 files).
- Docs: `6dd261a4` (report + handoff + design spec Done 1670 + N2220 row).
- GOAL: `f471c5d3` (GOAL.md §5 Windows debt line for N2220).
- Gate: full gate (main thread, PID 10133, ~01:41) Ran 5973 in 1051.230s, failures=170, skipped=5, 0 errors — all 170 verified Godot-absent asserts (finished ~01:58 +07).
