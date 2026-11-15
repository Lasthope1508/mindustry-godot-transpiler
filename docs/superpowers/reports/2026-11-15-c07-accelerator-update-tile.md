# Report — N2191: Accelerator updateTile advance (C07)

Date: 2026-11-15. Batch: N2190 + N2191 + N2192 (integration branch
`integration/batch-n2190-n2191-n2192`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2191 (parallel wave 1, coordinator-verified; worker handoff
arrived late 10:30 +07 and matched every coordinator-verified number).
Slice commit `468a2bb5` on `slice/N2191-accelerator-update-tile`; SSOT commit
`ff2eb6d1`; coordinator fix `20e45d33` (60x Time.delta — see GREEN).
Integration cherry-picks: slice `fafe334f`, fix `ed17c642`.

## What changed

N2183 gave the accelerator its live power.status read (the pure power row,
folded by the shared machinery into the min efficiency) — but the port still
never advanced the AcceleratorBuild.updateTile state (Accelerator.java:127-146):
heat, statusLerp, time, launchHeat and progress sat at their defaults, so the
accelerator never reached progress 1f and isCoreBuilt (Accelerator.java:153-154,
`return progress >= 1f;`) never passed. N2191 is the updateTile advance: a pure
advance over the frame (heat/statusLerp/launchHeat lerpDelta toward their
targets, time advances by Time.delta × efficiency when idle and slerps toward
0 when launching, progress advances by Time.delta × efficiency / buildDuration
and clamps at 1f), wired into the N2183 driver after the consumption fold —
Building.update() calls updateConsumption() then updateTile()
(BuildingComp.java:2274-2278), and the gate `if(enabled || !block.noUpdateDisabled){`
passes even when disabled because noUpdateDisabled defaults false (Block.java:170)
and Accelerator never sets it. super.updateTile() is empty
(BuildingComp.java:2010-2012), so the advance is the whole tick.

buildDuration is the class field 120f (Accelerator.java:52), not overridden by
the interplanetary-accelerator def. `launching` defaults false (Java boolean
default); only beginLaunch sets it true (Accelerator.java:334-337) — the launch
sequence waits for its own slice, but the flag must exist as frame state so the
lerps pick the right target. The lerpDelta/slerpDelta formulas come from Arc
Mathf.java: lerpDelta is lerp(from, to, clamp(progress × Time.delta))
(Mathf.java:430-432) and slerpDelta is slerp(from, to, clamp(progress ×
Time.delta)) (Mathf.java:460-462), where slerp is the angle lerp in degrees
with wrap (Mathf.java:455-458). The port has no slerp helper, so the advance
carries a local `source_mathf_slerp_delta` transliterating Mathf.slerpDelta;
GDScript fmod matches Java % (sign of the dividend), so the transliteration
is exact.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_accelerator_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_accelerator_update_tile.py`
written by worker-N2191. Register script: EXACT_EXPRS = the 41 verified exprs
(all 41 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 244 entries (copy forward from N2185, minus the resolved entries,
plus new deferrals including the disabled-early-return deferral).

RED run: registration + exact-evidence fail with `KeyError: 'N2191'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance in `godot-mindustry/src/game/SourceAcceleratorBuildState.gd`:
  `source_accelerator_update_tile_advance_state` returns the 5 advanced values
  (heat, statusLerp, time, launchHeat, progress) from the frame; the driver
  runs it after the consumption fold and writes the new values back to the
  frame. Header quotes all 41 exact exprs, each on ONE comment line. All
  documented limits recorded in the pure function's comment (including limit 7:
  the disabled-efficiency staleness — the advance runs even when disabled, per
  the Java gate, but reads a stale efficiency because the driver never zeroes
  efficiency when disabled; the driver-wide disabled early return is deferred).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07AcceleratorUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11385/1637/1558/2907**
  (+5/+1/+1/+2 from baseline 11380/1636/1557/2905 — the +5 symbols are the 5
  return values); audit 1335 unchanged; ledger N2191 status done.
  **No shard changed** (Accelerator.java is not under a shard selection path).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 41/41,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- **Coordinator fix `20e45d33` (the 60x Time.delta lesson):** the worker's driver
  passed raw `seconds` as Time.delta (following the conduit precedent, which is
  itself the bug — fixed as N2196). `_process(delta)` gives real seconds
  (~1/60 per tick) but Java Time.delta = seconds × 60 (arc Time.java:26), so
  the advance ran 60x too slow vs Java. Fixed to the canonical
  `game_source_delta(game, seconds)` helper, the pure parameter renamed to
  `source_delta`, and the proof expectation fixed with it (the live tick now
  expects Time.delta ticks). Targeted re-run after the fix: still 3/4 +
  Godot-absent. The same bug was found in N2186/N2187 and fixed the same way;
  N2189/N2190/N2192/N2193/N2195 were correct from the start.

