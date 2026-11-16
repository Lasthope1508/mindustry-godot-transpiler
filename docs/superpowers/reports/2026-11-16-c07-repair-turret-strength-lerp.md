# Report — N2215: RepairTurret strength lerp (RepairTurret.java, RepairPointBuild.updateTile:212, C07)

Date: 2026-11-16. Batch: N2215 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~19:27 +07 — targeted 4/4, family 28/28, wiring 32/32; full gate Ran 5953, failures=165, skipped=5, 0 errors, all 165 verified Godot-absent). Slice (this commit) / docs (this commit) / GOAL (next commit). Ready to push (origin/main 6e90868 — fast-forwarded, no rebase needed).**

## What changed

N2214 is DONE + PUSHED (main 6e90868 after fast-forward from 0ac75c4c); this slice lerps the strength N2213's heal reads — the deferred item the N2214 report names ("strength lerp"). Java: `strength = Mathf.lerpDelta(strength, healed ? 1f : 0f, 0.08f * Time.delta);` (RepairTurret.java:212). No gameplay change; slice committed in this tick, docs + push below.

What N2215 adds (9 files):

- **One new pure function.** `SourceRepairTurretBuildState.source_repair_turret_strength_lerp_state(frame, delta)` (:263) — reads `strength` (frame default 0.0 — Java field default 0, RepairTurret.java:155) and `healed` (frame default false — the same tick's local, set only inside the cone, :206, before the heal :207; stamped by the N2213 heal), target strength 1.0 if healed else 0.0, returns `{"strength": strength + (target_strength - strength) * clampf(0.08 * delta, 0.0, 1.0)}`. lerpDelta multiplies progress by Time.delta and clamps to [0, 1] (Mathf.java:430-432); lerp is plain linear interpolation (Mathf.java:425-427). The lerp runs on EVERY tick — line 212 sits AFTER the `if(target != null && efficiency > 0){` gate (:203) closes, so strength decays toward 0 with no target or no power instead of freezing.
- **One driver tick line.** In `source_repair_turret_tick_buildings_state` (:408), after the N2214 slerp stamps (Java order: angle → cone/heal → slerp → strength lerp, because the heal reads the pre-lerp strength), stamps `strength` live — the FIRST stamp of `frame["strength"]`. Before this slice the N2213 heal read strength 0.0 forever (frame default), so no repair turret ever healed anything; this slice is what unlocks the heal.
- **Test module + register script** `test_c07_repair_turret_strength_lerp.py` + `register_c07_repair_turret_strength_lerp.py`. SSOT baseline re-verified from disk: 11448/1664/1587/2965, audit 1335. After GREEN: **11449/1665/1588/2967** (+1/+1/+1/+2), audit 1335. No shard change (verify at completion).
- **Proof scene** `C07RepairTurretStrengthLerpProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6). 8 semantic keys: rises toward 1 when healed, decays toward 0 when not healed, rises from 0 when healed, decays from 1 when not healed, scales with delta, clamps progress at 1, unchanged at 1 when healed, unchanged at 0 when not healed.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-repair-turret-strength-lerp-handoff.md` — design, RED decisions, Java evidence, scope, gate result.

## RED → GREEN (18:45 cron worker, ~18:5x +07; verified by main thread)

Targeted Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2215' ×2, missing `source_repair_turret_strength_lerp_state`). GREEN: targeted **4/4 OK in 16.310s** (log `n2215-green.log`). Main-thread re-run 15.020s, OK. Register --verify 19/19 exprs present (16 exact + 2 inputs + 1 output), exit 0. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM.

## Family/wiring (main thread, ~19:1x +07)

Family RepairTurret **28/28 OK in 96.187s** (N2174 power + N2188 shouldConsume + N2209 coolant + N2212 acquire + N2213 heal + N2214 slerp + N2215 strength; log `n2215-family.log`), wiring-standard set **32/32 OK in 120.420s** (same 9 modules as N2209–N2214; log `n2215-wiring.log`). **GREEN total 64/64.** Port 7777 free before every proof run; no parallel run active.

## Gate (VERIFIED 2026-11-16 ~19:27 +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 8969, SID 8969, ~19:10; godot NOT on PATH, javalang OK). Finished: **Ran 5953 tests in 1026.067s — FAILED (failures=165, skipped=5), 0 errors.** All 165 failures verified Godot-absent: 165 × `AssertionError: unexpectedly None` (plain `assertIsNotNone(godot)`), zero `ERROR:` lines in the log. +4 tests / +1 failure vs N2214's 5949/164: the new N2215 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN; same pattern as the N2214 proof test already in the failure list). No failure names any N2215 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2215-gate.log` (untracked, never staged). `git diff --check` clean.

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1664 → 1665 + N2215 row) → GOAL.md §5 (Windows proof stays debt). Slice commit (9 files) → docs + GOAL → this hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main 6e90868 — fast-forwarded from 0ac75c4c, no rebase needed; re-checked before push).

## Deferred (NOT this slice)

- RepairTurret remaining rows: read/write persistence (:231-243), drawBeam/draw, config-display, sense rows — separate slices.
- ImpactReactor impactPower event, Accelerator battery side.
- Windows Godot proof — debt in GOAL.md §5, same as N2175–N2214.
- C08 inventory — NOT started unless the user asks.
