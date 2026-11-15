# Handoff — N2191 Accelerator updateTile advance

Date: 2026-11-15. Batch: N2190 + N2191 + N2192 (integration branch
`integration/batch-n2190-n2191-n2192`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; slice 468a2bb5, SSOT ff2eb6d1, fix 20e45d33; NOT pushed,
NOT merged).**

Worker: worker-N2191, done 10:21 +07; worker handoff arrived late 10:30 +07 and
matched every coordinator-verified number. Coordinator verified the commit, the
register run, and the targeted run, and fixed the 60x Time.delta bug (see GREEN).

## Scoping (DONE 2026-11-15 ~10:1x +07)

- N2183 gave the accelerator its live power.status read, but the updateTile
  advance (Accelerator.java:127-146) still waited: heat/statusLerp/time/
  launchHeat/progress sat at their defaults, so progress never reached 1f and
  isCoreBuilt (Accelerator.java:153-154) never passed. The advance is
  self-contained (internal fields only) — no items/liquids/targets state needed.
- buildDuration is the class field 120f (Accelerator.java:52), not overridden
  by the interplanetary-accelerator def. `launching` defaults false (Java
  boolean default); only beginLaunch sets it true (Accelerator.java:334-337).
- The gate `if(enabled || !block.noUpdateDisabled){` passes even when disabled
  (noUpdateDisabled defaults false, Block.java:170; Accelerator never sets it),
  so the advance runs while disabled — and reads the frame efficiency, which
  the driver never zeroes when disabled (stale-efficiency deviation,
  documented as limit 7 + a DEFERRED entry).
- SSOT baseline re-verified from the generated JSONs (main de9ab89c, N2185 DONE):
  symbols 11380 + slices 1636 + contracts 1557 + schemas 2905; audit
  `totalSourceFunctions` 1335. Expected after N2191: **11385/1637/1558/2907**
  (the +5 symbols are the 5 return values) — reached at the register run.
- No shard change expected (Accelerator.java is not under a shard selection
  path) — confirmed at the register run.

## Design (decided in scoping, recorded in test + register)

- Pure `SourceAcceleratorBuildState.source_accelerator_update_tile_advance_state(frame, ...)`
  returning the 5 advanced values (heat, statusLerp, time, launchHeat,
  progress) from the frame.
- The driver runs the advance after the consumption fold (Building.update()
  calls updateConsumption() then updateTile(), BuildingComp.java:2274-2278).
- The shared lerpDelta helper (SourceMathState.source_lerp_delta) is reused
  for heat/statusLerp/launchHeat; the port has no slerp helper, so the advance
  carries a local `source_mathf_slerp_delta` transliterating Mathf.slerpDelta
  (Mathf.java:460-462; slerp is the angle lerp in degrees with wrap,
  Mathf.java:455-458; GDScript fmod matches Java %).
- Proof scene `C07AcceleratorUpdateTileProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~10:1x +07, worker-N2191)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_accelerator_update_tile.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_accelerator_update_tile.py`.
- Register script verified standalone: **exit 0**. **41 exact exprs, 0 missing**;
  DEFERRED 244 entries. OWNER
  `SourceAcceleratorBuildState.source_accelerator_update_tile_advance_state`, PROOF
  `/root/C07AcceleratorUpdateTileProof`.
- Targeted RED run: registration + exact-evidence fail `KeyError: 'N2191'`,
  row-state fails on the missing function, proof test fails Godot-absent
  (`AssertionError: unexpectedly None` at `assertIsNotNone(godot)`). No other
  failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 ~10:21 +07, worker-N2191; coordinator fix same day)

- Pure advance + driver wiring in `SourceAcceleratorBuildState.gd` (5 files,
  +1082/−4); proof scene (6 keys); all 41 exact exprs present, each on ONE
  comment line.
- SSOT at GREEN (coordinator register run): **11385/1637/1558/2907**, audit 1335,
  no shard change. `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 41/41,
  row-state) + proof test FAIL, exactly `AssertionError: unexpectedly None` —
  no Godot on this VM (user order: no Godot runs here at all).
- **Coordinator fix `20e45d33`:** the worker passed raw `seconds` as Time.delta
  (60x too slow — `_process(delta)` gives seconds, Java Time.delta = seconds×60,
  arc Time.java:26; the conduit precedent it followed is itself the bug, fixed
  as N2196). Fixed to `game_source_delta(game, seconds)`, the pure parameter
  renamed to `source_delta`, and the proof expectation fixed with it (the live
  tick now expects Time.delta ticks). Targeted re-run after the fix: still 3/4
  + Godot-absent. Lesson recorded in the briefs: **Time.delta = seconds × 60,
  never raw seconds**.

## Neighbours (DONE 2026-11-15 10:4x +07, batch — coordinator, main thread)

- Family run `python3 -m unittest discover -s tests -p 'test_c07_*_power_status.py'`
  (41 modules, 164 tests): 123/164 PASS, 41 Godot-absent. New targeted 9/12
  (3 Godot-absent). Wiring-standard set (9 modules / 32 tests): 23/32 PASS,
  9 Godot-absent. **Total 155/208 PASS, 53 Godot-absent, 0 other failures,
  0 `ERROR:` lines — no regression.** Numbers recorded in STATUS.md
  (coordinator-verified; no log file was saved for the batch-2 neighbours run).

## Exact exprs (41, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_accelerator_update_tile.py` EXACT_EXPRS (41 entries,
including the heat/statusLerp/time/launchHeat/progress advances, the
buildDuration 120f class field, and the lerpDelta/slerpDelta formulas).

## Next

- N2192 ImpactReactor updateTile (same batch, done).
- Batch 3 {N2193 MendProjector, N2194 OverdriveProjector, N2195 BeamDrill}
  updateTile + N2196 conduit Time.delta fix: code + SSOT integrated on their
  slice branches; batch integration after the batch-2 gate.
- After batch 3: frame-state infra (config/link, items, liquids, payload,
  targets, recipe, unit) — shared-file design work for the coordinator, not
  parallel worker slices; it unblocks N2188 ItemBridge and most remaining
  C07 gates/advances.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) is a
  separate fix slice — N2191 documents the stale-efficiency deviation as
  limit 7 + a DEFERRED entry.
- Godot proof debt: `C07AcceleratorUpdateTileProof`, 9 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `468a2bb5` — C07: N2191 Accelerator updateTile advance, 5 files (+1082/−4).
- SSOT: `ff2eb6d1` — C07: N2191 SSOT registration (11385/1637/1558/2907), 4 files (+512).
- Coordinator fix: `20e45d33` — 60x Time.delta → game_source_delta; rename pure param to source_delta.
- Integration: slice cherry-pick `fafe334f` + fix cherry-pick `ed17c642` on
  `integration/batch-n2190-n2191-n2192`; batch SSOT `68fc759c`.
- Docs: (this commit) — report + handoff + spec + GOAL for N2190/N2191/N2192.

## Gate (DONE 2026-11-15 ~11:00 +07, log `full-suite-batch2-gate.log`, batch)

- Full gate launched from the coordinator main thread 10:43 +07 via
  `setsid nohup python3 -m unittest discover -s tests`, PID 18806, SID 18806.
  Single gate only. No Godot on PATH.
- Finished 11:00 +07: **Ran 5849 tests in 1041.246s, FAILED (failures=139,
  skipped=5)** — 0 errors, 0 `ERROR:` lines. All 139 verified Godot-absent
  (139 × `AssertionError: unexpectedly None`), exactly as expected (136 inherited
  + 3 new: N2190/N2191/N2192 proof tests).
