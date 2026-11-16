# Report — N2206: LaunchPad sense(progress) (LaunchPad.java:98-101, C07)

Date: 2026-11-16. Batch: N2206 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~10:0x +07 — targeted 4/4, family 12/12, wiring 32/32; full gate Ran 5917, failures=156, skipped=5, 0 errors, all 156 verified Godot-absent). Ready to push (origin/main moved to d14186e6 — validation wave15 merge; slice rebased cleanly onto it).**

## What changed

N2205 is DONE + PUSHED (main 7fac96a2); this tick finishes the LaunchPad sense(progress) override — the next deferred item after N2205 per the N2205 handoff ("After N2205: LaunchPad sense(progress), then LaunchPad updateTile advance..."). Java: LaunchPadBuild overrides sense with `if(sensor == LAccess.progress) return Mathf.clamp(launchCounter / launchTime);` (LaunchPad.java:98-101) — a logic processor reading `progress` on a launch pad gets the clamped launch fraction — yet the port had no live per-family sense override: the BuildingComp sense switch has no `progress` case and falls through to `default -> Float.NaN; //gets converted to null in logic` (BuildingComp.java:2123), so the pad sensed NaN/null. No gameplay change; slice committed + rebased in this tick, docs + push below.

What N2206 adds (9 files):

- **Pure function, NO driver line** `source_launch_pad_sense_state(frame, sensor, launch_time)` in the EXISTING `SourceLaunchPadBuildState.gd:142` (N2203 damage() precedent — sense is a logic read, not a tick write). `sensor == "progress"` returns `{"handled": true, "sense_value": clampf(counter / launch_time, 0.0, 1.0), "sense_value_is_nan": false}`; any other sensor returns `{"handled": false, "sense_value": null, "sense_value_is_nan": true}` (fall through to super.sense, the generic `laccess_state` wire). Absent `launch_counter` → 0.0 (Option A, Java-init-faithful: `public float launchCounter;` defaults to 0.0f — pinned at RED; unlike N2205 there is no live regression because no consumer reads this value yet). Per-def launchTime from `SOURCE_LAUNCH_PAD_LAUNCH_TIMES` (launch-pad 1200.0, advanced-launch-pad 1800.0, class default 1.0).
- **Test module + register script** `test_c07_launch_pad_sense_progress.py` + `register_c07_launch_pad_sense_progress.py` (N2205 pattern; DEFERRED carried by import from the N2205 register). SSOT baseline re-verified from disk: 11428/1655/1576/2943, audit 1335. After GREEN: **11429/1656/1577/2945**, audit 1335. No shard change (LaunchPad is `world/blocks/campaign/`, not defense — same as N2205). One result symbol registered: `source_launch_pad_sense_state_result.sense_value`.
- **Proof scene** `C07LaunchPadSenseProgressProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2203 pure-function proof shape. 6 semantic keys: sense_progress_below_launch_time / sense_progress_at_launch_time / sense_progress_above_launch_time / sense_progress_absent_counter_zero / sense_fall_through_non_progress / sense_progress_advanced_pad.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-launch-pad-sense-progress-handoff.md` — design, RED decisions (all four pinned), Java evidence, scope (why no dispatch hook in this slice), gate result.

## RED

Tests written first per the slice process (4 targeted: progress fraction below launchTime; counter at/above launchTime → 1.0; non-progress sensor → fall-through; absent launch_counter → 0.0). Targeted run: **Ran 4, failures=2, errors=2 — classic RED**: registration KeyError 'N2206' (register runs at GREEN); evidence test KeyError 'N2206'; state test missing `source_launch_pad_sense_state`; proof test fails with godot on PATH (scene `C07LaunchPadSenseProgressProof.tscn` does not exist yet). Without PATH the proof test fails at `which('godot')` instead — same RED, wrong reason; GREEN proof run must export PATH first (N2177 lesson). The register script carries 22 EXACT_EXPRS entries, verified verbatim against upstream at RED per the handoff. `git diff --check` clean.

