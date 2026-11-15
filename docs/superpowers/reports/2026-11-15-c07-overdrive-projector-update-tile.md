# Report — N2194: OverdriveProjector updateTile advance (C07)

Date: 2026-11-15. Batch: N2193 + N2194 + N2195 + N2196 (integration branch
`integration/batch-n2193-n2194-n2195-n2196`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2194 (parallel wave 1, coordinator-verified). Slice commit `32fdf11c`
on `slice/N2194-overdrive-projector-update-tile`; SSOT commit `1722b6b4`;
coordinator fix `3e15681f` (document disabled-stale-efficiency deviation +
disabled-early-return deferral — see GREEN). Integration cherry-picks: slice
`2723e795`, fix `447c0bc3`.

## What changed

N2157 proved the live power.status -> efficiency driver for the
OverdriveProjector family, but the port tracked NO updateTile advance:
smoothEfficiency / heat / charge / phaseHeat / useProgress never moved, so an
overdrive projector never accumulated charge to `reload` and never boosted.
N2194 is the OverdriveBuild.updateTile() internal advance
(OverdriveProjector.java:97-120): the smooth-efficiency and heat lerps
(OverdriveProjector.java:98-99), the charge advance on raw Time.delta
(OverdriveProjector.java:100, NOT delta() — unlike MendProjector's
`charge += heat * delta();`), the phaseHeat lerp toward optionalEfficiency
when hasBoost (OverdriveProjector.java:102-104), the charge reset at reload
(OverdriveProjector.java:111-112, before the indexer scan, so the reset does
not depend on finding a target), and the useProgress advance on delta() =
Time.delta × timeScale with the wrap at useTime (OverdriveProjector.java:116-120).
The useProgress wrap fires with the branch: consume() returns void, so nothing
gates `useProgress %= useTime;` on consume's outcome — the wrap is unconditional.

- Per-def from the catalog: overdrive-projector hasBoost true, useTime 400f,
  reload 60f; overdrive-dome hasBoost false (Blocks.java:1960), useTime 300f
  (Blocks.java:1958), reload 60f — read through the family's accessors, no
  per-def stamp needed.
- The charge init binds Java's `Mathf.random(reload)`
  (OverdriveProjector.java:84) to deterministic 0.0 — the runtime-state default
  precedent (SourceOverdriveProjectorRuntimeState.capture_state /
  runtime_step_state default charge 0.0) — so proofs are deterministic. (Note:
  N2193 MendProjector has NO such precedent; the two slices document this
  difference explicitly.)
- The pure function defaults a missing efficiency to 1.0 (matching the driver
  setup default) — unlike N2193/N2195, which use 0.0. Noted as a point to
  standardize later; the difference is documented, not hidden.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_overdrive_projector_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_overdrive_projector_update_tile.py`
written by worker-N2194. Register script: EXACT_EXPRS = the 22 verified exprs
(all 22 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 244 entries (copy forward from N2185, minus the resolved entries,
plus new deferrals including the disabled-early-return deferral).

RED run: registration + exact-evidence fail with `KeyError: 'N2194'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance in `godot-mindustry/src/game/SourceOverdriveProjectorBuildState.gd`:
  `source_overdrive_projector_update_tile_advance_state` returns the advanced
  values (smoothEfficiency, heat, charge, phaseHeat, useProgress) from the
  frame; the driver runs it after the consumption fold and writes the new
  values back to the frame. Header quotes all 22 exact exprs, each on ONE
  comment line. All documented limits recorded in the pure function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11383/1637/1558/2907**
  (+3/+1/+1/+2 from baseline 11380/1636/1557/2905 — the +3 symbols are
  advanced/charge_ready/use_ready); audit 1335 unchanged; ledger N2194 status
  done. **Defense shard changed** (OverdriveProjector.java lives under
  `/world/blocks/defense/`, the N2157 precedent): defense_slices 154→155,
  defense_api_contracts 153→154.
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 22/22,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- **Coordinator fix `3e15681f`:** the worker's advance runs even when disabled
  (correct gate — Java runs updateTile while disabled) but reads a stale
  efficiency, because the driver never zeroes efficiency when disabled. The
  fix documents the deviation in the file comment and adds the
  disabled-early-return deferral to the register (deferred 244). Targeted
  re-run after the fix: still 3/4 + Godot-absent.

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

- Slice: `32fdf11c` — C07: N2194 OverdriveProjector updateTile advance, 5 files (+885/−13),
  on `slice/N2194-overdrive-projector-update-tile`.
- SSOT: `1722b6b4` — C07: N2194 SSOT registration (11383/1637/1558/2907), 6 files (+569).
- Coordinator fix: `3e15681f` — C07: N2194 coordinator fix (document disabled-stale-efficiency deviation; add disabled-early-return deferral).
- Integration: slice cherry-pick `2723e795` + fix cherry-pick `447c0bc3` on
  `integration/batch-n2193-n2194-n2195-n2196`; batch SSOT `76a87003` (combined
  11391/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2193/N2194/N2195 (+N2196 note).
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- Boost application (the actual overdrive boost to nearby buildings) +
  consume() + draw — each its own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957): the
  advance runs while disabled (correct gate) but reads the stale efficiency.
  Documented deviation + DEFERRED entry; the driver-wide fix is its own slice.
- Standardizing the pure-function efficiency default (1.0 here vs 0.0 in
  N2193/N2195) — a later consistency slice, not this one.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07OverdriveProjectorUpdateTileProof`, commit carrying the scene `32fdf11c`, 9 keys
  (`smooth_efficiency_heat_lerp_toward_efficiency`, `charge_advances_and_resets_at_reload`,
  `phase_heat_lerps_when_has_boost`, `phase_heat_frozen_without_boost`,
  `use_progress_advances_and_wraps`, `live_tick_advances_frame_and_preserves_power`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_overdrive_projector_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: N2195 (BeamDrill updateTile) + N2196 conduit fix (same batch), then
  N2197 link infra (see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`) → N2188 ItemBridge gate retry.
