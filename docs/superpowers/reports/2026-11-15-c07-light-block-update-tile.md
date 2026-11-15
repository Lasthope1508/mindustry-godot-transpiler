# Report — N2189: LightBlock updateTile advance (C07)

Date: 2026-11-15. Batch: N2186 + N2187 + N2189 (integration branch
`integration/batch-n2186-n2187-n2189`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2189 (parallel wave 1, coordinator-verified). Slice commit `d3e8f4de`
on `slice/N2189-light-block-update-tile`; SSOT commit `ae307497`. No coordinator
fix needed — the worker was correct on Time.delta from the start.
Integration cherry-pick: slice `8803e1e7`.

## What changed

The first **updateTile advance** after the shouldConsume gates: LightBuild
advances `smoothTime = Mathf.lerpDelta(smoothTime, timeScale, 0.1f)`
(LightBlock.java:104-107) each tick, and the light radius clamps at
`min(smoothTime, 2f)`. Before this slice the N2185 power-status driver folded
efficiency but the frame carried no smoothTime, so the light's time-smoothing
never moved. Now the driver advances smoothTime from the live timeScale
(default 1f, BuildingComp.java:98) and the radius clamp follows it.

The advance composes the canonical `SourceMathState.source_lerp_delta`
(Arc lerpDelta: `lerp(from, to, clamp(progress * Time.delta))`,
Mathf.java:430-432) with Time.delta in ticks via `game_source_delta`
(seconds × 60) — correct from the start, unlike N2186/N2187/N2191.
The pure function is
`SourceLightBlockBuildState.source_light_block_smooth_time_state`.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_light_block_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_light_block_update_tile.py`
written by worker-N2189. Register script: EXACT_EXPRS = the 94 verified exprs
(82 from N2185 + 12 new, all present verbatim in upstream — script check,
0 missing), DEFERRED 242 entries (copy forward from N2185, minus the resolved
LightBlock updateTile entry).

RED run: registration + exact-evidence fail with `KeyError: 'N2189'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance + driver wiring in `godot-mindustry/src/game/SourceLightBlockBuildState.gd`:
  `source_light_block_smooth_time_state` advances smoothTime toward the live
  timeScale by lerpDelta 0.1f and clamps the radius at `min(smoothTime, 2f)`;
  the driver calls it every tick after the consumption fold. Header quotes all
  94 exact exprs, each on ONE comment line. All documented limits recorded in
  the pure function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07LightBlockUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11382/1637/1558/2907**
  (+2/+1/+1/+2 from baseline 11380/1636/1557/2905); audit 1335 unchanged; ledger
  N2189 status done. **Power shard DID change** (LightBlock.java lives at
  `core/src/mindustry/world/blocks/power/LightBlock.java`): power_slices 111→112,
  power_api_contracts 90→91, purely additive N2189 mirrors.
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 94/94,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all).
  The proof scene is written but NEVER run; see GOAL.md §5 debt.
- No coordinator fix: the worker used `game_source_delta` (seconds × 60) from
  the start — the correct Time.delta. This slice is one of the references for
  the 60x lesson (N2186/N2187/N2191 were fixed to match it).

## Neighbours (batch)

Family run 10:20 +07 (41 modules, 164 tests) + new targeted 9/12 + wiring-standard
set (9 modules / 32 tests): **155/208 PASS**, 53 failures ALL verified
`AssertionError: unexpectedly None` (41 family + 3 new targeted + 9 wiring),
0 other failures, 0 `ERROR:` lines — no regression. Log
`tools/mindustry_godot_transpiler/batch1-neighbours.log` (untracked).

## Gate (batch)

Full gate launched from the coordinator main thread 10:20 +07 via
`setsid nohup python3 -m unittest discover -s tests`, PID 12303, SID 12303.
Finished 10:39 +07: **Ran 5849 tests in 1131.248s, FAILED (failures=139,
skipped=5)** — 0 errors, 0 `ERROR:` lines. All 139 verified Godot-absent
(139 × `AssertionError: unexpectedly None`), exactly as expected (136 inherited
+ 3 new: N2186/N2187/N2189 proof tests). Log
`tools/mindustry_godot_transpiler/full-suite-batch1-gate.log` (untracked).

## Commits

- Slice: `d3e8f4de` — C07: N2189 LightBlock updateTile advance, 5 files (+520/−6),
  on `slice/N2189-light-block-update-tile`.
- SSOT: `ae307497` — C07: N2189 SSOT registration (11382/1637/1558/2907), 6 files (+549).
- Integration: slice cherry-pick `8803e1e7` on
  `integration/batch-n2186-n2187-n2189`; batch SSOT `ca44caa0` (combined
  11386/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2186/N2187/N2189.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- drawLight modeling beyond the efficiency fold (LightBlock.java:128) — its own slice.
- sense modeling — its own slice.
- Draw / config modeling — their own slices.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07LightBlockUpdateTileProof`, commit carrying the scene `d3e8f4de`, 9 keys
  (`smooth_time_lerp_delta_step`, `smooth_time_converges_after_ticks`,
  `smooth_time_holds_at_time_scale`, `light_radius_clamps_at_two`,
  `smooth_time_tick_advances_live`, `power_status_row_unchanged`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_light_block_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: the remaining updateTile advances (N2190 Radar, N2191 Accelerator, N2192
  ImpactReactor, N2193 MendProjector, N2194 OverdriveProjector, N2195 BeamDrill —
  all done, batches 2/3), then second consumers. Most remaining advances need
  frame-state infra (items, liquids, payload, targets).
