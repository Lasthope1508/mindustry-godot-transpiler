# Handoff — N2213 RepairTurret heal advance (C07)

## Status: DONE + PUSHED (slice fd7a3739, main 683a84b8).

Next slice after N2212 (DONE + PUSHED, main 956cef42): the heal advance,
`RepairPointBuild.updateTile()` RepairTurret.java:203-207.

## GREEN (this run)

- Pure `source_repair_turret_heal_advance_state(frame, x, y, repair_speed, delta, multiplier)` added to `SourceRepairTurretBuildState.gd` (after the N2212 acquire) with the EXACT lines the test pins, plus `_repair_speed_for_block_id` helper (0.45 / 3.0 / default 0.3) and the driver tick lines after the acquire stamps: repair_speed per def, multiplier from `source_repair_turret_coolant_multiplier_state(frame, accept_coolant, coolant_multiplier)` (accept_coolant = repair-turret only, coolant_multiplier 1.6f), call `source_repair_turret_heal_advance_state(frame, sprite.position.x, sprite.position.y, repair_speed, seconds, multiplier)`, stamps `target` / `target_health` / `healed` / `heal_amount` live.
- Design note (proof-driven): the efficiency/cone gates return the UNCHANGED target with its current health (`target_health` = health, not 0.0) — the proof asserts target_health 50.0 on blocked heals; only the no-target early return is null / 0.0. Returning the unchanged target also keeps the driver from wiping `frame["target"]` on a blocked tick.
- Targeted **4/4 OK in 15.404s** (first run 3/4: the proof test failed only because `godot` was not on PATH in the exec env; re-ran with `~/workspace/godot-bin` on PATH). Proof JSON 11 keys, all true, `matches:true`.
- Family RepairTurret **20/20 OK in 69.151s** (N2174 power + N2188 shouldConsume + N2209 coolant + N2212 acquire + N2213 heal; log `n2213-family.log`). Wiring-standard set **32/32 OK in 120.897s** (same 9 modules as N2209–N2212; log `n2213-wiring.log`). **GREEN total 56/56.**
- Register run (not --verify): SSOT 11443/1662/1585/2961 → **11447/1663/1586/2963** (symbols +4, ledger +1, contracts +1, schema +2 — the +2 is input+result schema for the ONE pure function; the handoff's earlier "+4" expectation was copied from N2212's two functions). Audit report unchanged. Register --verify **49/49**, exit 0. `git diff --check` clean.
- Port 7777 free before every proof run; no parallel run active. javalang 0.13.0 OK at run start (no reinstall needed).

## Remaining (main thread)

1. Full gate from the MAIN THREAD only (worker-launched gates die with the session). Expected: Ran ~5945, failures ~162, skipped 5, 0 errors (all Godot-absent).
2. Then the classic 5-commit pattern + push (slice files: `SourceRepairTurretBuildState.gd`, 4 SSOT JSONs, test + register + proof .gd/.tscn; never stage *.gd.uid or proof .json): slice commit, docs commit (spec Done 1662 → 1663 + N2213 row, handoff, report), GOAL.md §5 Windows debt line for N2213, hash-naming commit, handoff-status commit. Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_heal_advance.py`
  (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_heal_advance.py`,
  proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretHealAdvanceProof.gd` + `.tscn`.
- Targeted Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2213' ×2, missing
  `source_repair_turret_heal_advance_state` in the state test, proof parse error
  `Static function "source_repair_turret_heal_advance_state()" not found in base
  "SourceRepairTurretBuildState"`); log `hidden_files/n2213-red.log` (9.242s).
- Register --verify 49/49 (39 exact + 6 inputs + 4 outputs), exit 0; all exprs
  verified verbatim against the 6 slice sources (RepairTurret / HealthComp /
  BuildingComp / Angles / Blocks / UnitComp).
- javalang was missing at run start (VM restart wiped it again) — reinstalled
  0.13.0 first, nothing lost. Port 7777 free, no parallel run active.

## Scoping pinned in RED (do not re-decide in GREEN)

- One pure function: `source_repair_turret_heal_advance_state(frame, x, y,
  repair_speed, delta, multiplier)` returning `{"healed": ..., "heal_amount": ...,
  "target": ..., "target_health": ...}`. 4 result symbols, 8 semantic proof keys
  (aimed / strength scale / efficiency scale / blocked without power / blocked
  outside cone / clamps at max / coolant multiplier / flag set at zero strength).
- Gate `target != null && efficiency > 0` (RepairTurret.java:203); angle is
  `Angles.angle(x, y, target.x + offset.x, target.y + offset.y)` = atan2(dx, dy)
  in degrees normalized to [0, 360); cone STRICT `< 30f`; distance is the minimal
  circular distance in [0, 180]. `healed` is set by the angle gate, NOT by the
  amount — strength 0 still reports healed with amount 0.0.
- edelta = efficiency * delta (BuildingComp.java:1927-1928); driver passes its
  per-tick `seconds` as delta. heal_amount = repairSpeed * strength * edelta *
  multiplier. HealthComp.heal adds and clamps at maxHealth (`health += amount;`
  + clampHealth). Returned target is a DUPLICATE with healed health — input dict
  not mutated; driver stamps the returned target.
- Frame reads: target (already validated by the N2212 acquire, runs first in the
  same tick), rotation default 90.0, strength default 0.0, efficiency default 1.0,
  offset default Vector2.ZERO. No target dict → healed false, amount 0.0,
  target null, target_health 0.0.
- Rotation slerp (RepairTurret.java:208) and strength lerp (:211) are NOT this
  slice — separate slices. UnitComp.wasHealed flag unmodeled (port tracks no
  wasHealed on unit records); the health increase itself is HealthComp.heal.
- Per-def repairSpeed: repair-point 0.45f, repair-turret 3f (Blocks.java:6388/6400);
  class default 0.3f. Driver resolves it from the block id (N2209 precedent) and
  passes the N2209 coolant multiplier as `multiplier`.

## GREEN plan (next run)

1. Add `source_repair_turret_heal_advance_state` to
   `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (after the N2212
   acquire function) with the EXACT lines the test pins — signature, the
   `if not (target is Dictionary):` early return, `var efficiency/strength/
   rotation/offset` reads, `if efficiency <= 0.0:`, the `fmod(rad_to_deg(atan2(
   target_x - x, target_y - y)) + 360.0, 360.0)` angle, the `abs(fmod(angle -
   rotation, 360.0))` + `> 180.0` fold, `if angle_dist >= 30.0:`,
   `var edelta: float = efficiency * delta`, `var heal_amount: float =
   repair_speed * strength * edelta * multiplier`, `var healed_target:
   Dictionary = target.duplicate()`, `healed_target["health"] = min(health +
   heal_amount, max_health)`, and the two return dicts verbatim. The function
   comment MUST contain, verbatim, every Java line the test asserts
   (`if(target != null && efficiency > 0){`, the angle/heal/slerp/lerp lines,
   `public float strength, rotation = 90;`, `public float repairSpeed = 0.3f;`,
   `void heal(float amount){`, `health += amount;`, `clampHealth();`,
   `health = Math.min(health, maxHealth);`, `public float delta(){`,
   `return Time.delta * timeScale;`, `public float edelta(){`,
   `return efficiency * delta();`, the atan2/angleDist lines,
   `repairSpeed = 0.45f;`, `repairSpeed = 3f;`, `wasHealed = true;`).
   Also define `target_x`/`target_y` (target pos + offset) and
   `health`/`max_health` reads — the test does not pin their lines.
