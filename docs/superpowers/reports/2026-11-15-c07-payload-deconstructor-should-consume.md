# Report — N2210: PayloadDeconstructor shouldConsume gate (C07)

Date: 2026-11-15. Slice branch `slice/N2210-payload-deconstructor-should-consume`, base
`0fb61ffc` (wave-liquids docs tip). Integrated on `integration/wave-payload-n2208-n2211`
(cherry-pick `1abaed7c`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; NOT merged into main; slice branch pushed 14:18 per
push-as-you-go; integration branch pushed immediately after the docs commit
— see STATUS.md).**

Done by worker-N2210 (slice, done 14:17 +07); integrated and documented by
coordinator lượt 4. Slice commit `ba3f6bbd`; merged SSOT `231be5f1`
(wave-level, 11421/1652/1575/2941).

## What changed

The PayloadDeconstructor power.status slice (N2166) folded power only and
deferred the shouldConsume gate ("deconstructing state is not tracked yet").
N2210 wires the gate over a new frame key (the DESIGN-frame-state-infra.md
payload pattern — the Separator N2200 precedent: frame key added, live fill
deferred):

- **Pure gate** `source_payload_deconstructor_should_consume_state(frame)`
  in `SourcePayloadDeconstructorBuildState.gd` — mirrors
  PayloadDeconstructorBuild.shouldConsume()
  (PayloadDeconstructor.java:219-221): `return deconstructing != null &&
  enabled;` — this gate HAS `&& enabled`, unlike the Loader/Unloader gates.
  Returns `{"should_consume", "deconstructing_present"}` (the N2201
  precedent: the second result symbol is the value the gate reads).
  `enabled` is read from the frame (the tick already preserves
  `frame["enabled"]`, the factory precedent).
- **Frame key `deconstructing`** (default null — the Java field is nullable,
  `public @Nullable Payload deconstructing;`, PayloadDeconstructor.java:52).
  The gate reads only null-ness; no live fill sets the key yet (handlePayload
  / updateTile advance waits for its own slice).
- The driver feeds `should_consume` into the consumption machinery (the
  N2188/N2198 precedent), so efficiency folds to 0 when the gate is false
  (BuildingComp.java:1960/:1992-1994).
- Both defs (small-deconstructor consumePower 1f, deconstructor 3f) go
  through the catalog consumePower — no def constants needed.
- The power.row limit comment now says the gate is LIVE.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_payload_deconstructor_should_consume.py`
+ register script `tools/mindustry_godot_transpiler/register_c07_payload_deconstructor_should_consume.py`
written by worker-N2210. Register script: EXACT_EXPRS = the 15 verified
exprs (all 15 unique, all present verbatim in upstream — script check,
0 missing), DEFERRED 257 entries (the PayloadDeconstructor gate entry resolved; 1 new
deferral added: PayloadDeconstructor live deconstructing fill).

RED run: the expected no-Godot pattern — registration + exact-evidence fail
`KeyError: 'N2210'`, the state test fails on the missing pure function, and
the proof test fails Godot-absent (`AssertionError: unexpectedly None` at
`assertIsNotNone(godot)`).

## GREEN

- Pure gate + driver wiring in `SourcePayloadDeconstructorBuildState.gd`;
  frame key `deconstructing`; the limit comment updated. Header quotes the
  exact exprs, each Java line on ONE comment line (the N2148 lesson).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorShouldConsumeProof.gd`
  + `.tscn` (6 keys + registry_valid / one_headquarter_per_ssot / matches):
  gate_true_when_deconstructing_and_enabled,
  gate_false_when_no_deconstructing, gate_false_when_disabled,
  frame_key_default_null, efficiency_zero_when_gate_false,
  efficiency_folds_power_when_gate_true. The
  `gate_false_when_disabled` key is the distinguisher vs the
  Loader/Unloader gates (which have no `&& enabled`). The proof injects a
  minimal Dictionary fixture `{"block": "conveyor"}` as the deconstructing
  payload (only null-ness is read — stated in the proof; no real BuildPayload
  is built). Proof `.json` is gitignored (never stage, per AGENTS.md rule on
  proof .json).
