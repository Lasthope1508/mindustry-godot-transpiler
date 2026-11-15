# Handoff — N2192 ImpactReactor updateTile advance

Date: 2026-11-15. Batch: N2190 + N2191 + N2192 (integration branch
`integration/batch-n2190-n2191-n2192`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; slice da0b5abd, SSOT 305a0198, fix d280e2e9; NOT pushed,
NOT merged).**

Worker: worker-N2192, done 10:23 +07. Coordinator verified the commit, the
register run, and the targeted run, and fixed the worker's wrong enabled-gate
claim (see GREEN).

## Scoping (DONE 2026-11-15 ~10:1x +07)

- N2182 wired the impact reactor's live power.status read, but the updateTile
  advance (ImpactReactor.java:78-101) still waited: no frame key tracked
  warmup / totalProgress / productionEfficiency, so the reactor could never
  warm up to `productionEfficiency = Mathf.pow(warmup, 5f);`
  (ImpactReactor.java:100). The advance is self-contained (internal fields +
  the folded efficiency + the stamped power.status) — no items/liquids/targets
  state needed.
- warmupSpeed is the class default 0.001f (ImpactReactor.java:19), NOT
  overridden by the single impact-reactor def (Blocks.java:2632-2645).
- The Java gate `if(enabled || !block.noUpdateDisabled){` passes even when
  disabled (noUpdateDisabled defaults false, Block.java:170) — Java runs
  updateTile while disabled. The port driver gates the advance on enabled as
  a DOCUMENTED DEVIATION, because the frame efficiency is never zeroed when
  disabled (the driver-wide disabled early return is missing); an ungated
  advance would warm up on stale efficiency.
- SSOT baseline re-verified from the generated JSONs (main de9ab89c, N2185 DONE):
  symbols 11380 + slices 1636 + contracts 1557 + schemas 2905; audit
  `totalSourceFunctions` 1335. Expected after N2192: **11383/1637/1558/2907**
  (the +3 symbols are the 3 return values) — reached at the register run.
- Power shard change expected (ImpactReactor.java lives under
  `/world/blocks/power/`, the N2182 precedent): power_slices 111→112,
  power_api_contracts 90→91 — confirmed at the register run.

## Design (decided in scoping, recorded in test + register)

- Pure `SourceImpactReactorBuildState.source_impact_reactor_update_tile_advance_state(frame, ...)`
  returning the 3 advanced values (warmup, totalProgress, productionEfficiency)
  from the frame.
- The driver runs the advance AFTER the consumption fold (BuildingComp.update(),
  BuildingComp.java:2274 `updateConsumption();` then :2277 `updateTile();`),
  gated on enabled (documented deviation — see Scoping).
- Mathf.equal inlined as absf(warmup − 1.0) <= 0.001 (the port has no
  Mathf.equal helper; Mathf.java:554-555); Mathf.pow is Godot pow()
  (Mathf.java:212-213); timeScale is the sprite-meta timeScale
  (BuildingComp.java:98, default 1f), read through the UnitFactory precedent.
- The first-production event (ImpactReactor.java:87-88) and the consume timer
  (ImpactReactor.java:91-92) are deferred; the producer fold does not read
  the new `production_efficiency` frame key yet.
- Proof scene `C07ImpactReactorUpdateTileProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~10:1x +07, worker-N2192)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_update_tile.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_impact_reactor_update_tile.py`.
- Register script verified standalone: **exit 0**. **35 exact exprs, 0 missing**;
  DEFERRED 244 entries. OWNER
  `SourceImpactReactorBuildState.source_impact_reactor_update_tile_advance_state`, PROOF
  `/root/C07ImpactReactorUpdateTileProof`.
- Targeted RED run: registration + exact-evidence fail `KeyError: 'N2192'`,
  row-state fails on the missing function, proof test fails Godot-absent
  (`AssertionError: unexpectedly None` at `assertIsNotNone(godot)`). No other
  failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 ~10:23 +07, worker-N2192; coordinator fix same day)

- Pure advance + driver wiring in `SourceImpactReactorBuildState.gd` (5 files,
  +592/−2); proof scene (6 keys); all 35 exact exprs present, each on ONE
  comment line.
- SSOT at GREEN (coordinator register run): **11383/1637/1558/2907**, audit 1335,
  power shards slices 112 / contracts 91. `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 35/35,
  row-state) + proof test FAIL, exactly `AssertionError: unexpectedly None` —
  no Godot on this VM (user order: no Godot runs here at all).
- **Coordinator fix `d280e2e9`:** the worker's comment claimed the advance
  freezes when disabled (wrong gate reading — Java runs updateTile even when
  disabled). Fixed the comment to state the Java gate correctly and added the
  disabled-early-return deferral to the register (deferred 244). Targeted
  re-run after the fix: still 3/4 + Godot-absent. The driver keeps the enabled
  gate as a documented deviation until the driver-wide fix lands.

## Neighbours (DONE 2026-11-15 10:4x +07, batch — coordinator, main thread)

- Family run `python3 -m unittest discover -s tests -p 'test_c07_*_power_status.py'`
  (41 modules, 164 tests): 123/164 PASS, 41 Godot-absent. New targeted 9/12
  (3 Godot-absent). Wiring-standard set (9 modules / 32 tests): 23/32 PASS,
  9 Godot-absent. **Total 155/208 PASS, 53 Godot-absent, 0 other failures,
  0 `ERROR:` lines — no regression.** Numbers recorded in STATUS.md
  (coordinator-verified; no log file was saved for the batch-2 neighbours run).

## Exact exprs (35, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_impact_reactor_update_tile.py` EXACT_EXPRS (35 entries,
including the warmup gate `if(efficiency >= 0.9999f && power.status >= 0.99f){`,
the warmup lerp/snap/decay, `totalProgress += warmup * Time.delta;`, and
`productionEfficiency = Mathf.pow(warmup, 5f);`).

## Next

- Batch 3 {N2193 MendProjector, N2194 OverdriveProjector, N2195 BeamDrill}
  updateTile + N2196 conduit Time.delta fix: code + SSOT integrated on their
  slice branches; batch integration after the batch-2 gate.
- After batch 3: frame-state infra (config/link, items, liquids, payload,
  targets, recipe, unit) — shared-file design work for the coordinator, not
  parallel worker slices; it unblocks N2188 ItemBridge and most remaining
  C07 gates/advances.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) is a
  separate fix slice — N2192 documents the enabled-gate deviation + a
  DEFERRED entry (deferred 244).
- Godot proof debt: `C07ImpactReactorUpdateTileProof`, 9 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `da0b5abd` — C07: N2192 ImpactReactor updateTile advance, 5 files (+592/−2).
- SSOT: `305a0198` — C07: N2192 SSOT registration (11383/1637/1558/2907), 6 files (+522).
- Coordinator fix: `d280e2e9` — correct updateTile enabled-gate claim; add disabled-early-return deferral.
- Integration: slice cherry-pick `52e3b178` + fix cherry-pick `a646945c` on
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
