# Report — N2214: RegenProjector shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2214-regen-projector-should-consume`, base
`c3718d04` (wave-payload docs tip). Integrated on `integration/wave-targets-n2212-n2214`
(cherry-pick `49fbcec3`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 14:46 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2214 (slice, done 14:44 +07); integrated and documented by
coordinator lượt 4. Slice commit `71e4e8ab`; merged SSOT `89e79132`
(wave-level, 11427/1655/1578/2947).

## What changed

The RegenProjector power.status slice (N2160) folded power only and deferred
the shouldConsume gate ("the targets computation is not tracked yet").
N2214 wires the gate over a new frame key (the DESIGN-frame-state-infra.md
targets pattern — the Separator N2200 / payload N2208 precedent: frame key
added, live fill deferred; the port has no live target store on placed
buildings):

- **Pure gate** `source_regen_projector_should_consume_state(frame)` in
  `SourceRegenProjectorBuildState.gd` — mirrors
  RegenProjectorBuild.shouldConsume() (RegenProjector.java:**181-183**):
  `return anyTargets;` — this gate has NO `&& enabled`, mirrored exactly
  (the pure gate does NOT read `frame["enabled"]`). Returns
  `{"should_consume", "any_targets"}` (the N2201 precedent: the second
  result symbol is the value the gate reads).
- **Frame key `any_targets`** (default false — the Java field is `public
  boolean anyTargets = false;`, RegenProjector.java:112, recomputed each
  tick from `targets` (`Seq<Building>` :109) via `indexer.eachBlock(...)`
  (:116-118) then `anyTargets = targets.contains(b -> b.damaged())`
  (:139)). The gate reads `anyTargets` only, so the slice does NOT add a
  `targets` key; the targets computation waits for the updateTile advance
  slice.
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994).
- The power.row limit comment now says the gate is LIVE.
- **Cite fix (part of this slice):** the N2160 driver comment cited the gate
  at "RegenProjector.java:206-208" — WRONG at this pin (verified by grep:
  the file has exactly one shouldConsume, at :181-183). All cites this
  slice rewrote use 181-183; grep confirms no 206-208/:207 cite remains in
  the driver text this slice touched. Other pin-drift cites in the N2160
  driver (class :29→:20, heal gate :142→:141, healAmount :148→:147,
  healPercent Blocks :2018→:2019, range :2011→:2012, updateTile :123→:122,
  checkSuppression :137→:135, suppressable :49→:46, hasPower :45→:43) are
  OUT of scope — left untouched, recorded for a cite-cleanup slice.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_regen_projector_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_regen_projector_should_consume.py`
written by worker-N2214. Register script: EXACT_EXPRS = the 15 verified
exprs (all 15 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the RegenProjector gate entry resolved; 1 new
deferral added: RegenProjector targets computation live fill via indexer query).

RED run: failures=2, errors=2 (registration + exact-evidence fail
`KeyError: 'N2214'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`); pre-register after GREEN: failures=1, errors=2 —
the expected KeyError pattern).

## GREEN

- Pure gate + driver wiring in `SourceRegenProjectorBuildState.gd`; frame key
  `any_targets`; the limit comment updated. Header quotes the exact exprs, each
  Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07RegenProjectorShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_any_targets, gate_false_when_no_targets,
  gate_independent_of_enabled, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true, frame_any_targets_default_false. The proof
  injects `any_targets` true/false directly (the gate reads the bool only).
  Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11423/1653/1576/2943**
  from the wave-payload base 11421/1652/1575/2941; audit totalSourceFunctions
  1336, legacy 0. **Defense shard CHANGED** (`defense_api_contracts` +
  `defense_slices` — java_source under `/world/blocks/defense/` matches the
  selection rule).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 15/15,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Repair/regen family power_status (16 tests: RepairTurret N2174, RepairTower
N2176, RegenProjector N2160, MendProjector N2193): 12 PASS + 4 Godot-absent
(the 4 power_status proofs), 0 other failures. Targeted 3 wave modules
(12 tests): 9 PASS + 3 proof tests Godot-absent. No regression.

## Gate

Full gate (PID 15436, launch 14:47 by coordinator lượt 4, done 15:05 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-targets-gate.log`, untracked): Ran 5913 in 1040.657s,
failures=155, skipped=5, 0 errors — 155/155 verified Godot-absent (152 inherited + 3 new proof tests
N2212–N2214, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.

## Commits

- Slice: `71e4e8ab` — C07: N2214 RegenProjector shouldConsume gate, 5 files
  (+1000/−17), on `slice/N2214-regen-projector-should-consume` (base `c3718d04`).
  Cherry-pick `49fbcec3` on `integration/wave-targets-n2212-n2214`.
- Coordinator fix `5779a6c4` at integration (by design, not a regression):
  seed `any_targets = true` into the N2160 power proof — the projector there
  has no targets, so its `efficiency_folds_power_min` key would read 0 on
  Godot now that the gate closes on an empty frame (the 481315f8 / 53ed2029
  precedent). Same fix applied to the N2174 + N2176 power proofs in the
  same commit. Verified the ticks do not reset the new frame keys.
- SSOT: merged `89e79132` — wave-level SSOT (11427/1655/1578/2947), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2212–N2214.
- NOT merged into main. Slice branch pushed 14:46, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Targets computation: frame `any_targets` is never computed on the live path
  yet — the indexer query (:116-118) + `contains(damaged)` (:139) belong to
  the RegenProjector updateTile advance, own slice.
- The hydrogen liquid consumer (1f/60f, Blocks.java:2016) and the optional
  phaseFabric item booster (:2017) — second consumers, own slices.
- The suppression gate (checkSuppression, RegenProjector.java:135) —
  deferred (needs suppression state the tick does not track yet).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- N2160 driver cite pin-drift (see Cite fix above) — a cite-cleanup slice.
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07RegenProjectorShouldConsumeProof`, commit carrying the scene `71e4e8ab`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_regen_projector_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: plans (BuildTurret gate — see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`) → units → updateTile advances.
