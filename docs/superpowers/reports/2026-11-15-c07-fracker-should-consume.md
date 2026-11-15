# Report — N2207: Fracker shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2207-fracker-should-consume`, base
`22b410fb` (wave-items docs tip). Integrated on `integration/wave-liquids-n2205-n2207`
(cherry-pick `8bb5f81e`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 13:55 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2207 (slice, done 13:50 +07); integrated and documented by
coordinator lượt 4. Slice commit `5342006a`; merged SSOT `a47139dc`
(wave-level, 11413/1648/1571/2933).

## What changed

The Fracker power.status slice (N2153) folded power only and deferred the
shouldConsume gate ("result liquid amount is not tracked on the live
frame"). N2207 wires the gate over the liquids frame state (the
DESIGN-frame-state-infra.md liquids pattern: the liquids store already
exists as sprite meta `source_building_liquids`; amount read via
`SourceLiquidModuleState.source_get_state`):

- **Pure gate** `source_fracker_should_consume_state(frame, result_liquid,
  liquid_capacity)` in `SourceFrackerBuildState.gd` — the gate is INHERITED
  verbatim from SolidPump: `Fracker extends SolidPump` (Fracker.java:7),
  `FrackerBuild extends SolidPumpBuild` (:26), and grep finds NO
  shouldConsume override in Fracker.java (0 matches), so the gate is
  SolidPump.java:117-119: `return liquids.get(result) < liquidCapacity -
  0.01f;` — NO `&& enabled`, NO liquidDrop. Returns
  `{"should_consume", "result_amount"}`. (Note: older cites — the N2153
  driver, DEFERRED — say SolidPump.java:113-115; at this upstream pin the
  override is at 117-119, verified by grep; this slice cites 117-119.)
- **result + liquidCapacity def constants** (the catalog has NEITHER for
  the oil-extractor def — the N2190/N2199 precedent): result = oil
  (Blocks.java:2966; the class default is water, SolidPump.java:22),
  liquidCapacity = 40f (Blocks.java:2971).
- **Frame key `liquids`**: `_initial_frame()` now returns
  `{"liquids": {}}`; the driver syncs `frame["liquids"]` every tick from
  the sprite meta; `result_liquid` is a catalog id resolved by the driver
  via `liquid_id_by_name` (the factory precedent). A missing store or id
  −1 reads amount 0.0, matching Java `liquids.get`.
- The second consumers (sand + water, Blocks.java:2976-2978) are NOT part
  of this slice.
- The power.row limit comment now says the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_fracker_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_fracker_should_consume.py`
written by worker-N2207. Register script: EXACT_EXPRS = the 15 verified
exprs (all 15 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 250 entries (the Fracker gate entry resolved; NO new
deferral — the updateTile advance, the sand/water rows, and the attribute
rows were already deferred).

RED run: the expected no-Godot pattern — registration + exact-evidence fail
`KeyError: 'N2207'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`).

## GREEN

- Pure gate + driver wiring in `SourceFrackerBuildState.gd`; frame key
  `liquids`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07FrackerShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_below_capacity, gate_false_at_capacity, gate_ignores_enabled,
  efficiency_zero_when_gate_false, efficiency_folds_power_when_gate_true,
  def_constant_oil_capacity_forty. The def-constant key checks both faces:
  a store full of water but empty of oil still gates true (it reads the
  oil result, not the store total), and oil at 39.99 == capacity − 0.01f
  already gates false (the epsilon; verified `40.0 - 0.01 == 39.99` in
  double). Proof `.json` is gitignored (never stage, per AGENTS.md rule on
  proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11409/1646/1569/2929**
  from the wave-items base 11407/1645/1568/2927; audit totalSourceFunctions
  1336, legacy 0. **Production shard CHANGED** (4 `production_*` files —
  api_contracts 47→48, slices 53→54, state_schema 49→50, symbols 458→460;
  the N2201 note: production shards mirror this family). New symbols carry
  java_source `SolidPump.java` (the N2198 precedent: an inherited gate
  cites the parent class/method).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 15/15,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Pump family (20 tests): 15 PASS + 5 Godot-absent (the power_status proofs
of mechanical pump / solid pump / fracker + the liquid-bridge power_status
and shouldConsume proofs), 0 other failures. Targeted 3 wave modules
(12 tests): 9 PASS + 3 proof tests Godot-absent. No regression. (The first
targeted run showed 9 FileNotFoundError — the integration worktree had no
`mindustry-upstream` copy for the exact-evidence tests to read; copied the
upstream checkouts from the wave-items integration worktree, the same
layout the slice worktrees use, and the run then passed 9/12.)

## Gate

Full gate (PID 6624, launch 13:52 by coordinator lượt 4, done 14:09 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-liquids-gate.log`, untracked): Ran 5885 in 1005.870s,
failures=148, skipped=5, 0 errors — 148/148 verified Godot-absent (145 inherited + 3 new proof tests
N2205–N2207, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.

## Commits

- Slice: `5342006a` — C07: N2207 Fracker shouldConsume gate, 5 files
  (+596/−16), on `slice/N2207-fracker-should-consume` (base `22b410fb`).
  Cherry-pick `8bb5f81e` on `integration/wave-liquids-n2205-n2207`.
- SSOT: merged `a47139dc` — wave-level SSOT (11413/1648/1571/2933), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2205–N2207.
- NOT merged into main. Slice branch pushed 13:55, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- The Fracker updateTile advance (attribute rows, sand/water second
  consumers) — already deferred, own slices.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07FrackerShouldConsumeProof`, commit carrying the scene `5342006a`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_fracker_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: payload infra (coordinator serial — scope the port payload store
  first, then the PayloadLoader / PayloadUnloader / PayloadDeconstructor /
  UnitCargoLoader gates; see `SCOPE-payload-wave.md`) → targets → plans →
  units (see `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
