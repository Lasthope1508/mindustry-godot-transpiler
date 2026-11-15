# Handoff — N2215 BuildTurret shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2215-build-turret-should-consume`, base
`599b7573` (wave-targets docs tip). Integrated on `integration/wave-plans-n2215-n2216`
(cherry-pick `ff6e85c9`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 4a873633, merged SSOT 3977a45d; NOT merged into
main; slice branch pushed 15:11, integration branch pushed immediately
after the docs commit).**

Done by worker-N2215 (slice, done 15:11 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 ~15:10 +07, SCOPE-plans-wave.md + brief-n2215.md)

- `BuildTurretBuild.shouldConsume()` (BuildTurret.java:229-231): `return
  unit.plans().size > 0 && !isHealSuppressed();` — TWO conditions, NO
  `&& enabled`. `unit` is `public BlockUnitc unit =
  (BlockUnitc)unitType.create(team);` (:93); plan search / follow / mimic /
  validate at :156-225.
- `isHealSuppressed()` (BuildingComp.java:487-489): `return
  block.suppressable && Time.time <= healSuppressionTime;`, set via
  `applyHealSuppression` (:482-485). BuildTurret has `suppressable = true`
  (:46), so the term is live. `checkSuppression()` at updateTile
  (:132-133) is a DIFFERENT gate — out of this slice.
- Def: build-tower only (size 3, range 200f, buildSpeed 1.5f, consumePower
  3f, nitrogen 3f/60f, Blocks.java:1997-2006). Nitrogen is a second
  consumer — NOT this slice.
- Port: `SourceBuildTurretBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame keys `plans` + `heal_suppressed` + pure gate +
  driver wiring. The port has no live build-plan or suppression store on
  placed buildings; live fill is deferred to the updateTile advance slice
  (the Separator N2200 / payload N2208 precedent).
- SSOT baseline re-verified from the generated JSONs (base `599b7573`):
  symbols 11427 + slices 1655 + contracts 1578 + schemas 2947; audit
  `totalSourceFunctions` 1336. Expected after N2215 (single-slice):
  **11429/1656/1579/2949** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_build_turret_should_consume_state(frame)` →
  `{should_consume, plan_count}` (the N2201 precedent: the second result
  symbol is the value the gate reads; `heal_suppressed` is read
  internally, NOT a result symbol — the N2212 `enabled` precedent).
- Frame keys `plans` ([] default) + `heal_suppressed` (false default).
  The driver reads the gate through the pure function; the machinery folds
  efficiency to 0 when the gate is false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07BuildTurretShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 15:11 +07, worker-N2215)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_build_turret_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_build_turret_should_consume.py`.
- Register script verified standalone: **exit 0**. **19 exact exprs, 0 missing**;
  DEFERRED 257 entries. OWNER
  `SourceBuildTurretBuildState.source_build_turret_should_consume_state`, PROOF
  `/root/C07BuildTurretShouldConsumeProof`.
- Targeted RED run: failures=2, errors=2 — `KeyError: 'N2215'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). Pre-register after GREEN: failures=1, errors=2.
  No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 15:11 +07, worker-N2215)

- Pure gate + driver wiring + frame keys `plans` + `heal_suppressed`
  (5 files, +817/−9); proof scene (6 keys); all 19 exact exprs present,
  each on ONE comment line. The limit comment in the BuildTurret power row
  now says the gate is LIVE.
- SSOT at GREEN (single-slice): **11429/1656/1579/2949**, audit 1336,
  legacy 0. Defense shard CHANGED (defense_api_contracts +
  defense_slices). `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  19/19, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean. Neighbour check: N2184 power-status tests still 3/4.

## Neighbours (DONE 2026-11-15 ~15:12 +07, coordinator, main thread — wave-level)

- Build/constructor family power_status (8 tests): 6 PASS + 2 Godot-absent,
  0 other failures. Targeted 2 wave modules (8 tests): 6 PASS + 2 proof
  tests Godot-absent. No regression.
- Coordinator fix `c36f1cb7` at integration (by design, not a regression):
  seed a plans fixture into the N2184 power proof — the turret there has
  no plans, so its `efficiency_folds_power_min` key would read 0 on Godot
  now that the gate closes on an empty frame (the 481315f8 / 53ed2029 /
  5779a6c4 precedent). Same fix for the N2161 power proof in the same
  commit. Verified the ticks do not reset the new frame keys.

## Exact exprs (19, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_build_turret_should_consume.py` EXACT_EXPRS (19 entries,
including `return unit.plans().size > 0 && !isHealSuppressed();`, the unit
field, `suppressable = true`, `isHealSuppressed()`,
`applyHealSuppression`, BuildingComp 1960/1992, and the build-tower def
lines).

## Next

- Units → updateTile advances → second consumers (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice; the N2160
  driver cite-cleanup slice (pin-drift cites listed in the N2214 report).
- Godot proof debt: `C07BuildTurretShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `4a873633` — C07: N2215 BuildTurret shouldConsume gate, 5 files (+817/−9).
  Cherry-pick `ff6e85c9` on `integration/wave-plans-n2215-n2216`.
- Coordinator fix: `c36f1cb7` — seed plans/recipe fixtures in the
  N2184/N2161 power proofs.
- SSOT: merged `3977a45d` — wave-level SSOT (11431/1657/1580/2951), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2215–N2216.

## Gate (DONE 2026-11-15, log `full-suite-wave-plans-gate.log`)

Full gate run 1 (PID 19171, launch 15:12 by coordinator lượt 4) KILLED by VM restart 3 ~15:22;
run 2 (PID 1756, relaunch 15:22, done 15:38 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-plans-gate.log`, untracked): Ran 5921 in 959.898s,
failures=157, skipped=5, 0 errors — 157/157 verified Godot-absent (155 inherited + 2 new proof tests
N2215–N2216, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression. No commits/files lost in the restart (javalang reinstalled 0.13.0).
