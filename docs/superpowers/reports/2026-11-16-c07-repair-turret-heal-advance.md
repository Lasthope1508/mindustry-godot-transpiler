# Report — N2213: RepairTurret heal advance (RepairTurret.java, RepairPointBuild.updateTile, C07)

Date: 2026-11-16. Batch: N2213 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~17:10 +07 — targeted 4/4, family 20/20, wiring 32/32; full gate Ran 5945, failures=163, skipped=5, 0 errors, all 163 verified Godot-absent). Slice fd7a3739 / docs 288e7c47 / GOAL 06bf8d10. Ready to push (origin/main 956cef42 — no rebase needed).**

## What changed

N2212 is DONE + PUSHED (main 956cef42); this slice heals the target N2212 acquires — the deferred item the N2212 report names ("heal advance (the actual healing once a target is acquired)"). Java: `RepairPointBuild.updateTile()` (RepairTurret.java:203-207 — `if(target != null && efficiency > 0){` / `target.heal(repairSpeed * strength * edelta() * multiplier);`). No gameplay change; slice committed in this tick, docs + push below.

What N2213 adds (9 files):

- **One new pure function.** `SourceRepairTurretBuildState.source_repair_turret_heal_advance_state(frame, x, y, repair_speed, delta, multiplier)` (:157) — gates on `target != null && efficiency > 0`, computes the aim angle (`Angles.angle` = atan2(dx, dy) in degrees normalized to [0, 360)), requires the cone STRICT `< 30f` via minimal circular distance, heals `repairSpeed * strength * edelta * multiplier` with `edelta = efficiency * delta`, clamps at maxHealth (HealthComp.heal), returns `{"healed": ..., "heal_amount": ..., "target": ..., "target_health": ...}` with the target as a DUPLICATE (input dict not mutated). `healed` is set by the angle gate, NOT by the amount — strength 0 still reports healed with amount 0.0.
- **One helper + one driver tick line.** `_repair_speed_for_block_id` (:104) — per-def repairSpeed: repair-point 0.45f, repair-turret 3f, class default 0.3f (Blocks.java:6388/6400). Driver tick in `source_repair_turret_tick_buildings_state` (:292-303), after the N2212 acquire stamps: repair_speed per def, multiplier from the N2209 coolant function (accept_coolant only repair-turret, 1.6f), stamps `target` / `target_health` / `healed` / `heal_amount` live.
- **Design note (proof-driven):** the efficiency/cone gates return the UNCHANGED target with `target_health` = current health (proof asserts 50.0 when blocked); only the no-target early return is null / 0.0. Returning the unchanged target also keeps the driver from wiping `frame["target"]` on a blocked tick.
- **Test module + register script** `test_c07_repair_turret_heal_advance.py` + `register_c07_repair_turret_heal_advance.py`. SSOT baseline re-verified from disk: 11443/1662/1585/2961, audit 1335. After GREEN: **11447/1663/1586/2963** (+4/+1/+1/+2), audit 1335. No shard change (verify at completion).
- **Proof scene** `C07RepairTurretHealAdvanceProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6). 8 semantic keys: aimed, strength scale, efficiency scale, blocked without power, blocked outside cone, clamps at max, coolant multiplier, flag set at zero strength.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-repair-turret-heal-advance-handoff.md` — design, RED decisions, Java evidence, scope, gate result.

## RED → GREEN (16:30 cron worker, ~16:5x +07; verified by main thread)

Targeted Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2213' ×2, missing `source_repair_turret_heal_advance_state`). GREEN: targeted **4/4 OK in 15.404s** (first run 3/4: the proof test failed only because `godot` was not on PATH in the exec env; re-ran with `~/workspace/godot-bin` on PATH). Main-thread re-runs 14.157s and 15.348s, both OK. Register --verify 49/49 exprs present (39 exact + 6 inputs + 4 outputs), exit 0. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM.

## Family/wiring (main thread, ~16:5x +07)

Family RepairTurret **20/20 OK in 69.151s** (N2174 power + N2188 shouldConsume + N2209 coolant + N2212 acquire + N2213 heal; log `n2213-family.log`), wiring-standard set **32/32 OK in 120.897s** (same 9 modules as N2209–N2212; log `n2213-wiring.log`). **GREEN total 56/56.** Port 7777 free before every proof run; no parallel run active.

## Gate (VERIFIED 2026-11-16 ~17:10 +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 5999, SID 5999, ~16:53; godot NOT on PATH, javalang OK). Finished: **Ran 5945 tests in 1000.588s — FAILED (failures=163, skipped=5), 0 errors.** All 163 failures verified Godot-absent: 163 × `AssertionError: unexpectedly None` (plain `assertIsNotNone(godot)`), zero `Traceback` lines in the log. +4 tests / +1 failure vs N2212's 5941/162: the new N2213 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN; same pattern as the N2212 proof test already in the failure list). No failure names any N2213 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2213-gate.log` (untracked, never staged). `git diff --check` clean.

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1662 → 1663 + N2213 row) → GOAL.md §5 (Windows proof stays debt). Slice commit (9 files) → docs + GOAL → this hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main 956cef42 — no rebase needed; re-checked before push).

## Deferred (NOT this slice)

- RepairTurret rotation slerp, strength lerp — separate slices.
- ImpactReactor impactPower event, Accelerator battery side.
- Windows Godot proof — debt in GOAL.md §5, same as N2175–N2212.
- C08 inventory — NOT started unless the user asks.
