# Handoff — N2221 RepairTurret shouldAmbientSound/status (C07)

## Status: DONE (gate GREEN, ~03:0x +07). Awaiting push — main thread only.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_should_ambient_sound_status.py` (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_should_ambient_sound_status.py`, proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldAmbientSoundStatusProof.gd` + `.tscn` (both exist at RED, N2220 pattern).
- Targeted RED (this run, log `hidden_files/n2221-red.log` in the repo root): Ran 4 in 10.662s, FAILED (failures=2, errors=2) — KeyError 'N2221' ×2 (registration + input-evidence tests, slice not yet in the ledger), state-test FAIL (missing `source_repair_turret_should_ambient_sound_state` / `source_repair_turret_status_state`), reference-test FAIL (Godot parse errors: `Static function "source_repair_turret_should_ambient_sound_state()" not found in base "SourceRepairTurretBuildState"` + the same for `source_repair_turret_status_state()` — the proof scene runs and fails on the missing functions, the correct RED signal).
- Register --verify 16/16 exprs present, exit 0. One fix during RED: the `tick` input's java_expr is the BuildingComp.java status line, so it needed `source=BUILDING_COMP` in the register (the `backed()` default source is RepairTurret.java — first run was 15/16 with `MISSING: tick: ...`). This script DOES implement --verify (`def verify()`, `if '--verify' in sys.argv`) — checked first, per the N2218 lesson (never run a register script with --verify unless the file implements it). Do NOT run the register script without --verify until GREEN (it writes SSOT).
- SSOT before: 11467/1670/1595/2981 (verified from disk at RED), audit 1335. N2221 NOT in the ledger. No shard change expected (RepairTurret matches no shard — N2219/N2220 precedent; verify from `git status` at GREEN).
- No VM restart during this run (javalang 0.13.0 importable). Port 7777 free before the proof run and after (checked). origin/main == HEAD == 8f728f60 (N2220 DONE + PUSHED).

## GREEN (done this run, ~02:3x–02:4x)

- Two pure functions implemented in `SourceRepairTurretBuildState.gd` after the N2220 draw_place functions, before `REPAIR_TURRET_SAVE_VERSION`, exactly as pinned: `source_repair_turret_should_ambient_sound_state(frame)` returning `{"should_ambient_sound": has_target and efficiency > 0.0}`; `source_repair_turret_status_state(frame, tick)` with the `absf(potential_efficiency) <= 0.01` gate, the BuildingComp super.status() legs (logicDisable / noOutput / noInput / active via `fmod(tick / 30.0, 1.0) < efficiency`), reusing N2188 `source_repair_turret_should_consume_state` + canonical `production_valid_state()`. NO driver tick line (read functions). One fix during GREEN: the first targeted run failed 2/4 — the two `return ...;` Java lines were paraphrased in comments ("returns `target...`") so the verbatim `assertIn` missed them; fixed by writing each Java line as its own comment line. Targeted re-run Ran 4 OK in 15.517s.
- Register run (NOT --verify) → SSOT **11469/1671/1597/2985** (symbols +2, Done +1, contracts +2, schema +4), N2221 in the ledger, verified from disk. NO shard change (git diff --stat on source_modules/ empty).
- Targeted GREEN 4/4 OK, family RepairTurret 44/44 OK in 150.386s (log `hidden_files/n2221-family.log`), wiring-standard 32/32 OK in 124.950s (9 modules, log `hidden_files/n2221-wiring.log`). **Total 80/80.** `git diff --check` clean.
- Godot proof: `C07RepairTurretShouldAmbientSoundStatusProof.json` — 11 keys, all true, matches:true (8 semantic + registry_valid + one_headquarter_per_ssot + matches), headless Godot 4.6.2-stable Linux in this VM. Port 7777 free before/after. The proof .json is untracked (never staged, per rule).
- No VM restart during GREEN (javalang 0.13.0 importable). origin/main == HEAD == 8f728f60 (unchanged — no push yet).

## Scoping pinned in RED (do not re-decide in GREEN)

