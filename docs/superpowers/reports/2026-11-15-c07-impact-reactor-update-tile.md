# Report — N2192: ImpactReactor updateTile advance (C07)

Date: 2026-11-15. Batch: N2190 + N2191 + N2192 (integration branch
`integration/batch-n2190-n2191-n2192`). Status: **DONE (code + SSOT + neighbours +
gate clean except Godot; NOT pushed, NOT merged — local branches only, per user order).**

Worker: worker-N2192 (parallel wave 1, coordinator-verified). Slice commit `da0b5abd`
on `slice/N2192-impact-reactor-update-tile`; SSOT commit `305a0198`; coordinator
fix `d280e2e9` (correct enabled-gate claim + disabled-early-return deferral — see
GREEN). Integration cherry-picks: slice `52e3b178`, fix `a646945c`.

## What changed

N2182 wired the impact reactor's live power.status read: the pure power row
folds the stamped frame value into the min efficiency, so the warmup gate
(ImpactReactor.java:79, `if(efficiency >= 0.9999f && power.status >= 0.99f){`)
follows it — but the port still never advanced the warmup itself: no frame key
tracked warmup / totalProgress / productionEfficiency, so the reactor could
never warm up to `productionEfficiency = Mathf.pow(warmup, 5f);`
(ImpactReactor.java:100), and `warmup()` / `totalProgress()` / `ambientVolume()` /
`sense(LAccess.heat)` (ImpactReactor.java:104-121) all read a warmup that never
moved. N2192 is the updateTile advance: a pure advance over the folded
efficiency and the stamped power.status, run by the driver AFTER the consumption
fold (BuildingComp.update(), BuildingComp.java:2274 `updateConsumption();` then
:2277 `updateTile();`).

The warmup lerps toward 1 at warmupSpeed × timeScale (ImpactReactor.java:82,
warmupSpeed 0.001f class default, ImpactReactor.java:19, NOT overridden by the
single impact-reactor def, Blocks.java:2632-2645), snaps to 1f when
Mathf.equal(warmup, 1f, 0.001f) (ImpactReactor.java:83-84), decays toward 0 at
0.01f when the gate fails (ImpactReactor.java:95), totalProgress accumulates
warmup × Time.delta (ImpactReactor.java:98, Time.delta is seconds × 60, arc
Time.java:26, the N2093 pump precedent), and productionEfficiency is
pow(warmup, 5f) (ImpactReactor.java:100). Mathf.equal is inlined as
absf(warmup − 1.0) <= 0.001 because the port has no Mathf.equal helper
(Mathf.java:554-555); Mathf.pow is Godot pow() (Mathf.java:212-213).
timeScale is the sprite-meta timeScale (BuildingComp.java:98, default 1f),
read through the UnitFactory precedent.

**Documented deviation — the enabled gate:** the worker first claimed the
advance freezes when disabled; that is wrong. Java runs updateTile even when
disabled (the gate `if(enabled || !block.noUpdateDisabled){` passes because
noUpdateDisabled defaults false, Block.java:170). The port driver still gates
the advance on enabled, because the frame efficiency is never zeroed when
disabled (the driver-wide disabled early return is missing — see Deferred),
so an ungated advance would warm up on stale efficiency. The gate is a
documented deviation, pending the driver-wide fix; the coordinator fix
`d280e2e9` corrected the claim and added the deferral.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_impact_reactor_update_tile.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_impact_reactor_update_tile.py`
written by worker-N2192. Register script: EXACT_EXPRS = the 35 verified exprs
(all 35 unique, all present verbatim in upstream — script check, 0 missing),
DEFERRED 244 entries (copy forward from N2185, minus the resolved entries,
plus new deferrals including the disabled-early-return deferral).

RED run: registration + exact-evidence fail with `KeyError: 'N2192'` (slice not
registered yet) and the row-state test fails on the missing function; the proof
test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`) — the expected no-Godot pattern on this VM.

## GREEN

- Pure advance in `godot-mindustry/src/game/SourceImpactReactorBuildState.gd`:
  `source_impact_reactor_update_tile_advance_state` returns the 3 advanced
  values (warmup, totalProgress, productionEfficiency) from the frame; the
  driver runs it after the consumption fold and writes the new values back to
  the frame. Header quotes all 35 exact exprs, each on ONE comment line. All
  documented limits recorded in the pure function's comment.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ImpactReactorUpdateTileProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run by the coordinator at integration: SSOT **11383/1637/1558/2907**
  (+3/+1/+1/+2 from baseline 11380/1636/1557/2905 — the +3 symbols are the 3
  return values); audit 1335 unchanged; ledger N2192 status done.
  **Power shard changed** (ImpactReactor.java lives under
  `/world/blocks/power/`, the N2182 precedent): power_slices 111→112,
  power_api_contracts 90→91.
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 35/35,
  row-state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.
- **Coordinator fix `d280e2e9`:** the worker's comment claimed the advance
  freezes when disabled (wrong gate reading — see What changed). Fixed the
  comment to state the Java gate correctly and added the disabled-early-return
  deferral to the register (deferred 244). Targeted re-run after the fix:
  still 3/4 + Godot-absent. The driver keeps the enabled gate as a documented
  deviation until the driver-wide fix lands.

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

- Slice: `da0b5abd` — C07: N2192 ImpactReactor updateTile advance, 5 files (+592/−2),
  on `slice/N2192-impact-reactor-update-tile`.
- SSOT: `305a0198` — C07: N2192 SSOT registration (11383/1637/1558/2907), 6 files (+522).
- Coordinator fix: `d280e2e9` — C07: N2192 coordinator fix (correct updateTile enabled-gate claim; add disabled-early-return deferral).
- Integration: slice cherry-pick `52e3b178` + fix cherry-pick `a646945c` on
  `integration/batch-n2190-n2191-n2192`; batch SSOT `68fc759c` (combined
  11390/1639/1560/2911).
- Docs: (this commit) — report + handoff + spec + GOAL for N2190/N2191/N2192.
- NOT pushed, NOT merged into main — local branches only; main agent merges after
  user approval.

## Deferred (NOT this slice)

- The first-production event (ImpactReactor.java:87-88,
  `Events.fire(Trigger.impactPower);` — needs getPowerProduction() and
  consPower.requestedPower(this) from the power graph, which the port does not
  model yet) and the consume timer (ImpactReactor.java:91-92,
  `if(timer(timerUse, itemDuration / timeScale)){` with `consume();` — needs
  timer + item/liquid consumption infrastructure).
- The producer fold (PowerGenerator.java:156-158, `return enabled ?
  powerProduction * productionEfficiency : 0f;`) does NOT read the new
  `production_efficiency` frame key yet: the key is tracked here and waits for
  its consumer slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) — see
  What changed; the enabled gate on the advance is a documented deviation
  until that fix lands.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07ImpactReactorUpdateTileProof`, commit carrying the scene `da0b5abd`, 9 keys
  (`warmup_rises_toward_one`, `warmup_snaps_to_one`, `warmup_decays_toward_zero`,
  `total_progress_advances`, `production_efficiency_pow_five`,
  `live_tick_keeps_power_row_and_advances`
  + `registry_valid` / `one_headquarter_per_ssot` / `matches`),
  status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_impact_reactor_update_tile` with Godot 4.6.2 on PATH, port 7777 free.
- Next: batch 3 {N2193, N2194, N2195} + N2196, then frame-state infra
  (config/link, items, liquids, payload, targets) — see the N2188 blocker in
  STATUS.md and the batch-2 handoff Next sections.