2. Driver tick line in `source_repair_turret_tick_buildings_state`, after the
   acquire stamps: call
   `source_repair_turret_heal_advance_state(frame, sprite.position.x,
   sprite.position.y, repair_speed, seconds, multiplier)` — the test pins this
   exact call line. Needs a per-def `_repair_speed_for_block_id` helper
   (0.45 / 3.0 / default 0.3) and the multiplier from
   `source_repair_turret_coolant_multiplier_state(frame, accept_coolant,
   coolant_multiplier)` with per-def accept_coolant (repair-turret only) and
   coolant_multiplier 1.6f. Stamp the returned `target` / `target_health` on the
   frame (and `healed` / `heal_amount` if the driver pattern wants them).
3. Run register (NOT --verify) to add N2213 to SSOT, targeted GREEN 4/4,
   family + wiring, Godot proof (11 keys: 8 semantic + matches + 2 harness),
   full gate from the main thread only, then the classic 5-commit pattern +
   push. SSOT before: 11443/1662/1585/2961 (actual after register:
   11447/1663/1586/2963 — symbols +4, ledger +1, contracts +1, schema +2,
   NOT +4 as first estimated; NO shard change — N2212 precedent).
4. Check port 7777 free before any proof run; never run proof scenes in
   parallel with another run. Check `git fetch origin` + origin/main before
   pushing (validation agent merges regularly).

## After N2213

RepairTurret rotation slerp, RepairTurret strength lerp, ImpactReactor
impactPower event, Accelerator battery side. (Do NOT start the C08 inventory
unless the user asks.)

## GREEN verification + gate (main thread, ~16:53 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 14.157s; family log Ran 20 OK (69.151s, RepairTurret N2174+N2188+N2209+N2212+N2213); wiring log Ran 32 OK (120.897s). GREEN total 56/56. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 49/49 exprs present, exit 0.
- Pure function `source_repair_turret_heal_advance_state(frame, x, y, repair_speed, delta, multiplier)` at :157 + helper `_repair_speed_for_block_id` at :104 (0.45/3.0/0.3 per def) + 1 driver tick line (:292-303) after acquire, applying the N2209 coolant multiplier (accept_coolant only repair-turret, 1.6f); stamps target/target_health/healed/heal_amount live.
- Technical note (worker, pinned in proof): gate efficiency/cone returns the target unchanged with target_health = current health (proof asserts 50.0 when blocked); only the early-return no-target case is null/0.0.
- SSOT 11443/1662/1585/2961 → **11447/1663/1586/2963** (symbols +4, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (verify at completion).
- Gate (main thread, PID 5999, SID 5999, ~16:53): godot NOT on PATH, javalang OK, no stray gate before launch, log fresh and growing (dots + F's only, 303 bytes at launch check). Parent subshell PID 5993 stays alive. Expected: Ran ~5945, failures ~162, skipped 5, 0 errors.
- Gate result (finished ~17:10 +07): Ran 5945 tests in 1000.588s — FAILED (failures=163, skipped=5), 0 errors. All 163 failures verified Godot-absent: 163 × `AssertionError: unexpectedly None`, zero `Traceback` lines. +4 tests / +1 failure vs N2212's 5941/162: the new N2213 proof test, Godot-absent in the gate env (its real Godot proof ran green headless). Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2213-gate.log` (untracked, never staged).
