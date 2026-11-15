# Handoff — N2193 MendProjector updateTile advance

Date: 2026-11-15. Batch: N2193 + N2194 + N2195 + N2196 (integration branch
`integration/batch-n2193-n2194-n2195-n2196`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; slice ab7a8958, SSOT f3939cee; NOT pushed,
NOT merged).**

Worker: worker-N2193, done 10:28 +07; worker handoff arrived late 10:45 +07 and
matched every coordinator-verified number. Coordinator verified the commit, the
register run, and the targeted run directly from git. No coordinator fix needed.

## Scoping (DONE 2026-11-15 ~10:2x +07)

- N2156 proved the live power.status -> efficiency driver for the mend
  projector, but the updateTile advance (MendProjector.java:94-120) still
  waited: smoothEfficiency / heat / charge / phaseHeat never moved, so a mend
  projector never accumulated charge up to `reload` to heal. The advance is
  self-contained (internal fields + the folded efficiency + the stamped
  optionalEfficiency) — no items/liquids/targets state needed.
- canHeal is a documented default true: `canHeal = !checkSuppression();`
  (MendProjector.java:94) needs suppression state the tick does not track yet
  (the N2184 BuildTurret suppression precedent).
- charge starts at `Mathf.random(reload)` (MendProjector.java:85); the port
  binds 0.0 deterministically (documented deviation; NO deterministic-bind
  precedent exists in the drivers — corrected from the worker's first note).
- reload per-def from the catalog: mender 200f, mend-projector 250f
  (Blocks.java:1923/1936).
- SSOT baseline re-verified from the generated JSONs (main de9ab89c, N2185 DONE):
  symbols 11380 + slices 1636 + contracts 1557 + schemas 2905; audit
  `totalSourceFunctions` 1335. Expected after N2193: **11384/1637/1558/2907**
  (the +4 symbols are the 4 frame keys) — reached at the register run.
- Defense shard change expected (MendProjector.java lives under
  `/world/blocks/defense/`, the N2156 precedent): defense_slices 154→155,
  defense_api_contracts 153→154 — confirmed at the register run.

## Design (decided in scoping, recorded in test + register)

- Pure `SourceMendProjectorBuildState.source_mend_projector_update_tile_advance_state(frame, ...)`
  returning the 4 advanced values (smoothEfficiency, heat, charge, phaseHeat)
  from the frame, in Java order: smoothEfficiency/heat lerps (0.08f), charge
  advance (`charge += heat * delta();`), phaseHeat lerp (0.1f toward
  optionalEfficiency), charge reset (`charge = 0f;`) inside the
  `charge >= reload` branch BEFORE the indexer scan.
- The driver runs the advance after the consumption fold. delta() =
  Time.delta × timeScale (BuildingComp.java:1922-1924); the lerps use the
  UNSCALED Time.delta (Mathf.java:430-432) — only the charge advance uses the
  scaled delta().
- The heal scan itself is deferred — the reset does not depend on finding a
  target, so the advance is complete without it.
- Proof scene `C07MendProjectorUpdateTileProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 ~10:2x +07, worker-N2193)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_mend_projector_update_tile.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_mend_projector_update_tile.py`.
- Register script verified standalone: **exit 0**. **17 exact exprs, 0 missing**;
  DEFERRED 245 entries. OWNER
  `SourceMendProjectorBuildState.source_mend_projector_update_tile_advance_state`, PROOF
  `/root/C07MendProjectorUpdateTileProof`.
- Targeted RED run: registration + exact-evidence fail `KeyError: 'N2193'`,
  row-state fails on the missing function, proof test fails Godot-absent
  (`AssertionError: unexpectedly None` at `assertIsNotNone(godot)`). No other
  failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 ~10:28 +07, worker-N2193)

- Pure advance + driver wiring in `SourceMendProjectorBuildState.gd` (5 files,
  +808/−6); proof scene (6 keys); all 17 exact exprs present, each on ONE
  comment line.
- SSOT at GREEN (coordinator register run): **11384/1637/1558/2907**, audit 1335,
  defense shards slices 155 / contracts 154. `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 17/17,
  row-state) + proof test FAIL, exactly `AssertionError: unexpectedly None` —
  no Godot on this VM (user order: no Godot runs here at all).
- No coordinator fix: correct Time.delta ticks (game_source_delta) and correct
  updateTile gate (advance runs even when disabled) from the start. N2156 in
  the same family still 3/4 + Godot-absent (no regression).

## Neighbours (DONE 2026-11-15 11:02 +07, batch — coordinator, main thread)

- Family run `python3 -m unittest discover -s tests -p 'test_c07_*_power_status.py'`
  (41 modules, 164 tests): 123/164 PASS, 41 Godot-absent. New targeted 9/12
  (3 Godot-absent). Conduit N2196 6/8 (2 Godot-absent). Wiring-standard set
  (9 modules / 32 tests): 23/32 PASS, 9 Godot-absent. **Total 161/216 PASS,
  55 Godot-absent, 0 other failures, 0 `ERROR:` lines — no regression.**
  Log `batch3-neighbours.log` (untracked).

## Exact exprs (17, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_mend_projector_update_tile.py` EXACT_EXPRS (17 entries,
including the smoothEfficiency/heat lerps, `charge += heat * delta();`, the
phaseHeat lerp, and the charge reset before the indexer scan).

## Next

- N2194 OverdriveProjector updateTile + N2195 BeamDrill updateTile + N2196
  conduit fix (same batch, done).
- After batch 3: N2197 link infra (coordinator, serial — see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`), then
  N2188 ItemBridge gate retry + N2198 LiquidBridge gate (workers).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) is a
  separate fix slice (N2191/N2192/N2194/N2195 document the stale-efficiency
  deviation; N2193 reads the same stale efficiency while disabled).
- The `runtime_step_state` divergence (lerps to 1.0 unconditionally, never
  resets charge) needs its own reconcile slice.
- Godot proof debt: `C07MendProjectorUpdateTileProof`, 9 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `ab7a8958` — C07: N2193 MendProjector updateTile advance, 5 files (+808/−6).
- SSOT: `f3939cee` — C07: N2193 SSOT registration (11384/1637/1558/2907), 6 files (+575).
- Integration: slice cherry-pick `d8dce467` on
  `integration/batch-n2193-n2194-n2195-n2196`; batch SSOT `76a87003`.
- Docs: (this commit) — report + handoff + spec + GOAL for N2193/N2194/N2195 (+N2196 note).

## Gate (DONE 2026-11-15 11:19 +07, log `full-suite-batch3-gate.log`, batch)

Full gate (batch, PID 20921, coordinator main thread, launch 11:02, done 11:19 +07,
log `tools/mindustry_godot_transpiler/full-suite-batch3-gate.log`, untracked):
Ran 5850 in 1044.287s, failures=139, skipped=5, 0 errors — 139/139 verified
Godot-absent (136 inherited + 3 new proof tests N2193/N2194/N2195, all confirmed
present in the failures; 0 `ERROR:` lines). Ran 5850, not 5849 as in batches 1–2,
because N2196 added 1 passing test (`test_conduit_update_uses_source_delta_ticks_not_raw_seconds`).
Gate clean except Godot; no regression.
