# Report — N2195: BeamDrill updateTile advance (C07)

Date: 2026-11-15. Batch: N2193 + N2194 + N2195 + N2196 (integration branch
`integration/batch-n2193-n2194-n2195-n2196`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2195 (parallel wave 1, coordinator-verified). Slice commit `aa390da5`
on `slice/N2195-beam-drill-update-tile`; SSOT commit `669290e4`; coordinator
fix `c1682bca` (correct enabled-gate claim + disabled-early-return deferral —
see GREEN). Integration cherry-picks: slice `c42968e1`, fix `7fa5d6ad`.

## What changed

N2155 proved the BeamDrill family's live power read: the tick folds power.status
into the min efficiency and the lastDrillSpeed fold (BeamDrill.java:249)
follows it — but the port tracked no warmup / boostWarmup / time at all, so a
beam drill never accumulated time toward drillTime and never dropped anything.
N2195 is the updateTile advance (BeamDrillBuild.updateTile(), BeamDrill.java:
237-263, the internal part): warmup approachDelta toward num(efficiency > 0),
the boost multiplier lerp(1, 2.5, optionalEfficiency), boostWarmup lerpDelta
toward optionalEfficiency, and time += edelta() × multiplier.

Formulas verified line by line against BeamDrill.java:242-251: approachDelta
1/60, multiplier lerp 2.5, boostWarmup lerpDelta 0.1, time += edelta ×
multiplier. optionalBoostIntensity stays the class 2.5f (BeamDrill.java:44)
for both defs; drillTime is a class default 200f overridden per def (160f /
100f, Blocks.java:3042/3055). optionalEfficiency is already folded by the
shared machinery (with no optional rows modeled yet it is min(1.0,
minEfficiency), the Java default for zero optional consumers,
BuildingComp.java:1965/1986). timeScale reads live from the sprite meta
(default 1.0, BuildingComp.java:98). super.updateTile() is an empty no-op
(BuildingComp.java:2010-2012), so the driver owes it nothing.

**Documented deviation — the enabled gate:** the worker first claimed the
advance freezes when disabled; that is wrong. Java runs updateTile even when
disabled (the gate `if(enabled || !block.noUpdateDisabled){` passes because
noUpdateDisabled defaults false, Block.java:170). The port driver still gates
the advance on enabled, because the frame efficiency is never zeroed when
disabled (the driver-wide disabled early return is missing — see Deferred),
so an ungated advance would warm up on stale efficiency. The gate is a
documented deviation, pending the driver-wide fix; the coordinator fix
`c1682bca` corrected the claim and added the deferral (same as N2192).

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_beam_drill_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_beam_drill_update_tile.py`
written by worker-N2195. Register script: EXACT_EXPRS = the 26 verified exprs
(all 26 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 245 entries (copy forward from N2185, minus the resolved entries,
plus new deferrals including the disabled-early-return deferral).

RED run: registration + exact-evidence fail with `KeyError: 'N2195'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance in `godot-mindustry/src/game/SourceBeamDrillBuildState.gd`:
  `source_beam_drill_update_tile_advance_state` returns the 4 advanced values
  (warmup, boostWarmup, multiplier, time) from the frame; the driver runs it
  after the consumption fold and writes the new values back to the frame.
  Header quotes all 26 exact exprs, each on ONE comment line. All documented
  limits recorded in the pure function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07BeamDrillUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11384/1637/1558/2907**
  (+4/+1/+1/+2 from baseline 11380/1636/1557/2905 — the +4 symbols are the 4
  return values); audit 1335 unchanged; ledger N2195 status done.
  **Production shard changed** (BeamDrill.java lives under
  `/world/blocks/production/`, the N2155 precedent): production_slices 48→49,
  production_api_contracts 42→43 (+ symbols shard).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 26/26,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- **Coordinator fix `c1682bca`:** the worker's comment claimed the advance
  freezes when disabled (wrong gate reading — see What changed). Fixed the
  comment to state the Java gate correctly and added the disabled-early-return
  deferral to the register (deferred 245). Targeted re-run after the fix:
  still 3/4 + Godot-absent. The driver keeps the enabled gate as a documented
  deviation until the driver-wide fix lands.

## Neighbours (batch — see the batch-3 report section in each slice report)

Family run 11:02 +07 (41 modules, 164 tests) + new targeted 9/12 + conduit
N2196 6/8 + wiring-standard set (9 modules / 32 tests): **161/216 PASS**,
55 failures ALL verified `AssertionError: unexpectedly None` (41 family +
3 new targeted + 2 conduit + 9 wiring), 0 other failures, 0 `ERROR:` lines —
no regression. Log `tools/mindustry_godot_transpiler/batch3-neighbours.log`
(untracked).

## Gate (batch)

Full gate (batch, PID 20921, coordinator main thread, launch 11:02, done 11:19 +07,
log `tools/mindustry_godot_transpiler/full-suite-batch3-gate.log`, untracked):
Ran 5850 in 1044.287s, failures=139, skipped=5, 0 errors — 139/139 verified
Godot-absent (136 inherited + 3 new proof tests N2193/N2194/N2195, all confirmed
present in the failures; 0 `ERROR:` lines). Ran 5850, not 5849 as in batches 1–2,
because N2196 added 1 passing test (`test_conduit_update_uses_source_delta_ticks_not_raw_seconds`).
Gate clean except Godot; no regression.

## Commits

- Slice: `aa390da5` — C07: N2195 BeamDrill updateTile advance, 5 files (+516/−7),
  on `slice/N2195-beam-drill-update-tile`.
- SSOT: `669290e4` — C07: N2195 SSOT registration (11384/1637/1558/2907), 8 files (+639).
- Coordinator fix: `c1682bca` — C07: N2195 coordinator fix (correct enabled-gate claim; add disabled-early-return deferral).
- Integration: slice cherry-pick `c42968e1` + fix cherry-pick `7fa5d6ad` on
  `integration/batch-n2193-n2194-n2195-n2196`; batch SSOT `76a87003` (combined
  11391/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2193/N2194/N2195 (+N2196 note).
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- lastItem is NOT tracked (set by updateFacing, BeamDrill.java:376-411,
  deferred), so the drop loop + time reset (`time %= drillTime`) +
  lastDrillSpeed + dump timer defer — and time grows unbounded, a documented
  consequence (the LaunchPad counter-freeze precedent).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) — see
  What changed; the enabled gate on the advance is a documented deviation
  until that fix lands.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07BeamDrillUpdateTileProof`, commit carrying the scene `aa390da5`, 9 keys
  (`warmup_approaches_one_when_powered`, `warmup_decays_to_zero_without_power`,
  `boost_warmup_lerps_to_optional_efficiency`, `multiplier_lerps_boost_intensity`,
  `time_advances_by_edelta_times_multiplier`, `live_tick_advances_warmup_and_time`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_beam_drill_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2196 conduit fix (same batch), then N2197 link infra (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) → N2188
  ItemBridge gate retry.
