# Handoff — N2215 RepairTurret strength lerp (C07)

## Status: DONE + PUSHED (slice dcfff971, main 0c41db50).

Next slice after N2214 (DONE + PUSHED, main 0ac75c4c): the strength lerp,
`RepairPointBuild.updateTile()` RepairTurret.java:212.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_strength_lerp.py`
  (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_strength_lerp.py`,
  proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretStrengthLerpProof.gd` + `.tscn`.
- Targeted RED: Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2215' ×2, missing `source_repair_turret_strength_lerp_state` in the state test + reference test `AssertionError: unexpectedly None` for godot, not on PATH in this shell); log `hidden_files/n2215-red.log` (0.229s).
- Register --verify 19/19 (16 exact + 2 inputs + 1 output), exit 0; all exprs verified verbatim against the 3 slice sources (RepairTurret / Mathf / Time).
- javalang 0.13.0 OK at run start (no reinstall needed). Port 7777 free, no parallel run active. No VM restart during this run.

## Scoping pinned in RED (do not re-decide in GREEN)

- One pure function: `source_repair_turret_strength_lerp_state(frame, delta)` returning `{"strength": ...}` — ONLY strength. 8 semantic proof keys (rises toward 1 when healed / decays toward 0 when not healed / rises from 0 when healed / decays from 1 when not healed / scales with delta / clamps progress at 1 / unchanged at 1 when healed / unchanged at 0 when not healed).
- The lerp runs on EVERY tick — line 212 sits AFTER the `if(target != null && efficiency > 0){` gate (RepairTurret.java:203) closes, so strength decays toward 0 with no target or no power instead of freezing. `healed` is the same tick's local (`boolean healed = false;`, RepairTurret.java:200, set `healed = true;` only inside the cone, :206, before the heal :207) — the N2213 heal stamps it on the frame, so the pure function reads `frame.get("healed", false)` (absent -> false, no heal observed).
- Formula: `strength + (target_strength - strength) * clampf(0.08 * delta, 0.0, 1.0)` where target_strength is 1.0 if healed else 0.0. lerpDelta multiplies progress by Time.delta and clamps to [0, 1] (Mathf.java:430-432, `return lerp(fromValue, toValue, clamp(progress * Time.delta));`); lerp is plain linear interpolation (Mathf.java:425-427, `return fromValue + (toValue - fromValue) * progress;`). Driver passes its per-tick `seconds` as delta (N2212/N2213/N2214 precedent), so progress = clampf(0.08 * delta, 0.0, 1.0).
- Driver calls the lerp AFTER the N2214 slerp in the same tick (Java order: angle → cone/heal → slerp → strength lerp), because the heal reads the pre-lerp strength. This is the FIRST stamp of `frame["strength"]` — before N2215 the N2213 heal read strength 0.0 forever (frame default), so no repair turret ever healed anything.
- strength is a Java field default 0 (`public float strength, rotation = 90;`, RepairTurret.java:155) — frame default 0.0, NOT 90 (that default belongs to rotation).
- SSOT before: 11448/1664/1587/2965. Expected after register: 11449/1665/1588/2967 (symbols +1, ledger +1, contracts +1, schema +2; NO shard change — N2213/N2214 precedent).

## GREEN plan

1. Add `source_repair_turret_strength_lerp_state` to `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (after the N2214 rotation slerp) with the EXACT lines the test pins — signature, the `var strength` / `var healed` / `var target_strength` / `var progress` reads, and the `return {"strength": strength + (target_strength - strength) * progress}` verbatim. The function comment MUST contain, verbatim, every Java line the test asserts (lerp line :212, `public float strength, rotation = 90;`, lerp/lerpDelta/clamp lines, `public static float delta = 1f;`, `boolean healed = false;`, `healed = true;`, the heal line :207, the gate :203).
2. Driver tick line in `source_repair_turret_tick_buildings_state`, after the slerp stamps: call `source_repair_turret_strength_lerp_state(frame, seconds)` — the test pins this exact call line. Stamp the returned `strength` live (`frame["strength"]`).
3. Run register (NOT --verify) to add N2215 to SSOT, targeted GREEN 4/4, family + wiring, Godot proof (11 keys: 8 semantic + matches + 2 harness), full gate from the main thread only, then the classic 5-commit pattern + push. SSOT before: 11448/1664/1587/2965.
4. Check port 7777 free before any proof run; never run proof scenes in parallel with another run. Check `git fetch origin` + origin/main before pushing (validation agent merges regularly). NOTE: godot is NOT on PATH in this shell — the binary lives at `~/workspace/godot-bin/godot`; GREEN must run the reference/proof tests with `PATH=~/workspace/godot-bin:$PATH` (or the equivalent the N2214 GREEN run used), otherwise the reference test fails with `godot is None`.
5. Proof math pinned: one tick (delta 1/60) moves strength by 0.08/60 = 0.0013333 of the gap — 0.5 healed → 0.5006667, 0.5 not healed → 0.4993333, 0.0 healed → 0.0013333, 1.0 not healed → 0.9986667 (tolerance 0.0001); delta 1.0 → 0.5 healed → 0.54; delta 60.0 clamps progress to 1.0 → 0.25 healed → 1.0.

## GREEN (this run)

- Pure `source_repair_turret_strength_lerp_state(frame, delta)` added to `SourceRepairTurretBuildState.gd` (after the N2214 rotation slerp) with the EXACT lines the test pins, plus 1 driver tick line after the slerp stamps (`source_repair_turret_strength_lerp_state(frame, seconds)`) — stamps `strength` live, the FIRST stamp of `frame["strength"]`.
- Targeted **4/4 OK in 16.310s** (log `hidden_files/n2215-green.log`). Proof JSON 11 keys, all true, `matches:true`.
- Family RepairTurret **28/28 OK in 96.187s** (N2174 + N2188 + N2209 + N2212 + N2213 + N2214 + N2215; log `n2215-family.log`). Wiring-standard set **32/32 OK in 120.420s** (same 9 modules as N2209–N2214; log `n2215-wiring.log`). **GREEN total 64/64.**
- Register run (not --verify): SSOT 11448/1664/1587/2965 → **11449/1665/1588/2967** (symbols +1, ledger +1, contracts +1, schema +2 — exactly as scoped). Audit report unchanged (1335). Register --verify **19/19**, exit 0. `git diff --check` clean. No shard change.
- Standalone Godot proof (Linux binary, headless): exit 0, 11 keys all true, `matches:true`, no ERROR lines (log `hidden_files/n2215-proof.log`).
- Port 7777 free before every proof run; no parallel run active. javalang 0.13.0 OK at run start (no reinstall needed). No VM restart during this run.
- Nothing staged, committed, or pushed (per task brief). Design spec / report / GOAL.md §5 NOT touched — main thread handles them with the gate + push.

## Remaining (main thread)

1. Full gate — MUST be launched from the main thread (worker sessions die with the session; N2214 precedent). Expected: Ran ~5953, failures ~165, skipped 5, 0 errors — all Godot-absent asserts.
2. The classic 5-commit pattern + push (slice commit, docs commit, GOAL.md §5 Windows debt line, hash-naming commit, handoff-status commit). Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2215

ImpactReactor impactPower event, Accelerator battery side. (Do NOT start the C08 inventory unless the user asks.)

## GREEN verification + gate (main thread, ~19:10 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 15.020s; family log Ran 28 OK (96.187s, RepairTurret N2174+N2188+N2209+N2212+N2213+N2214+N2215); wiring log Ran 32 OK (120.420s). GREEN total 64/64. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 19/19 exprs present, exit 0.
- Pure function `source_repair_turret_strength_lerp_state(frame, delta)` at :263 + 1 driver tick line (:408) after the N2214 slerp; stamps frame["strength"] live (RepairTurret.java:212). Strength rises toward 1 while healing, decays toward 0 when not — this is what unlocks the N2213 heal (it read strength 0.0 forever before this slice).
- SSOT 11448/1664/1587/2965 → **11449/1665/1588/2967** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (verify at completion).
- Gate (main thread, PID 8969, SID 8969, ~19:10): godot NOT on PATH, javalang OK, no stray gate before launch, log fresh and growing (dots + F's only, 298 bytes at launch check). Parent subshell PID 8963 stays alive. Expected: Ran ~5953, failures ~165, skipped 5, 0 errors.

## Gate footer + completion (main thread, ~19:27 +07)

- Gate (main PID 8969): **Ran 5953 in 1026.067s, FAILED (failures=165, skipped=5), 0 errors** — all 165 verified Godot-absent (165 × `AssertionError: unexpectedly None`, 0 `ERROR:` lines). +4 tests / +1 failure vs N2214 (5949/164): the new N2215 proof test. Log `tools/mindustry_godot_transpiler/full-suite-n2215-gate.log`.
- Completion: fast-forwarded origin/main 0ac75c4c → 6e90868 (PR #12 wave26 validation merge, docs-only) before the 5 commits — no rebase needed. Slice commit (9 files) → docs commit (report + handoff + spec Done 1665 + N2215 row) → GOAL.md §5 debt line → hash-naming commit → handoff-status commit → push to origin main.
- SSOT 11449/1665/1588/2967 verified from disk at completion; NO shard change.

## Commits

- Slice: dcfff971 (C07: N2215 RepairTurret strength lerp, 9 files)
- Docs: bedcf73b (report + handoff + design spec, Done 1665 + N2215 row)
- GOAL: fe1f9c24 (§5 Windows debt line for N2215)
- Hash-naming: (this commit)
- Handoff-status: (next commit)
