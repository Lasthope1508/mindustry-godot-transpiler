# Handoff — N2207 Fracker shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2207-fracker-should-consume`, base
`22b410fb` (wave-items docs tip). Integrated on `integration/wave-liquids-n2205-n2207`
(cherry-pick `8bb5f81e`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 5342006a, merged SSOT a47139dc; NOT merged into
main; slice branch pushed 13:55, integration branch pushed immediately
after the docs commit).**

Done by worker-N2207 (slice, done 13:50 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 13:29 +07, SCOPE-liquids-wave.md + brief-n2207-fracker.md)

- `Fracker extends SolidPump` (Fracker.java:7), `FrackerBuild extends
  SolidPumpBuild` (:26); grep finds NO shouldConsume override in
  Fracker.java (0 matches) → the gate is inherited verbatim from
  SolidPump.java:117-119: `return liquids.get(result) < liquidCapacity -
  0.01f;` — NO `&& enabled`, NO liquidDrop. (Note: older cites — the N2153
  driver, DEFERRED — say SolidPump.java:113-115; at this upstream pin the
  override is at 117-119, verified by grep.)
- result = oil (Blocks.java:2966; the class default is water,
  SolidPump.java:22), liquidCapacity = 40f (Blocks.java:2971). The catalog
  has NEITHER for the oil-extractor def — both are def constants (the
  N2190/N2199 precedent). The second consumers (sand + water,
  Blocks.java:2976-2978) are NOT part of this slice.
- Port: `SourceFrackerBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame key `liquids` + pure gate + driver wiring (the
  driver syncs `frame["liquids"]` every tick from the sprite meta
  `source_building_liquids`; `result_liquid` is a catalog id resolved via
  `liquid_id_by_name`, the factory precedent). Amount read via
  `SourceLiquidModuleState.source_get_state` (reused, not rewritten); a
  missing store or id −1 reads 0.0, matching Java `liquids.get`.
- SSOT baseline re-verified from the generated JSONs (base `22b410fb`):
  symbols 11407 + slices 1645 + contracts 1568 + schemas 2927; audit
  `totalSourceFunctions` 1336. Expected after N2207 (single-slice):
  **11409/1646/1569/2929** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_fracker_should_consume_state(frame, result_liquid,
  liquid_capacity)` → `{should_consume, result_amount}`. New symbols carry
  java_source `SolidPump.java` (the N2198 precedent: an inherited gate
  cites the parent class/method).
- Frame key `liquids` only (Dictionary keyed by liquid catalog id). The
  driver reads the gate through the pure function; the machinery folds
  efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07FrackerShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 13:50 +07, worker-N2207)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_fracker_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_fracker_should_consume.py`.
- Register script verified standalone: **exit 0**. **15 exact exprs, 0 missing**;
  DEFERRED 250 entries. OWNER
  `SourceFrackerBuildState.source_fracker_should_consume_state`, PROOF
  `/root/C07FrackerShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2207'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 13:50 +07, worker-N2207)

- Pure gate + driver wiring + frame key `liquids` (5 files, +596/−16);
  proof scene (6 keys); all 15 exact exprs present, each on ONE comment
  line. The limit comment in the Fracker power row now says the gate is
  LIVE.
- SSOT at GREEN (single-slice): **11409/1646/1569/2929**, audit 1336,
  legacy 0. Production shard CHANGED (4 files: api_contracts 47→48,
  slices 53→54, state_schema 49→50, symbols 458→460). `git diff --check`
  clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  15/15, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean.

## Neighbours (DONE 2026-11-15 ~13:5x +07, coordinator, main thread — wave-level)

- Pump family (20 tests): 15 PASS + 5 Godot-absent, 0 other failures.
  Targeted 3 wave modules (12 tests): 9 PASS + 3 proof tests Godot-absent.
  No regression. (The first targeted run showed 9 FileNotFoundError — the
  integration worktree had no `mindustry-upstream` copy; copied the
  upstream checkouts from the wave-items integration worktree and the run
  then passed 9/12.)

## Exact exprs (15, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_fracker_should_consume.py` EXACT_EXPRS (15 entries,
including `return liquids.get(result) < liquidCapacity - 0.01f;`, the
Fracker extends lines, and the Blocks.java def lines).

## Next

- Payload infra (coordinator serial — scope the port payload store first,
  then the PayloadLoader / PayloadUnloader / PayloadDeconstructor /
  UnitCargoLoader gates; see `SCOPE-payload-wave.md`) → targets → plans →
  units (see `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07FrackerShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `5342006a` — C07: N2207 Fracker shouldConsume gate, 5 files (+596/−16).
  Cherry-pick `8bb5f81e` on `integration/wave-liquids-n2205-n2207`.
- SSOT: merged `a47139dc` — wave-level SSOT (11413/1648/1571/2933), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2205–N2207.

## Gate (DONE 2026-11-15, log `full-suite-wave-liquids-gate.log`)

Full gate (PID 6624, launch 13:52 by coordinator lượt 4, done 14:09 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-liquids-gate.log`, untracked): Ran 5885 in 1005.870s,
failures=148, skipped=5, 0 errors — 148/148 verified Godot-absent (145 inherited + 3 new proof tests
N2205–N2207, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.
