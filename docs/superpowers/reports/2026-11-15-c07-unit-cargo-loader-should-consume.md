# Report — N2211: UnitCargoLoader shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2211-unit-cargo-loader-should-consume`, base
`0fb61ffc` (wave-liquids docs tip). Integrated on `integration/wave-payload-n2208-n2211`
(cherry-pick `5a9805f5`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 14:18 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2211 (slice, done 14:18 +07); integrated and documented by
coordinator lượt 4. Slice commit `1ee8ae0e`; merged SSOT `231be5f1`
(wave-level, 11421/1652/1575/2941).

## What changed

The UnitCargoLoader power.status slice (N2165) folded power only and deferred
the shouldConsume gate ("unit state is not tracked yet"). N2211 wires the
gate over a new frame key (the DESIGN-frame-state-infra.md payload pattern —
the Separator N2200 precedent: frame key added, live fill deferred; the port
has no unit store / readUnitId state on building frames):

- **Pure gate** `source_unit_cargo_loader_should_consume_state(frame)` in
  `SourceUnitCargoLoaderBuildState.gd` — mirrors
  UnitTransportSourceBuild.shouldConsume() (UnitCargoLoader.java:141-143):
  `return unit == null;` — this gate is INVERTED: the loader consumes while
  it has NO unit (it is building one) and stops once a unit is waiting.
  Returns `{"should_consume", "has_unit"}` (the N2201 precedent: the second
  result symbol is the value the gate reads).
- **Frame key `unit`** (default null — the Java field is nullable,
  `public @Nullable Unit unit;`, UnitCargoLoader.java:89, on
  `UnitTransportSourceBuild extends Building implements UnitTetherBlock`,
  :84). The gate reads only null-ness; no live fill sets the key yet (unit
  spawn / readUnitId waits for the updateTile advance slice).
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994).
- The liquid nitrogen consumer row (consumeLiquid nitrogen 10f/60f,
  Blocks.java:2279) is a second consumer and is NOT part of this slice.
- The power.row limit comment now says the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_unit_cargo_loader_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_unit_cargo_loader_should_consume.py`
written by worker-N2211. Register script: EXACT_EXPRS = the 13 verified
exprs (all 13 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the UnitCargoLoader gate entry resolved; 1 new
deferral added: UnitCargoLoader live unit fill via unit spawn / readUnitId).

RED run: the expected no-Godot pattern — registration + exact-evidence fail
`KeyError: 'N2211'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`).

## GREEN

- Pure gate + driver wiring in `SourceUnitCargoLoaderBuildState.gd`; frame key
  `unit`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_unit_null, gate_false_when_unit_present,
  gate_independent_of_enabled, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true, frame_unit_default_null. The
  `gate_false_when_unit_present` key is the INVERTED distinguisher (opposite
  of the Loader/Unloader/Deconstructor gates). The proof injects a minimal
  Dictionary fixture `{"type": "dart"}` as the unit (only null-ness is read
  — stated in the proof; no real Unit is built). Proof `.json` is gitignored
  (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11415/1649/1572/2935**
  from the wave-liquids base 11413/1648/1571/2933; audit totalSourceFunctions
  1336, legacy 0. **NO shard changed** (only the 4 canonical JSONs — the
  unit-cargo-loader family has no distribution shard).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 13/13,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Payload family power_status (20 tests): 15 PASS + 5 Godot-absent (the
power_status proofs of loader / unloader / deconstructor / cargo loader /
mass driver), 0 other failures. Targeted 4 wave modules (16 tests): 12 PASS
+ 4 proof tests Godot-absent. No regression. Note: the N2165 power proof
needed NO coordinator fix — the inverted gate means a unit-less loader
consumes exactly as before, so its `efficiency_folds_power_min` key still
holds.

## Gate

Full gate (PID 11414, launch 14:20 by coordinator lượt 4, done 14:38 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-payload-gate.log`, untracked): Ran 5901 in 1003.626s,
failures=152, skipped=5, 0 errors — 152/152 verified Godot-absent (148 inherited + 4 new proof tests
N2208–N2211, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.

## Commits

- Slice: `1ee8ae0e` — C07: N2211 UnitCargoLoader shouldConsume gate, 5 files
  (+746/−7), on `slice/N2211-unit-cargo-loader-should-consume` (base `0fb61ffc`).
  Cherry-pick `5a9805f5` on `integration/wave-payload-n2208-n2211`.
- Coordinator fix `53ed2029` at integration (by design, not a regression):
  seed payload/deconstructing fixtures into the N2162/N2163/N2166 power
  proofs (the 481315f8 precedent from wave items). The N2165 proof needed
  no fix (see Neighbours).
- SSOT: merged `231be5f1` — wave-level SSOT (11421/1652/1575/2941), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2208–N2211.
- NOT merged into main. Slice branch pushed 14:18, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live unit fill: frame `unit` is never filled on the live path yet — unit
  spawn / readUnitId belongs to the UnitCargoLoader updateTile advance, own
  slice.
- The liquid nitrogen consumer row, the updateTile advance (unit
  lost/destroyed / warmup / readyness / buildProgress / totalProgress),
  unit spawn rows, canPlaceOn, bars, draw, read/write — deferred
  (documented in the driver limits).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07UnitCargoLoaderShouldConsumeProof`, commit carrying the scene `1ee8ae0e`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_unit_cargo_loader_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: targets (RepairTurret/RepairTower/RegenProjector gates — see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) →
  plans → units.