- Register script: SSOT single-slice **+2/+1/+1/+2 → 11415/1649/1572/2935**
  from the wave-liquids base 11413/1648/1571/2933; audit totalSourceFunctions
  1336, legacy 0. **Payload shard CHANGED** (`payload_api_contracts` +
  `payload_slices`; production shard NOT changed).
- Targeted: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence 15/15,
  state) + 1 FAIL, the proof test, failing exactly
  `AssertionError: unexpectedly None` at `assertIsNotNone(godot)` — **no Godot
  binary exists on this VM** (user order 2026-11-15: no Godot runs here at all —
  no headless, no MCP, no editor). The proof scene is written but NEVER run;
  see GOAL.md §5 debt.

## Neighbours (coordinator, main thread — wave-level)

Payload family power_status (20 tests): 15 PASS + 5 Godot-absent (the
power_status proofs of loader / unloader / deconstructor / cargo loader /
mass driver), 0 other failures. Targeted 4 wave modules (16 tests): 12 PASS
+ 4 proof tests Godot-absent. No regression.

## Gate

Full gate (PID 11414, launch 14:20 by coordinator lượt 4, done 14:38 +07, log
`tools/mindustry_godot_transpiler/full-suite-wave-payload-gate.log`, untracked): Ran 5901 in 1003.626s,
failures=152, skipped=5, 0 errors — 152/152 verified Godot-absent (148 inherited + 4 new proof tests
N2208–N2211, all confirmed present in the failures; 0 `ERROR:` lines). Gate clean except Godot; no
regression.

## Commits

- Slice: `ba3f6bbd` — C07: N2210 PayloadDeconstructor shouldConsume gate, 5 files
  (+494/−7), on `slice/N2210-payload-deconstructor-should-consume` (base `0fb61ffc`).
  Cherry-pick `1abaed7c` on `integration/wave-payload-n2208-n2211`.
- Coordinator fix `53ed2029` at integration (by design, not a regression):
  seed a deconstructing fixture into the N2166 power proof — the
  deconstructor there has no deconstructing payload, so its
  `efficiency_folds_power_min` key would read 0 on Godot now that the gate
  closes on an empty frame (the 481315f8 precedent from wave items). Same
  fix applied to the N2162 + N2163 power proofs in the same commit.
- SSOT: merged `231be5f1` — wave-level SSOT (11421/1652/1575/2941), audit
  1336, legacy 0, validator errors [].
- Docs: (this commit) — report + handoff + spec + GOAL for N2208–N2211.
- NOT merged into main. Slice branch pushed 14:18, integration branch
  pushed per push-as-you-go immediately after the docs commit (user order
  12:08 + parent 12:26); push recorded in STATUS.md.

## Deferred (NOT this slice)

- Live deconstructing fill: frame `deconstructing` is never filled on the
  live path yet — handlePayload / updateTile advance belongs to its own slice.
- The updateTile advance (dumpAccumulate / progress / payRotation /
  canProgress / accum / item transfer / finish), accept/handle payload rows,
  sense, draw/icons, setBars, read/write, dump rows — deferred (documented
  in the driver limits).
- The driver-wide disabled early return (BuildingComp.java:1954-1957) —
  deferred (same deviation as N2188/N2198/N2201–N2204).
- Godot proof never run on this VM (no Godot here, user order) — debt in GOAL.md §5:
  `C07PayloadDeconstructorShouldConsumeProof`, commit carrying the scene `ba3f6bbd`,
  6 keys (listed above + `registry_valid` / `one_headquarter_per_ssot` /
  `matches`), status "chờ agent Godot test". Run: targeted test
  `tests.test_c07_payload_deconstructor_should_consume` with Godot 4.6.2 on PATH, port
  7777 free.
- Next: targets (RepairTurret/RepairTower/RegenProjector gates — see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) →
  plans → units.
