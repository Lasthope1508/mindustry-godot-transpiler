# Report — N2215: BuildTurret shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2215-build-turret-should-consume`, base
`599b7573` (wave-targets docs tip). Integrated on `integration/wave-plans-n2215-n2216`
(cherry-pick `ff6e85c9`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 15:11 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2215 (slice, done 15:11 +07); integrated and documented by
coordinator lượt 4. Slice commit `4a873633`; merged SSOT `3977a45d`
(wave-level, 11431/1657/1580/2951).

## What changed

The BuildTurret power.status slice (N2184) folded power only and deferred
the shouldConsume gate ("on live build plans, which the port tracks on no
placed-building frame"). N2215 wires the gate over two new frame keys (the
DESIGN-frame-state-infra.md plans pattern — the Separator N2200 / payload
N2208 precedent: frame keys added, live fill deferred; the port has no live
build-plan or suppression store on placed buildings):

- **Pure gate** `source_build_turret_should_consume_state(frame)` in
  `SourceBuildTurretBuildState.gd` — mirrors
  BuildTurretBuild.shouldConsume() (BuildTurret.java:229-231): `return
  unit.plans().size > 0 && !isHealSuppressed();` — TWO conditions, and NO
  `&& enabled` term (the pure gate does NOT read `frame["enabled"]`).
  Returns `{"should_consume", "plan_count"}` (the N2201 precedent: the
  second result symbol is the value the gate reads; `heal_suppressed` is
  read internally, NOT a result symbol — the N2212 `enabled` precedent).
- **Frame key `plans`** (default [] — the builder unit's plan queue,
  `public BlockUnitc unit`, BuildTurret.java:93; plan search / follow /
  mimic / validate at :156-225). The gate reads only the size; no live
  fill sets the key yet (plan advance waits for the updateTile advance
  slice).
- **Frame key `heal_suppressed`** (default false — mirrors
  `isHealSuppressed()`: `return block.suppressable && Time.time <=
  healSuppressionTime;`, BuildingComp.java:487-489, set via
  `applyHealSuppression`, :482-485). BuildTurret has `suppressable = true`
  (BuildTurret.java:46), so the suppression term is live, not dead. The
  live computation needs game time + suppression application — deferred.
  Note: `checkSuppression()` at updateTile (:132-133, zeroes efficiency +
  potentialEfficiency) is a DIFFERENT gate — out of this slice (driver
  limit (5)).
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994).
- The power.row limit comment now says the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_build_turret_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_build_turret_should_consume.py`
written by worker-N2215. Register script: EXACT_EXPRS = the 19 verified
exprs (all 19 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the BuildTurret gate entry resolved; 1 new
deferral added: BuildTurret live plans / suppression fill).

RED run: failures=2, errors=2 (registration + exact-evidence fail
`KeyError: 'N2215'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`); pre-register after GREEN: failures=1, errors=2 —
the expected KeyError pattern).

## GREEN

- Pure gate + driver wiring in `SourceBuildTurretBuildState.gd`; frame keys
  `plans` + `heal_suppressed`; the limit comment updated. Header quotes the
  exact exprs, each Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07BuildTurretShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_plans_nonempty, gate_false_when_plans_empty,
  gate_false_when_heal_suppressed, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true, frame_plans_default_empty. The proof
  injects a minimal plans fixture `[{"block": "conveyor", "x": 0, "y": 0}]`
  (only the size is read — stated in the proof; no real BlockPlan is built)
  and flips `heal_suppressed` true/false directly.
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11429/1656/1579/2949**
  from the wave-targets base 11427/1655/1578/2947; audit totalSourceFunctions
  1336, legacy 0. **Defense shard CHANGED** (`defense_api_contracts` +
  `defense_slices` — BuildTurret.java lives under `/world/blocks/defense/`).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 19/19,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Build/constructor family power_status (8 tests: BuildTurret N2184,
Constructor N2161): 6 PASS + 2 Godot-absent (the 2 power_status proofs),
0 other failures. Targeted 2 wave modules (8 tests): 6 PASS + 2 proof
tests Godot-absent. No regression.

## Gate

Full gate run 1 (PID 19171, launch 15:12 by coordinator lượt 4) KILLED by VM restart 3 ~15:22;
run 2 (PID 1756, relaunch 15:22, done 15:38 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-plans-gate.log`, untracked): Ran 5921 in 959.898s,
failures=157, skipped=5, 0 errors — 157/157 verified Godot-absent (155 inherited + 2 new proof tests
N2215–N2216, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression. No commits/files lost in the restart (javalang reinstalled 0.13.0).

## Commits

- Slice: `4a873633` — C07: N2215 BuildTurret shouldConsume gate, 5 files
  (+817/−9), on `slice/N2215-build-turret-should-consume` (base `599b7573`).
  Cherry-pick `ff6e85c9` on `integration/wave-plans-n2215-n2216`.
- Coordinator fix `c36f1cb7` at integration (by design, not a regression):
  seed a plans fixture into the N2184 power proof — the turret there has
  no plans, so its `efficiency_folds_power_min` key would read 0 on Godot
  now that the gate closes on an empty frame (the 481315f8 / 53ed2029 /
  5779a6c4 precedent). Same fix applied to the N2161 power proof in the
  same commit. Verified the ticks do not reset the new frame keys.
- SSOT: merged `3977a45d` — wave-level SSOT (11431/1657/1580/2951), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2215–N2216.
- NOT merged into main. Slice branch pushed 15:11, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live plans fill: frame `plans` is never filled on the live path yet —
  plan search / follow / mimic / validate (BuildTurret.java:156-225)
  belong to the BuildTurret updateTile advance, own slice.
- Live suppression fill: frame `heal_suppressed` is never computed on the
  live path yet — `applyHealSuppression` (BuildingComp.java:482-485) +
  game-time comparison belong to the suppression advance, own slice.
- The `checkSuppression()` gate (BuildTurret.java:132-133) — a different
  gate, own slice.
- The nitrogen liquid consumer (consumeLiquid nitrogen 3f/60f,
  Blocks.java:2006) — the second consumer, own slice.
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07BuildTurretShouldConsumeProof`, commit carrying the scene `4a873633`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_build_turret_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: units → updateTile advances → second consumers (see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`).