- N2212-N2215 made the repair turret live (target acquire, heal advance, rotation slerp, strength lerp), N2217 persisted its rotation, N2219 captured the beam state draw() draws each frame and N2220 the dash-circle state — but nothing in the port captured when the turret plays its ambient sound or what status it reports. N2221 captures both.
- Java: RepairPointBuild.shouldAmbientSound() returns `target != null && efficiency > 0f;` (RepairTurret.java:182, inside `public boolean shouldAmbientSound(){`, :181). RepairPointBuild.status() returns `Mathf.equal(potentialEfficiency, 0f, 0.01f) ? BlockStatus.noInput : super.status();` (RepairTurret.java:226, inside `public BlockStatus status(){`, :225).
- super.status() is BuildingComp.status() (BuildingComp.java:632-646): `if(!enabled){ return BlockStatus.logicDisable; }` (:633-635), `if(!shouldConsume()){ return BlockStatus.noOutput; }` (:637-639), `if(efficiency <= 0 || !productionValid()){ return BlockStatus.noInput; }` (:641-643), `return ((state.tick / 30f) % 1f) < efficiency ? BlockStatus.active : BlockStatus.noInput;` (:645).
- Two pure functions on the same family file N2174/N2188/N2209/N2212-N2215/N2217/N2219/N2220 built (place after the N2220 draw_place functions, before `REPAIR_TURRET_SAVE_VERSION`):
  - `static func source_repair_turret_should_ambient_sound_state(frame: Dictionary) -> Dictionary:` returning `{"should_ambient_sound": has_target and efficiency > 0.0}` where `has_target = bool(frame.get("has_target", false))` (the live target observation stamped every tick by the N2212 acquire; absent means "no observation yet", so it reads false) and `efficiency = float(frame.get("efficiency", 1.0))` (folded efficiency stamped every tick by the driver via apply_update_consumption_state; absent folds to 1.0, the N2174 missing-stamp precedent).
  - `static func source_repair_turret_status_state(frame: Dictionary, tick: float) -> Dictionary:` returning `{"status": <String>}`:
    - `potential_efficiency = float(frame.get("potential_efficiency", 0.0))` (stamped every tick by the driver via apply_update_consumption_state; absent reads 0.0 — the Java transient field default, `transient float potentialEfficiency;`, BuildingComp.java:89 — so an unticked frame reports noInput, exactly like Java before the first updateConsumption).
    - `if absf(potential_efficiency) <= 0.01:` → `{"status": source_building_access_state.SOURCE_BUILDING_STATUS_NO_INPUT}` — Mathf.equal(potentialEfficiency, 0f, 0.01f) is `Math.abs(a - b) <= tolerance` (Mathf.java:554-556, arc-upstream/arc-core/src/arc/math/Mathf.java).
    - Else super.status(): `enabled = bool(frame.get("enabled", true))` false → `SOURCE_BUILDING_STATUS_LOGIC_DISABLE`; `source_repair_turret_should_consume_state(frame)` (N2188) false → `SOURCE_BUILDING_STATUS_NO_OUTPUT`; `efficiency = float(frame.get("efficiency", 1.0))` <= 0.0 or not `source_building_access_state.production_valid_state()` (canonical true) → `SOURCE_BUILDING_STATUS_NO_INPUT`; `if fmod(tick / 30.0, 1.0) < efficiency:` → `SOURCE_BUILDING_STATUS_ACTIVE`, else `SOURCE_BUILDING_STATUS_NO_INPUT`.
    - The tick arrives as an explicit float param, not from the frame (the driver stamps no tick key). Status strings are the SourceBuildingAccessState constants ("logicDisable" / "noOutput" / "noInput" / "active").
  - NO driver tick line: status() / shouldAmbientSound() are read functions (UI + the ambient-sound gate BuildingComp.update() calls), not per-tick — the live-loop ambient-sound gate call waits for its own slice (deferred).
- Two new result symbols: `source_repair_turret_should_ambient_sound_state_result.should_ambient_sound`, `source_repair_turret_status_state_result.status`. Slice sources: RepairTurret.java + BuildingComp.java (super.status()).
- Proof math pinned (8 semantic keys): ambient_true_target_and_efficiency (has_target true, efficiency 1.0 → true) / ambient_false_no_target (has_target false, efficiency 1.0 → false) / ambient_false_zero_efficiency (has_target true, efficiency 0.0 → false) / status_no_input_zero_potential (potential 0.0 → noInput) / status_no_input_near_zero_potential (potential 0.005 → noInput, inside the 0.01 tolerance) / status_logic_disable (potential 1.0, enabled false → logicDisable) / status_no_output_no_consume (potential 1.0, enabled true, has_target false → noOutput via the N2188 gate) / status_active (potential 1.0, enabled true, has_target true, efficiency 1.0, tick 0.0 → (0/30)%1 = 0 < 1.0 → active). Proof output line prefix `C_07_REPAIR_TURRET_SHOULD_AMBIENT_SOUND_STATUS_PROOF `, scene `tools/runtime_proofs/C07RepairTurretShouldAmbientSoundStatusProof.tscn`.

## Gate (main thread, ~02:42–02:59 +07)

- Full gate (main thread, PID 3888, log `tools/mindustry_godot_transpiler/full-suite-n2221-gate.log`): Ran 5977 in 1033.561s, failures=171, skipped=5, 0 errors — all 171 verified `AssertionError: unexpectedly None` (Godot-absent), exactly as expected (170 inherited + 1 new N2221 proof test). No VM restart during the gate (javalang 0.13.0 importable).
- origin/main fast-forwarded 8f728f60 → 99294edc before the commits (PR #17 validation merge, docs-only: N2390/N2391/N2392 sense proofs on Windows) — no rebase needed.

## Remaining (main thread)

1. The classic 5-commit pattern + push after the gate footer is verified (spec Done 1670 → 1671 + N2221 row; GOAL.md §5 Windows debt line for N2221 names the slice commit hash).
2. Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2221

Next deferred C07 item per backlog: next RepairTurret row per backlog (config-display / sense rows), or the next family. (Do NOT start the C08 inventory unless the user asks.)
