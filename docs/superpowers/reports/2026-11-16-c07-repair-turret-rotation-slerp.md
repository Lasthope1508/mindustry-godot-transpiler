# Report — N2214 RepairTurret rotation slerp (C07)

Date: 2026-11-16. Batch: N2214 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~18:19 +07 — targeted 4/4, family 24/24, wiring 32/32; full gate Ran 5949, failures=164, skipped=5, 0 errors, all 164 verified Godot-absent). Ready to push (origin/main da7eb743 — fast-forwarded, no rebase needed).**

## Scope

RepairTurret rotation slerp — the deferred item the N2213 report names ("rotation slerp"). One Java line, `RepairPointBuild.updateTile()` RepairTurret.java:209:

```java
rotation = Mathf.slerpDelta(rotation, angle, 0.5f * efficiency * timeScale);
```

inside the `if(target != null && efficiency > 0){` gate (:203) but OUTSIDE the aim-cone `if(Angles.angleDist(angle, rotation) < 30f){` (:205): the cone gates only the heal (:206-207), so the turret still turns toward a target outside the cone. Strength lerp (RepairTurret.java:212) is NOT this slice — separate slice. Line numbers per grep (slerp :209, lerp :212), not the handoff N2213's :208/:211 (off by one).

## What changed

- Pure `source_repair_turret_rotation_slerp_state(frame, x, y, delta, time_scale)` in `godot-mindustry/src/game/SourceRepairTurretBuildState.gd` (after the N2213 heal advance), returning `{"rotation": float}` — ONLY rotation (angle is an intermediate like edelta in N2213, no consumer stamps it). Gate: no target dict or efficiency <= 0 → rotation unchanged. Otherwise angle = `Angles.angle(x, y, target.x + offset.x, target.y + offset.y)` (atan2(dx, dy), [0, 360)), progress = `clampf(0.5 * efficiency * time_scale * delta, 0.0, 1.0)` (slerpDelta multiplies by Time.delta and clamps, Mathf.java:460-462), shortest circular path via `fmod(angle - rotation + 540.0, 360.0) - 180.0`, result in [0, 360).
- One driver tick line in `source_repair_turret_tick_buildings_state`, after the N2213 heal stamps (Java order: angle → cone/heal → slerp, because the heal reads the pre-slerp rotation for its cone check): `source_repair_turret_rotation_slerp_state(frame, sprite.position.x, sprite.position.y, seconds, float(frame.get("time_scale", 1.0)))`, stamps `frame["rotation"]` live. This is the FIRST stamp of `frame["rotation"]` — before N2214 every repair turret sat at the 90.0 default.
- timeScale is the Building's own field (BuildingComp.java:98, `private transient float timeScale = 1f`, via `timeScale()` :599-600), NOT the global Time.timeScale. No frame key stamps it yet; the driver passes `frame.get("time_scale", 1.0)`, the Java default.
- x, y params are required (angle needs the turret position, N2213 precedent) — the task brief's shorthand `(frame, delta, time_scale)` omits them; the test pins the 5-param signature.

## Verification

- RED: targeted Ran 4, failures=2, errors=2 — classic (KeyError 'N2214', missing `source_repair_turret_rotation_slerp_state` in the state test + proof parse error); log `hidden_files/n2214-red.log` (10.564s). Register --verify 34/34 exprs present (28 exact + 5 inputs + 1 output), exit 0.
- Register run (not --verify): SSOT **11447/1663/1586/2963 → 11448/1664/1587/2965** (+1/+1/+1/+2, exactly as scoped); audit stays 1335. No shard change (no shard selection matches RepairTurret.java, N2213 precedent). `git diff --check` clean.
- Targeted GREEN **Ran 4 OK in 15.563s** (log `hidden_files/n2214-green.log`), including the Godot proof test. Proof `C07RepairTurretRotationSlerpProof.json` (11 keys: 8 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM.
- Family RepairTurret **24/24 OK in 81.920s** (N2174 power + N2188 shouldConsume + N2209 coolant + N2212 acquire + N2213 heal + N2214 slerp; log `n2214-family.log`), wiring-standard set **32/32 OK in 121.330s** (same 9 modules as N2209–N2213; log `n2214-wiring.log`). **GREEN total 60/60.**
- Full gate (PID 14527, main thread, ~18:02) **Ran 5949 in 992.898s, failures=164, skipped=5, 0 errors** — all 164 verified `AssertionError: unexpectedly None` (Godot-absent); log `tools/mindustry_godot_transpiler/full-suite-n2214-gate.log` (footer present, finished ~18:19 +07). VM restart #25 ~18:19 wiped javalang after the gate footer landed — reinstalled 0.13.0, imports OK; nothing lost.
- Port 7777 free before every proof run; no parallel run active. javalang 0.13.0 OK at run start (no reinstall needed).

## Proof keys (8 semantic)

`rotation_turns_toward_target` (80 → 80.0833 toward east angle 90), `rotation_turns_short_way_across_360` (350 → 350.1667 toward angle 10, not -340), `rotation_scales_with_efficiency` (90 → 89.625 at efficiency 0.5), `rotation_scales_with_time_scale` (90 → 88.5 at time_scale 2.0), `rotation_unchanged_without_target` (123.0 stays), `rotation_unchanged_without_power` (90.0 stays at efficiency 0), `rotation_turns_even_outside_cone` (90 → 89.25 toward north angle 0, angleDist 90 > 30 — the key that distinguishes this slice from N2213), `rotation_reaches_target_when_progress_clamps` (350 → exactly 10.0 at delta 60.0, progress clamped to 1).

## Documented limits

- Strength lerp (RepairTurret.java:212) deferred — separate slice.
- `time_scale` has no live source in the port (always 1.0 until a timeScale slice stamps `frame["time_scale"]`); a turret under a time-scale effect rotates at unscaled speed. Gap recorded, not guessed.
- Windows Godot proof debt (GOAL.md §5 line added with this push): N2214 proof runs headless on Linux here, waits for a Windows Godot run — same as N2175–N2213.

## Files

Slice: `godot-mindustry/src/game/SourceRepairTurretBuildState.gd`, 4 SSOT JSONs, `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_rotation_slerp.py`, `tools/mindustry_godot_transpiler/register_c07_repair_turret_rotation_slerp.py`, `godot-mindustry/tools/runtime_proofs/C07RepairTurretRotationSlerpProof.gd` + `.tscn`. Docs: this report, `docs/superpowers/handoffs/2026-11-16-c07-repair-turret-rotation-slerp-handoff.md`, design spec (Done 1663 → 1664 + N2214 row). Never stage *.gd.uid or proof .json.

## Remaining (main thread)

1. Full gate DONE (main thread, PID 14527): Ran 5949, failures=164, skipped=5, 0 errors.
2. The classic 5-commit pattern + push in progress: slice commit, docs commit (spec Done 1664 + N2214 row, handoff, report), GOAL.md §5 Windows debt line for N2214, hash-naming commit, handoff-status commit. `git fetch origin` done — origin/main da7eb743, fast-forwarded, no rebase needed (validation agent merges regularly).

## Next

After N2214: RepairTurret strength lerp, ImpactReactor impactPower event, Accelerator battery side. (Do NOT start the C08 inventory unless the user asks.)
