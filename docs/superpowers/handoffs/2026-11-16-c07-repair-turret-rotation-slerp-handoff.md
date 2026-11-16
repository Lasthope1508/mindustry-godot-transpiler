# Handoff — N2214 RepairTurret rotation slerp (C07)

## Status: GREEN + GATE VERIFIED (main thread ~18:19 +07). Targeted 4/4 OK, family 24/24 OK, wiring 32/32 OK — GREEN total 60/60. Full gate Ran 5949, failures=164, skipped=5, 0 errors (all Godot-absent). Slice e1322bb7 / docs 1513486b / GOAL 703081f0. NOT committed/pushed yet.

Next slice after N2213 (DONE + PUSHED, main f3267e50): the rotation slerp,
`RepairPointBuild.updateTile()` RepairTurret.java:209.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_rotation_slerp.py`
  (4 tests), register `tools/mindustry_godot_transpiler/register_c07_repair_turret_rotation_slerp.py`,
  proof `godot-mindustry/tools/runtime_proofs/C07RepairTurretRotationSlerpProof.gd` + `.tscn`.
- Targeted RED: Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2214', missing `source_repair_turret_rotation_slerp_state` in the state test + proof parse error `Static function "source_repair_turret_rotation_slerp_state()" not found in base "SourceRepairTurretBuildState"`); log `hidden_files/n2214-red.log` (10.564s).
- Register --verify 34/34 (28 exact + 5 inputs + 1 output), exit 0; all exprs verified verbatim against the 5 slice sources (RepairTurret / Mathf / BuildingComp / Angles / Time).
- javalang 0.13.0 OK at run start (no reinstall needed). Port 7777 free, no parallel run active.

## Scoping pinned in RED (do not re-decide in GREEN)

- One pure function: `source_repair_turret_rotation_slerp_state(frame, x, y, delta, time_scale)` returning `{"rotation": ...}` — ONLY rotation (angle is an intermediate like edelta in N2213, no consumer stamps it). 8 semantic proof keys (turns toward target / short way across 0/360 / scales with efficiency / scales with time_scale / unchanged without target / unchanged without power / turns even outside cone / reaches target when progress clamps).
- Gate `target != null && efficiency > 0` (RepairTurret.java:203); angle is `Angles.angle(x, y, target.x + offset.x, target.y + offset.y)` = atan2(dx, dy) in degrees normalized to [0, 360). The cone `Angles.angleDist(angle, rotation) < 30f` (:205) gates ONLY the heal (:206-207) — the slerp line (:209) sits after the cone block closes, still inside the gate block, so the turret turns toward a target even outside the 30° cone.
- slerpDelta multiplies progress by Time.delta and clamps to [0, 1] (Mathf.java:460-462); slerp takes the shortest circular path, result in [0, 360) (Mathf.java:455-458). Driver passes its per-tick `seconds` as delta (N2212/N2213 precedent), so progress = clampf(0.5 * efficiency * time_scale * delta, 0.0, 1.0).
- timeScale is the Building's own field (BuildingComp.java:98, `private transient float timeScale = 1f`, via `timeScale()` :599-600) — NOT the global Time.timeScale. No frame key stamps it yet; driver passes `float(frame.get("time_scale", 1.0))`, the Java default 1f.
- Driver calls the slerp AFTER the N2213 heal in the same tick (Java order: angle → cone/heal → slerp), because the heal reads the pre-slerp rotation for its cone check. This is the FIRST stamp of `frame["rotation"]` — before N2214 every repair turret's rotation sat at the 90.0 default.
- Strength lerp (RepairTurret.java:212) is NOT this slice — separate slice. Line numbers per grep (slerp :209, lerp :212), NOT the handoff N2213's :208/:211 (off by one).
- x, y params are REQUIRED (angle needs the turret position, N2213 precedent) — the task brief's shorthand `(frame, delta, time_scale)` omits them; the test pins the 5-param signature.
- SSOT before: 11447/1663/1586/2963. Expected after register: 11448/1664/1587/2965 (symbols +1, ledger +1, contracts +1, schema +2; NO shard change — N2213 precedent).

## GREEN plan

1. Add `source_repair_turret_rotation_slerp_state` to `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (after the N2213 heal advance) with the EXACT lines the test pins — signature, the `if not (target is Dictionary):` early return, `var rotation/efficiency/offset` reads, `if efficiency <= 0.0:`, the `fmod(rad_to_deg(atan2(target_x - x, target_y - y)) + 360.0, 360.0)` angle, `var progress: float = clampf(0.5 * efficiency * time_scale * delta, 0.0, 1.0)`, `var angle_delta: float = fmod(angle - rotation + 360.0 + 180.0, 360.0) - 180.0`, `var new_rotation: float = fmod(rotation + angle_delta * progress + 360.0, 360.0)`, and the two return dicts verbatim. The function comment MUST contain, verbatim, every Java line the test asserts (gate, angle, slerp, lerp, `public float strength, rotation = 90;`, slerp/slerpDelta/clamp lines, `private transient float timeScale = 1f, timeScaleDuration;`, `public float timeScale(){`, `public float delta(){`, `return Time.delta * timeScale;`, `public static float delta = 1f;`, atan2/angle lines). Also define `target_x`/`target_y` (target pos + offset) — the test does not pin their lines.
2. Driver tick line in `source_repair_turret_tick_buildings_state`, after the heal stamps: call `source_repair_turret_rotation_slerp_state(frame, sprite.position.x, sprite.position.y, seconds, float(frame.get("time_scale", 1.0)))` — the test pins this exact call line. Stamp the returned `rotation` live (`frame["rotation"]`).
3. Run register (NOT --verify) to add N2214 to SSOT, targeted GREEN 4/4, family + wiring, Godot proof (11 keys: 8 semantic + matches + 2 harness), full gate from the main thread only, then the classic 5-commit pattern + push. SSOT before: 11447/1663/1586/2963.
4. Check port 7777 free before any proof run; never run proof scenes in parallel with another run. Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2214

