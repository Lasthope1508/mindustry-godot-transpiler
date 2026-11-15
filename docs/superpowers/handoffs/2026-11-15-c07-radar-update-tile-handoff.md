# Handoff — N2190 Radar updateTile advance

Date: 2026-11-15. Batch: N2190 + N2191 + N2192 (integration branch
`integration/batch-n2190-n2191-n2192`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; slice 950087a7, SSOT 27d45a21; NOT pushed,
NOT merged).**

Worker: worker-N2190, done 10:21 +07. Coordinator verified the commit, the
register run, and the targeted run. No coordinator fix needed.

## Scoping (DONE 2026-11-15 ~10:1x +07)

- N2173 gave the radar its live power.status read, but the updateTile advance
  (Radar.java:60-72) still waited: smoothEfficiency/progress/totalProgress/
  lastRadius never moved. The advance is self-contained (internal fields only)
  — no items/liquids/targets state needed.
- One def: radar (consumePower 0.6f, Blocks.java:1994; fogRadius 34,
  Blocks.java:1991; discoveryTime 60f * 10f, Radar.java:18). The catalog
  carries no fogRadius property, so the driver passes the def constant 34.0.
- SSOT baseline re-verified from the generated JSONs (main de9ab89c, N2185 DONE):
  symbols 11380 + slices 1636 + contracts 1557 + schemas 2905; audit
  `totalSourceFunctions` 1335. Expected after N2190: **11382/1637/1558/2907**
  (the +2/+1/+1/+2 pattern) — reached at the register run.
- Defense shard change expected (Radar.java lives under
  `/world/blocks/defense/`, the N2173 precedent): defense_slices 154→155,
  defense_api_contracts 153→154 — confirmed at the register run.

## Design (decided in scoping, recorded in test + register)

- Pure `SourceRadarBuildState.source_radar_update_tile_state(frame, ...)`
  returning the advance dict (advance + force_update_needed flag) from the
  frame, in Java order: smooth-efficiency lerp, fog-radius change check,
  progress advance + clamp, total-progress advance.
- The driver runs the advance after the consumption fold and writes the new
  smoothEfficiency/progress/totalProgress/lastRadius back to the frame. The
  driver passes seconds × TICK_RATE as the source delta (the N2093 pump
  precedent; arc Time.java:26), so edelta is in Time.delta ticks.
- The `fogControl.forceUpdate` call (Radar.java:64) is deferred — the advance
  tracks only the condition and the lastRadius write.
- Proof scene `C07RadarUpdateTileProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~10:1x +07, worker-N2190)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_radar_update_tile.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_radar_update_tile.py`.
- Register script verified standalone: **exit 0**. **24 exact exprs, 0 missing**;
  DEFERRED 242 entries. OWNER
  `SourceRadarBuildState.source_radar_update_tile_state`, PROOF
  `/root/C07RadarUpdateTileProof`.
- Targeted RED run: registration + exact-evidence fail `KeyError: 'N2190'`,
  row-state fails on the missing function, proof test fails Godot-absent
  (`AssertionError: unexpectedly None` at `assertIsNotNone(godot)`). No other
  failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 ~10:21 +07, worker-N2190)

- Pure advance + driver wiring in `SourceRadarBuildState.gd` (5 files,
  +532/−3); proof scene (6 keys); all 24 exact exprs present, each on ONE
  comment line.
- SSOT at GREEN (coordinator register run): **11382/1637/1558/2907**, audit 1335,
  defense shards slices 155 / contracts 154. `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 24/24,
  row-state) + proof test FAIL, exactly `AssertionError: unexpectedly None` —
  no Godot on this VM (user order: no Godot runs here at all).
- No coordinator fix: the worker passed seconds × TICK_RATE as the source
  delta from the start (correct Time.delta ticks, unlike N2186/N2187/N2191).

## Neighbours (DONE 2026-11-15 10:4x +07, batch — coordinator, main thread)

- Family run `python3 -m unittest discover -s tests -p 'test_c07_*_power_status.py'`
  (41 modules, 164 tests): 123/164 PASS, 41 Godot-absent. New targeted 9/12
  (3 Godot-absent). Wiring-standard set (9 modules / 32 tests): 23/32 PASS,
  9 Godot-absent. **Total 155/208 PASS, 53 Godot-absent, 0 other failures,
  0 `ERROR:` lines — no regression.** Numbers recorded in STATUS.md
  (coordinator-verified; no log file was saved for the batch-2 neighbours run).

## Exact exprs (24, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_radar_update_tile.py` EXACT_EXPRS (24 entries,
including `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`,
the progress/totalProgress advances, and the fog-radius change check).

## Next

- N2191 Accelerator updateTile + N2192 ImpactReactor updateTile (same batch, done).
- Batch 3 {N2193 MendProjector, N2194 OverdriveProjector, N2195 BeamDrill}
  updateTile + N2196 conduit Time.delta fix: code + SSOT integrated on their
  slice branches; batch integration after the batch-2 gate.
- After batch 3: frame-state infra (config/link, items, liquids, payload,
  targets, recipe, unit) — shared-file design work for the coordinator, not
  parallel worker slices; it unblocks N2188 ItemBridge and most remaining
  C07 gates/advances.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) is a
  separate fix slice (N2191/N2192/N2194/N2195 all document the stale-efficiency
  deviation).
- Godot proof debt: `C07RadarUpdateTileProof`, 9 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `950087a7` — C07: N2190 Radar updateTile advance, 5 files (+532/−3).
- SSOT: `27d45a21` — C07: N2190 SSOT registration (11382/1637/1558/2907), 6 files (+539).
- Integration: slice cherry-pick `6baeb7bc` on
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