## GREEN (2026-11-16 ~09:4x +07)

Pure function `source_launch_pad_sense_state(frame, sensor, launch_time)` in the EXISTING `SourceLaunchPadBuildState.gd:142` (all exact exprs in its comment; one fix after the first targeted run: the `default -> Float.NaN; //gets converted to null in logic` comment expr was split across two lines and failed the state test's assertIn — rejoined onto one line, sentence restored). No driver line (N2203 precedent). Register: SSOT **11429/1656/1577/2945** đúng kỳ vọng (+1/+1/+1/+2 vs N2205), audit 1335. Targeted GREEN **Ran 4 OK in 13.446s** (log `n2206-green.log`); family N2172 + N2205 + N2206 **12/12 OK in 43.594s** (log `n2206-family.log`); wiring **32/32 OK in 121.204s** (9 modules, log `n2206-wiring.log`). **GREEN tổng 48/48**. Proof `C07LaunchPadSenseProgressProof.json` (9 keys: 6 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM. `git diff --check` sạch. Environment: VM restart #21 ~09:14 (uptime 17 min at 09:31); javalang 0.13.0 importable (survived); port 7777 free.

## Gate (VERIFIED 2026-11-16 ~10:0x +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 4429, ~09:41; godot NOT on PATH, javalang OK). Finished: **Ran 5917 tests in 1020.885s — FAILED (failures=156, skipped=5), 0 errors, 0 `ERROR:` lines.** All 156 failures verified Godot-absent: 156 × `AssertionError: unexpectedly None` (`assertIsNotNone(godot)` — no Godot on PATH in the gate shell, by design). +4 tests / +1 failure vs N2205's 5913/155: the new N2206 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN). Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2206-gate.log` (untracked, never staged).

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1655 → 1656 + N2206 row) → GOAL.md §5 (Windows proof stays debt). Slice `8db29088` (9 files, rebased cleanly onto origin/main `d14186e6` — validation wave15 merge `02fc3757` + `d14186e6`, docs only) → docs `13fe94f3` + GOAL `fca286e8` → this hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main re-checked before push). Post-rebase sanity: targeted **Ran 4 OK in 16.730s** (port 7777 free, javalang 0.13.0).

## Deferred (NOT this slice)

- LaunchPad updateTile advance (LaunchPad.java:143-161: launchCounter advance + consume() + LaunchPayload entity spawn + items.clear + sound/Fx) — own slice(s) after the gate; the entity spawn is a new subsystem and needs an items.total frame input. This is also the slice that will start stamping `launch_counter` live, which is what makes the N2206 absent-default decision observable.
- LaunchPad acceptItem (LaunchPad.java:138-140) — needs items.total + first item + acceptMultipleItems; own slice.
- LaunchPad liquid consumer row (advanced-launch-pad consumeLiquid oil 9f/60f, Blocks.java:6808) — second consumer on one def; own slice.
- LaunchPad draw / read-write / config-display (LaunchPad.java:104-140 / 211-222 / 164-...) — presentation / serialization / campaign sector config; each its own slice.
- MassDriver sense(progress) (MassDriver.java:224-228, `Mathf.clamp(1f - reloadCounter)`) — same per-family sense shape as N2206, but needs a `reload_counter` frame key the port does not track yet; own slice after N2206 establishes the shape. MassDriver acceptItem / updateTile split / fire / handlePayload / link / config / read-write / draw — each its own slice after the LaunchPad rows.
- ShockwaveTower sense(progress) (ShockwaveTower.java:110, `reloadCounter / reload` — UNCLAMPED, unlike LaunchPad/MendProjector) — own slice.
- RepairTurret coolant, Units.nearby live query — still deferred after the MassDriver/LaunchPad rows.
- Windows Godot proof — debt in GOAL.md §5, same as N2175–N2205.
