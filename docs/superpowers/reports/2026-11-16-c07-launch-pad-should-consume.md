# Report — N2205: LaunchPad shouldConsume gate (LaunchPad.java:92-95, C07)

Date: 2026-11-16. Batch: N2205 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~08:49 +07 — targeted 4/4, family 8/8, wiring 32/32; full gate Ran 5913, failures=155, skipped=5, 0 errors, all 155 verified Godot-absent). Ready to push (origin/main still b72e66e0).**

## What changed

N2204 is DONE + PUSHED (main b72e66e0); this tick finishes the LaunchPad shouldConsume gate — the next deferred item after N2204 per the N2204 handoff ("After N2204: MassDriver / LaunchPad rows, RepairTurret coolant, Units.nearby live query"). Java: LaunchPadBuild overrides shouldConsume with `return launchCounter < launchTime;` (LaunchPad.java:92-95) — once the launch counter is full, Java stops consuming — yet the port's driver hardcoded `should_consume = enabled` (SourceLaunchPadBuildState.gd:109, N2172), so a pad whose counter is full kept consuming power as if the gate were open. updateConsumption forces efficiency to zero when the gate is false (BuildingComp.java:1960, `boolean update = shouldConsume() && productionValid();` + 1992, `if(!update){`). No gameplay change; nothing staged/committed/pushed yet.

What N2205 adds (9 files, not staged):

- **Pure function + 1 driver line** `source_launch_pad_should_consume_state(frame, launch_time)` in the EXISTING `SourceLaunchPadBuildState.gd:82`, driver line at `:183` in `source_launch_pad_tick_buildings_state`. Gate `launch_counter < launch_time`; per-def launchTime from `SOURCE_LAUNCH_PAD_LAUNCH_TIMES` (launch-pad 1200.0, advanced-launch-pad 1800.0, class default 1.0) because the catalog carries no launchTime property. Absent `launch_counter` → 0.0, preserving N2172 behavior (`should_consume = enabled`) until the future updateTile-advance slice stamps `launch_counter` live — the N2201 plans_count / N2202 break_timer absent-default precedent.
- **Test module + register script** `test_c07_launch_pad_should_consume.py` + `register_c07_launch_pad_should_consume.py` (N2201 pattern). SSOT baseline re-verified from disk: 11427/1654/1575/2941, audit 1335. After GREEN: **11428/1655/1576/2943**, audit 1335. Defense shards untouched (LaunchPad is `world/blocks/campaign/`, not defense; no campaign shard files exist yet — the register rebuilds extension shards from `source_ssot_modules.json`, per the N2172 precedent).
- **Proof scene** `C07LaunchPadShouldConsumeProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6), N2201 proof shape. 6 semantic keys: gate passes below launchTime / gate blocks at launchTime / gate blocks when fully charged / gate blocks when disabled / gate passes below launchTime live / gate-absent preserves power fold.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-launch-pad-should-consume-handoff.md` — design, frame key (`launch_counter`), proof keys, RED decisions, Java evidence, gate saga (attempts 1–3).

## RED

Tests written first per the slice process (4 targeted: counter below launchTime → consume; counter at/above launchTime → no consume; absent launch_counter → `should_consume = enabled` (N2172 behavior); disabled → no consume). No RED log survives on disk (no `n2205-red.log`; the worker left no green/neighbours/wiring logs either — the main thread re-verified GREEN instead, see below), so no RED Ran/failure count is claimed here. The register script carries 28 EXACT_EXPRS entries, verified verbatim against upstream at RED per the handoff; DEFERRED carried from N2204 plus the N2205 Windows-proof debt entry. `git diff --check` clean.

## GREEN (main-thread verified ~08:02–08:06 +07)

Pure function `source_launch_pad_should_consume_state(frame, launch_time)` in the EXISTING `SourceLaunchPadBuildState.gd:82` (all exact exprs in its comment; per-def launchTime resolved from `SOURCE_LAUNCH_PAD_LAUNCH_TIMES` by block id, defaulting to the class default 1.0). One driver line + comment at `:183` in `source_launch_pad_tick_buildings_state`, inside the power-consumer branch, stamping `should_consume` through the updateConsumption setup (the N2201 gate pattern). Frame key: `launch_counter` (float, absent defaults to 0.0 — "no observation yet", not "fully launched"). Register: SSOT **11428/1655/1576/2943** đúng kỳ vọng (+1/+1/+1/+2 vs N2204), audit 1335. Targeted GREEN **Ran 4 OK in 15.278s** (main-thread re-run — the 07:45 worker left NO `n2205-green.log`); family N2172 + N2205 both OK (**8/8**); wiring **32/32 OK** (9 modules). **GREEN tổng 44/44**. Proof `C07LaunchPadShouldConsumeProof.json` (9 keys: 6 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM (JSON written 08:03 +07). `git diff --check` sạch. Note: the 08:00 worker mistook the main-thread verification run for "the N2205 worker" (its PID 13345 unittest / 13347 Godot BatteryPlacementProof were the main thread's own wiring loop) — no parallel worker was running, no port collision occurred.

## Gate (VERIFIED 2026-11-16 ~08:49 +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (PID 3298, SID 3298, ~08:33; parent subshell PID 3295 stayed alive). Attempt 1 (main thread, PID 13554, ~08:06) DIED on VM restart #20 (~08:20); attempt 2 (worker-launched, PID 3114, ~08:31) DIED with the worker session (10th worker-session gate death on record). Attempt 3 finished: **Ran 5913 tests in 963.223s — FAILED (failures=155, skipped=5), 0 errors.** All 155 failures verified Godot-absent: 155 × `AssertionError: unexpectedly None` (`assertIsNotNone(godot)` — no Godot on PATH in the gate shell, by design), 0 `^ERROR` lines. +4 tests / +1 failure vs N2204's 5909/154: the new N2205 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN). Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2205-gate.log` (untracked, never staged); attempt-1 log preserved as `full-suite-n2205-gate-attempt1.log`.

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1654 → 1655 + N2205 row) → GOAL.md §5 (Windows proof stays debt). Slice `68b32928` (9 files) → docs `b56b13b8` + GOAL `9df5a0bf` → this hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main re-checked before push: still b72e66e0).

## Deferred (NOT this slice)

- LaunchPad updateTile advance (LaunchPad.java:143-161: launchCounter advance + consume() + LaunchPayload entity spawn + items.clear + sound/Fx) — own slice(s) after the gate; the entity spawn is a new subsystem and needs an items.total frame input.
- LaunchPad sense(progress) (LaunchPad.java:98-101, `Mathf.clamp(launchCounter / launchTime)`) — needs the sense-dispatch hook; own slice.
- LaunchPad acceptItem (LaunchPad.java:138-140) — needs items.total + first item + acceptMultipleItems; own slice.
- LaunchPad draw / read-write / config-display (LaunchPad.java:104-140 / 211-222 / 164-...) — presentation / serialization / campaign sector config; each its own slice.
- LaunchPad liquid consumer row (advanced-launch-pad consumeLiquid oil 9f/60f, Blocks.java:6808) — second consumer on one def; own slice.
- MassDriver rows (sense(progress), acceptItem, updateTile split: reload drain → state transitions → fire) — MassDriver has NO shouldConsume override (BuildingComp default `return enabled;` already applies), so there is no MassDriver shouldConsume slice.
- RepairTurret coolant, Units.nearby live query — still deferred after the MassDriver/LaunchPad rows.
- Windows Godot proof — debt in GOAL.md §5, same as N2175–N2204.
