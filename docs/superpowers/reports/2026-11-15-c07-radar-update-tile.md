# Report — N2190: Radar updateTile advance (C07)

Date: 2026-11-15. Batch: N2190 + N2191 + N2192 (integration branch
`integration/batch-n2190-n2191-n2192`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2190 (parallel wave 1, coordinator-verified). Slice commit `950087a7`
on `slice/N2190-radar-update-tile`; SSOT commit `27d45a21`; no coordinator fix
needed (Time.delta correct from the start — seconds × TICK_RATE). Integration
cherry-pick: slice `6baeb7bc`.

## What changed

N2173 gave the radar its live power.status read (a pure power row over the
stamped frame value, folded by the shared machinery into the min efficiency)
— but the radar's updateTile advance (Radar.java:60-72) still waited:
smoothEfficiency never lerped toward the folded efficiency, progress never
advanced by edelta() / discoveryTime, totalProgress never accumulated, and
lastRadius never tracked the fog radius — so a radar never discovered,
however long it ran. N2190 adds the pure updateTile step
`SourceRadarBuildState.source_radar_update_tile_state`, wired into the N2173
driver every tick, in Java order: the smooth-efficiency lerp FIRST
(Radar.java:61, `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`),
then the fog-radius change check against the NEW smooth efficiency and the
CURRENT progress (Radar.java:63-66), then the progress advance + clamp
(Radar.java:68-69, `progress += edelta() / discoveryTime;` /
`progress = Mathf.clamp(progress);`), then the total-progress advance
(Radar.java:71, `totalProgress += efficiency * edelta();`).

One def: radar (consumePower 0.6f, Blocks.java:1994; fogRadius 34,
Blocks.java:1991; discoveryTime 60f * 10f, Radar.java:18). The catalog
carries no fogRadius property, so the driver passes the def constant 34.0.
timeScale uses the default 1f (BuildingComp.java:98, documented).
The driver passes seconds × TICK_RATE as the source delta (the N2093 pump
precedent; arc Time.java:26), so edelta is in Time.delta ticks — correct
from the start, unlike N2186/N2187/N2191.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_radar_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_radar_update_tile.py`
written by worker-N2190. Register script: EXACT_EXPRS = the 24 verified exprs
(all 24 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 242 entries (copy forward from N2185, minus the resolved entries,
plus new deferrals).

RED run: registration + exact-evidence fail with `KeyError: 'N2190'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance in `godot-mindustry/src/game/SourceRadarBuildState.gd`:
  `source_radar_update_tile_state` returns the advance dict (advance +
  force_update_needed flag) from the frame; the driver runs it after the
  consumption fold and writes the new smoothEfficiency/progress/totalProgress/
  lastRadius back to the frame. Header quotes all 24 exact exprs, each on ONE
  comment line. All documented limits recorded in the pure function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07RadarUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11382/1637/1558/2907**
  (+2/+1/+1/+2 from baseline 11380/1636/1557/2905); audit 1335 unchanged; ledger
  N2190 status done. **Defense shard changed** (Radar.java lives under
  `/world/blocks/defense/`, the N2173 precedent): defense_slices 154→155,
  defense_api_contracts 153→154.
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 24/24,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

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

- Slice: `950087a7` — C07: N2190 Radar updateTile advance, 5 files (+532/−3),
  on `slice/N2190-radar-update-tile`.
- SSOT: `27d45a21` — C07: N2190 SSOT registration (11382/1637/1558/2907), 6 files (+539).
- Integration: slice cherry-pick `6baeb7bc` on
  `integration/batch-n2190-n2191-n2192`; batch SSOT `68fc759c` (combined
  11390/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2190/N2191/N2192.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The `fogControl.forceUpdate(team, this)` call (Radar.java:64) — a side-effect
  into the fog system, which has no port-side control yet; the advance tracks
  only the condition (|fogRadius() − lastRadius| >= 0.5f) and the lastRadius
  write. The call itself waits for its own fog slice.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07RadarUpdateTileProof`, commit carrying the scene `950087a7`, 9 keys
  (`smooth_efficiency_lerps_to_efficiency`, `progress_advances_edelta_over_discovery`,
  `progress_clamps_at_one`, `total_progress_accumulates`, `last_radius_updates_on_fog_change`,
  `live_tick_advances_and_keeps_power_row`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_radar_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2191 (Accelerator updateTile) + N2192 (ImpactReactor updateTile, same
  batch), then batch 3 {N2193, N2194, N2195} + N2196, then frame-state infra
  (config/link, items, liquids, payload, targets) — see the N2188 blocker in
  STATUS.md and the batch-2 handoff Next sections.
