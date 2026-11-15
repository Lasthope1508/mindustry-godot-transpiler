# Report — N2193: MendProjector updateTile advance (C07)

Date: 2026-11-15. Batch: N2193 + N2194 + N2195 + N2196 (integration branch
`integration/batch-n2193-n2194-n2195-n2196`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2193 (parallel wave 1, coordinator-verified; worker handoff
arrived late 10:45 +07 and matched every coordinator-verified number).
Slice commit `ab7a8958` on `slice/N2193-mend-projector-update-tile`; SSOT commit
`f3939cee`; no coordinator fix needed. Integration cherry-pick: slice `d8dce467`.

## What changed

N2156 proved the live power.status -> efficiency driver for the mend projector
(the pure power row folded into the min efficiency, the heal fold
MendProjector.java:113 following it) — but the port still tracked no
smoothEfficiency / heat / charge / phaseHeat on the placed-building frame, so
a mend projector never accumulated charge up to `reload` to heal. N2193 is the
updateTile advance (MendProjector.java:94-120): a pure frame advance over the
exact Java lines — the smoothEfficiency / heat lerps (0.08f), the charge
advance (`charge += heat * delta();`), the phaseHeat lerp (0.1f toward
optionalEfficiency), and the charge reset (`charge = 0f;`) inside the
`charge >= reload` branch, which sits BEFORE the indexer scan, so the reset
does not depend on finding a target.

- canHeal is a documented default true: `canHeal = !checkSuppression();`
  (MendProjector.java:94) needs suppression state the tick does not track yet
  (the N2184 BuildTurret suppression precedent); the pure function takes
  can_heal as a parameter defaulting true, so the suppressed branch (heat
  lerps toward 0) is still provable.
- optionalEfficiency is already folded onto the frame by the shared machinery;
  with no optional consumers modeled it equals the folded efficiency. The
  advance reads it with the Java field default 0.0 (BuildingComp.java:87)
  before any consumption tick.
- delta() = Time.delta × timeScale (BuildingComp.java:1922-1924): Time.delta in
  ticks from the placed-block helper (seconds × TICK_RATE 60), timeScale live
  from the sprite meta (default 1f, BuildingComp.java:98). The lerps use the
  UNSCALED Time.delta (Mathf.java:430-432) — only the charge advance uses the
  scaled delta().
- charge starts at `Mathf.random(reload)` (MendProjector.java:85); the port
  binds 0.0 deterministically (documented deviation: the random stagger only
  desynchronizes first-heal timing across projectors). No deterministic-bind
  precedent exists in the drivers.
- reload per-def from the catalog: mender 200f, mend-projector 250f
  (Blocks.java:1923/1936).

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_mend_projector_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_mend_projector_update_tile.py`
written by worker-N2193. Register script: EXACT_EXPRS = the 17 verified exprs
(all 17 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 245 entries (copy forward from N2185, minus the resolved entries,
plus new deferrals including the runtime_step_state divergence entry).

RED run: registration + exact-evidence fail with `KeyError: 'N2193'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance in `godot-mindustry/src/game/SourceMendProjectorBuildState.gd`:
  `source_mend_projector_update_tile_advance_state` returns the 4 advanced
  values (smoothEfficiency, heat, charge, phaseHeat) from the frame; the
  driver runs it after the consumption fold and writes the new values back to
  the frame. Header quotes all 17 exact exprs, each on ONE comment line. All
  documented limits recorded in the pure function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07MendProjectorUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11384/1637/1558/2907**
  (+4/+1/+1/+2 from baseline 11380/1636/1557/2905 — the +4 symbols are the 4
  frame keys); audit 1335 unchanged; ledger N2193 status done.
  **Defense shard changed** (MendProjector.java lives under
  `/world/blocks/defense/`, the N2156 precedent): defense_slices 154→155,
  defense_api_contracts 153→154.
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 17/17,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- No coordinator fix: the worker used game_source_delta (correct Time.delta
  ticks) and read the updateTile gate correctly (advance runs even when
  disabled) from the start. N2156 in the same family still 3/4 + Godot-absent
  (no regression).

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

- Slice: `ab7a8958` — C07: N2193 MendProjector updateTile advance, 5 files (+808/−6),
  on `slice/N2193-mend-projector-update-tile`.
- SSOT: `f3939cee` — C07: N2193 SSOT registration (11384/1637/1558/2907), 6 files (+575).
- Integration: slice cherry-pick `d8dce467` on
  `integration/batch-n2193-n2194-n2195-n2196`; batch SSOT `76a87003` (combined
  11391/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2193/N2194/N2195 (+N2196 note).
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The heal scan (indexer scan + the actual heal) + timer/consume + sound —
  each its own slice.
- The charge-init random stagger (Java `Mathf.random(reload)`) — bound 0.0
  deterministically, documented deviation.
- Divergence with `runtime_step_state` (DEFERRED entry): the runtime sim lerps
  toward 1.0 unconditionally and never resets charge — a separate reconcile
  slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957): the
  advance runs even when disabled (correct gate) but reads a stale efficiency;
  deferred.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07MendProjectorUpdateTileProof`, commit carrying the scene `ab7a8958`, 9 keys
  (`smooth_efficiency_lerps_to_efficiency`, `heat_lerps_by_efficiency_and_can_heal`,
  `charge_advances_by_heat_delta`, `charge_resets_at_reload`,
  `phase_heat_lerps_to_optional_efficiency`, `efficiency_folds_power_min`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_mend_projector_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2194 (OverdriveProjector updateTile) + N2195 (BeamDrill updateTile)
  + N2196 conduit fix (same batch), then N2197 link infra (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) → N2188
  ItemBridge gate retry.
