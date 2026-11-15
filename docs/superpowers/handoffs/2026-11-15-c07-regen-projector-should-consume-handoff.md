# Handoff — N2214 RegenProjector shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2214-regen-projector-should-consume`, base
`c3718d04` (wave-payload docs tip). Integrated on `integration/wave-targets-n2212-n2214`
(cherry-pick `49fbcec3`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice 71e4e8ab, merged SSOT 89e79132; NOT merged into
main; slice branch pushed 14:46, integration branch pushed immediately
after the docs commit).**

Done by worker-N2214 (slice, done 14:44 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 ~14:55 +07, SCOPE-targets-wave.md + brief-n2214.md)

- `RegenProjectorBuild.shouldConsume()` (RegenProjector.java:**181-183**):
  `return anyTargets;` — NO `&& enabled`. ⚠️ The N2160 driver comment
  cited the gate at ":206-208" — WRONG at this pin (verified by grep: the
  file has exactly one shouldConsume, at :181-183). All new cites use
  181-183. Field `public boolean anyTargets = false;` (:112), recomputed
  each tick from `targets` (`Seq<Building>` :109) via `indexer.eachBlock(
  ...)` (:116-118) then `anyTargets = targets.contains(b -> b.damaged())`
  (:139).
- Def: regen-projector only (size 3, range 28 — def override of class 14,
  consumePower 1f, hydrogen 1f/60f, phaseFabric boost, healPercent 4f/60f,
  Blocks.java:2009-2019). Hydrogen + phaseFabric are second consumers —
  NOT this slice.
- Port: `SourceRegenProjectorBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame key `any_targets` + pure gate + driver wiring. The
  gate reads `anyTargets` only, so NO `targets` key is added. The port has
  no live target store on placed buildings; the targets computation is
  deferred to the updateTile advance slice (the Separator N2200 / payload
  N2208 precedent).
- SSOT baseline re-verified from the generated JSONs (base `c3718d04`):
  symbols 11421 + slices 1652 + contracts 1575 + schemas 2941; audit
  `totalSourceFunctions` 1336. Expected after N2214 (single-slice):
  **11423/1653/1576/2943** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_regen_projector_should_consume_state(frame)` →
  `{should_consume, any_targets}` (the N2201 precedent: the second result
  symbol is the value the gate reads).
- Frame key `any_targets` only (false default). The pure gate does NOT read
  `frame["enabled"]` (the gate has no enabled term). The driver reads the
  gate through the pure function; the machinery folds efficiency to 0 when
  the gate is false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07RegenProjectorShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 14:44 +07, worker-N2214)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_regen_projector_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_regen_projector_should_consume.py`.
- Register script verified standalone: **exit 0**. **15 exact exprs, 0 missing**;
  DEFERRED 257 entries. OWNER
  `SourceRegenProjectorBuildState.source_regen_projector_should_consume_state`, PROOF
  `/root/C07RegenProjectorShouldConsumeProof`.
- Targeted RED run: failures=2, errors=2 — `KeyError: 'N2214'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). Pre-register after GREEN: failures=1, errors=2.
  No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 14:44 +07, worker-N2214)

- Pure gate + driver wiring + frame key `any_targets` (5 files, +1000/−17);
  proof scene (6 keys); all 15 exact exprs present, each on ONE comment
  line. The limit comment in the RegenProjector power row now says the gate
  is LIVE. Cite fix: 206-208/:207 cites removed from all driver text this
  slice rewrote (grep-confirmed clean).
- SSOT at GREEN (single-slice): **11423/1653/1576/2943**, audit 1336,
  legacy 0. Defense shard CHANGED (defense_api_contracts +
  defense_slices). `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  15/15, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean; cite fix verified (0 occurrences of 206-208 in the
  driver, 181-183 present).

## Neighbours (DONE 2026-11-15 ~14:50 +07, coordinator, main thread — wave-level)

- Repair/regen family power_status (16 tests): 12 PASS + 4 Godot-absent, 0
  other failures. Targeted 3 wave modules (12 tests): 9 PASS + 3 proof
  tests Godot-absent. No regression.
- Coordinator fix `5779a6c4` at integration (by design, not a regression):
  seed `any_targets = true` into the N2160 power proof — the projector
  there has no targets, so its `efficiency_folds_power_min` key would read
  0 on Godot now that the gate closes on an empty frame (the 481315f8 /
  53ed2029 precedent). Same fix for the N2174 + N2176 power proofs in the
  same commit. Verified the ticks do not reset the new frame keys.

## Exact exprs (15, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_regen_projector_should_consume.py` EXACT_EXPRS (15 entries,
including `return anyTargets;`, the field/class lines, the targets/indexer/
contains lines, BuildingComp 1960/1992, `return enabled;`, the def lines,
and the heal gate + healAmount lines).

## Next

- Plans (BuildTurret gate — see `DESIGN-frame-state-infra.md` in
  `~/workspace/mindustry-parallel/`) → units → updateTile advances.
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice; the N2160
  driver cite-cleanup slice (pin-drift cites: class :29→:20, heal gate
  :142→:141, healAmount :148→:147, healPercent Blocks :2018→:2019, range
  :2011→:2012, updateTile :123→:122, checkSuppression :137→:135,
  suppressable :49→:46, hasPower :45→:43).
- Godot proof debt: `C07RegenProjectorShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `71e4e8ab` — C07: N2214 RegenProjector shouldConsume gate, 5 files (+1000/−17).
  Cherry-pick `49fbcec3` on `integration/wave-targets-n2212-n2214`.
- Coordinator fix: `5779a6c4` — seed target/targets/any_targets fixtures in
  the N2174/N2176/N2160 power proofs.
- SSOT: merged `89e79132` — wave-level SSOT (11427/1655/1578/2947), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2212–N2214.

## Gate (DONE 2026-11-15, log `full-suite-wave-targets-gate.log`)

Full gate (PID 15436, launch 14:47 by coordinator lượt 4, done 15:05 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-targets-gate.log`, untracked): Ran 5913 in 1040.657s,
failures=155, skipped=5, 0 errors — 155/155 verified Godot-absent (152 inherited + 3 new proof tests
N2212–N2214, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.