RepairTurret strength lerp, ImpactReactor impactPower event, Accelerator battery side. (Do NOT start the C08 inventory unless the user asks.)

## GREEN (this run)

- Pure `source_repair_turret_rotation_slerp_state(frame, x, y, delta, time_scale)` added to `SourceRepairTurretBuildState.gd` (after the N2213 heal advance) with the EXACT lines the test pins, plus 1 driver tick line after the heal stamps (`source_repair_turret_rotation_slerp_state(frame, sprite.position.x, sprite.position.y, seconds, float(frame.get("time_scale", 1.0)))`) — stamps `rotation` live, the FIRST stamp of `frame["rotation"]`.
- Targeted **4/4 OK in 15.563s** (log `hidden_files/n2214-green.log`). Proof JSON 11 keys, all true, `matches:true`.
- Family RepairTurret **24/24 OK in 81.920s** (N2174 + N2188 + N2209 + N2212 + N2213 + N2214; log `n2214-family.log`). Wiring-standard set **32/32 OK in 121.330s** (same 9 modules as N2209–N2213; log `n2214-wiring.log`). **GREEN total 60/60.**
- Register run (not --verify): SSOT 11447/1663/1586/2963 → **11448/1664/1587/2965** (symbols +1, ledger +1, contracts +1, schema +2 — exactly as scoped). Audit report unchanged (1335). Register --verify **34/34**, exit 0. `git diff --check` clean. No shard change.
- Port 7777 free before every proof run; no parallel run active. javalang 0.13.0 OK at run start (no reinstall needed).
- Design spec updated: Done 1663 → 1664 + N2214 row. Report written: `docs/superpowers/reports/2026-11-16-c07-repair-turret-rotation-slerp.md`. GOAL.md §5 NOT touched (main thread adds the Windows debt line after the gate).

## Remaining (main thread)

1. Full gate DONE (main thread, PID 14527, ~18:02): Ran 5949 in 992.898s, failures=164, skipped=5, 0 errors — all 164 verified Godot-absent asserts (footer present, finished ~18:19 +07). VM restart #25 ~18:19 wiped javalang after the footer landed; reinstalled 0.13.0, imports OK.
2. The classic 5-commit pattern + push in progress (slice commit, docs commit, GOAL.md §5 Windows debt line, hash-naming commit, handoff-status commit). `git fetch origin` done — origin/main da7eb743, fast-forwarded, no rebase needed.

## GREEN verification + gate (main thread, ~18:02 +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 16.376s; family log Ran 24 OK (81.920s, RepairTurret N2174+N2188+N2209+N2212+N2213+N2214); wiring log Ran 32 OK (121.330s). GREEN total 60/60. Proof JSON 11 keys (8 semantic + matches + 2 harness), matches:true, 0 false. Register --verify 34/34 exprs present, exit 0.
- Pure function `source_repair_turret_rotation_slerp_state(frame, x, y, delta, time_scale)` at :214 + 1 driver tick line (:374) after the N2213 heal block; stamps frame["rotation"] live (RepairTurret.java:209 — the N2213 handoff's ":208" was wrong, corrected in the N2214 scope).
- SSOT 11447/1663/1586/2963 → **11448/1664/1587/2965** (symbols +1, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (verify at completion).
- Gate saga: worker's claimed gate (PID 14149) was DEAD on arrival — log 144 bytes, no footer; a second worker-session process (PID 14340) also died with the worker session. Main thread relaunched twice: first relaunch (PID 14369) was killed after the overlap with dying 14340 risked a mixed log; clean relaunch (main thread, PID 14527, SID 14527, ~18:02): godot NOT on PATH, javalang OK, single gate confirmed by ps, log fresh and growing (1217 bytes at first check). Expected: Ran ~5949, failures ~164, skipped 5, 0 errors.
- origin/main MOVED during N2214: f3267e50 → **da7eb743** ("Merge PR #11: wave23-fixed Godot validation evidence N2362 GREEN and two pending RED proofs", docs-only, commit e55a21b1). Fast-forwarded before pushing N2214 (no rebase needed, docs-only).
- Gate (main PID 14527, SID 14527, ~18:02) **Ran 5949 in 992.898s, failures=164, skipped=5, 0 errors** — all 164 verified `AssertionError: unexpectedly None` (Godot-absent); footer present in `tools/mindustry_godot_transpiler/full-suite-n2214-gate.log`, finished ~18:19 +07. VM restart #25 ~18:19 wiped javalang after the footer landed; reinstalled 0.13.0, imports OK; nothing lost.