## Neighbours (batch — see the batch-2 report section in each slice report)

Family run 10:4x +07 (41 modules, 164 tests) + new targeted 9/12 + wiring-standard
set (9 modules / 32 tests): **155/208 PASS**, 53 failures ALL verified
`AssertionError: unexpectedly None` (41 family + 3 new targeted + 9 wiring),
0 other failures, 0 `ERROR:` lines — no regression. Numbers recorded in
`~/workspace/mindustry-parallel/STATUS.md` (coordinator-verified; no log file
was saved for the batch-2 neighbours run).

## Gate (batch)

Full gate launched from the coordinator main thread 10:43 +07 via
`setsid nohup python3 -m unittest discover -s tests`, PID 18806, SID 18806.
Finished 11:00 +07: **Ran 5849 tests in 1041.246s, FAILED (failures=139,
skipped=5)** — 0 errors, 0 `ERROR:` lines. All 139 verified Godot-absent
(139 × `AssertionError: unexpectedly None`), exactly as expected (136 inherited
+ 3 new: N2190/N2191/N2192 proof tests). Log
`tools/mindustry_godot_transpiler/full-suite-batch2-gate.log` (untracked).

## Commits

- Slice: `468a2bb5` — C07: N2191 Accelerator updateTile advance, 5 files (+1082/−4),
  on `slice/N2191-accelerator-update-tile`.
- SSOT: `ff2eb6d1` — C07: N2191 SSOT registration (11385/1637/1558/2907), 4 files (+512).
- Coordinator fix: `20e45d33` — C07: N2191 coordinator fix (60x Time.delta → game_source_delta; rename pure param to source_delta).
- Integration: slice cherry-pick `fafe334f` + fix cherry-pick `ed17c642` on
  `integration/batch-n2190-n2191-n2192`; batch SSOT `68fc759c` (combined
  11390/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2190/N2191/N2192.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The launch sequence (beginLaunch / endLaunch / buildConfiguration), the
  canLaunch battery gate, the progress()/isCoreBuilt() accessors, and progress
  serialization — each its own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957): Java
  zeroes efficiency/optionalEfficiency/potentialEfficiency when disabled, but
  every driver family skips the consumption fold when disabled, so the frame
  efficiency goes stale; the N2191 advance runs while disabled (correct gate)
  but reads the stale value. Documented as limit 7 + a DEFERRED entry; the
  driver-wide fix is its own slice.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07AcceleratorUpdateTileProof`, commit carrying the scene `468a2bb5` (proof
  expectation fixed in `20e45d33`), 9 keys
  (`heat_lerps_toward_efficiency`, `status_lerp_tracks_power_status`,
  `launch_heat_lerps_by_launching`, `time_advances_and_slerps`,
  `progress_advances_and_clamps`, `live_tick_advances_and_folds_power`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_accelerator_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2192 (ImpactReactor updateTile, same batch), then batch 3 {N2193,
  N2194, N2195} + N2196, then frame-state infra — see the N2188 blocker in
  STATUS.md and the batch-2 handoff Next sections.
