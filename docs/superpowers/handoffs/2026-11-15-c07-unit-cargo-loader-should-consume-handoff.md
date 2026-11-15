# Handoff — N2211 UnitCargoLoader shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2211-unit-cargo-loader-should-consume`, base
`0fb61ffc` (wave-liquids docs tip). Integrated on `integration/wave-payload-n2208-n2211`
(cherry-pick `5a9805f5`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 1ee8ae0e, merged SSOT 231be5f1; NOT merged into
main; slice branch pushed 14:18, integration branch pushed immediately
after the docs commit).**

Done by worker-N2211 (slice, done 14:18 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 14:1x +07, SCOPE-payload-wave.md + brief-n2211-unit-cargo-loader.md)

- `UnitTransportSourceBuild.shouldConsume()` (UnitCargoLoader.java:141-143,
  file at `world/blocks/units/UnitCargoLoader.java`): `return unit == null;`
  — INVERTED: consumes while it has NO unit (building one), stops once a
  unit waits. Override on `UnitTransportSourceBuild extends Building
  implements UnitTetherBlock` (:84); field `unit` (`public @Nullable Unit
  unit;`, :89).
- Def: unit-cargo-loader only (consumePower 8f/60f, consumeLiquid nitrogen
  10f/60f, size 3, itemCapacity 200, unitBuildTime 60f*8f,
  Blocks.java:2270-2282). The nitrogen row is a second consumer — NOT this
  slice.
- Port: `SourceUnitCargoLoaderBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame key `unit` + pure gate + driver wiring. The port has
  no unit store / readUnitId state on building frames; live fill deferred
  to the updateTile advance slice.
- SSOT baseline re-verified from the generated JSONs (base `0fb61ffc`):
  symbols 11413 + slices 1648 + contracts 1571 + schemas 2933; audit
  `totalSourceFunctions` 1336. Expected after N2211 (single-slice):
  **11415/1649/1572/2935** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_unit_cargo_loader_should_consume_state(frame)` →
  `{should_consume, has_unit}` (the N2201 precedent: the second result
  symbol is the value the gate reads).
- Frame key `unit` only (null default). The driver reads the gate through
  the pure function; the machinery folds efficiency to 0 when the gate is
  false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07UnitCargoLoaderShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 14:18 +07, worker-N2211)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_unit_cargo_loader_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_unit_cargo_loader_should_consume.py`.
- Register script verified standalone: **exit 0**. **13 exact exprs, 0 missing**;
  DEFERRED 257 entries. OWNER
  `SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_should_consume_state`, PROOF
  `/root/C07UnitCargoLoaderShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2211'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 14:18 +07, worker-N2211)

- Pure gate + driver wiring + frame key `unit` (5 files, +746/−7);
  proof scene (6 keys); all 13 exact exprs present, each on ONE comment
  line. The limit comment in the UnitCargoLoader power row now says the gate
  is LIVE.
- SSOT at GREEN (single-slice): **11415/1649/1572/2935**, audit 1336,
  legacy 0. NO shard changed (only the 4 canonical JSONs — the
  unit-cargo-loader family has no distribution shard). `git diff --check`
  clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  13/13, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean.

## Neighbours (DONE 2026-11-15 ~14:20 +07, coordinator, main thread — wave-level)

- Payload family power_status (20 tests): 15 PASS + 5 Godot-absent, 0 other
  failures. Targeted 4 wave modules (16 tests): 12 PASS + 4 proof tests
  Godot-absent. No regression. Note: the N2165 power proof needed NO
  coordinator fix — the inverted gate means a unit-less loader consumes
  exactly as before, so its `efficiency_folds_power_min` key still holds.
- Coordinator fix `53ed2029` at integration (by design, not a regression):
  seed payload/deconstructing fixtures into the N2162/N2163/N2166 power
  proofs (the 481315f8 precedent from wave items).

## Exact exprs (13, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_unit_cargo_loader_should_consume.py` EXACT_EXPRS (13 entries,
including `return unit == null;`, the UnitTransportSourceBuild class + field
lines, and the Blocks.java def lines).

## Next

- Targets (RepairTurret/RepairTower/RegenProjector gates — see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) →
  plans → units.
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07UnitCargoLoaderShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `1ee8ae0e` — C07: N2211 UnitCargoLoader shouldConsume gate, 5 files (+746/−7).
  Cherry-pick `5a9805f5` on `integration/wave-payload-n2208-n2211`.
- Coordinator fix: `53ed2029` — seed payload/deconstructing fixtures in the
  N2162/N2163/N2166 power proofs.
- SSOT: merged `231be5f1` — wave-level SSOT (11421/1652/1575/2941), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2208–N2211.

## Gate (DONE 2026-11-15, log `full-suite-wave-payload-gate.log`)

Full gate (PID 11414, launch 14:20 by coordinator lượt 4, done 14:38 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-payload-gate.log`, untracked): Ran 5901 in 1003.626s,
failures=152, skipped=5, 0 errors — 152/152 verified Godot-absent (148 inherited + 4 new proof tests
N2208–N2211, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.
