# Handoff — N2210 PayloadDeconstructor shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2210-payload-deconstructor-should-consume`, base
`0fb61ffc` (wave-liquids docs tip). Integrated on `integration/wave-payload-n2208-n2211`
(cherry-pick `1abaed7c`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice ba3f6bbd, merged SSOT 231be5f1; NOT merged into
main; slice branch pushed 14:18, integration branch pushed immediately
after the docs commit).**

Done by worker-N2210 (slice, done 14:17 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 14:1x +07, SCOPE-payload-wave.md + brief-n2210-payload-deconstructor.md)

- `PayloadDeconstructorBuild.shouldConsume()`
  (PayloadDeconstructor.java:219-221): `return deconstructing != null &&
  enabled;` — HAS `&& enabled`, unlike the Loader/Unloader gates. Field
  `deconstructing` (`public @Nullable Payload deconstructing;`,
  PayloadDeconstructor.java:52).
- Defs: small-deconstructor (consumePower 1f, size 3, Blocks.java:6640-6647)
  and **deconstructor** (consumePower 3f, size 5, Blocks.java:6649-6656) —
  the def name is "deconstructor", NOT "payload-deconstructor" (the old
  driver comment was loose; verified by grep).
- Port: `SourcePayloadDeconstructorBuildState.gd`, `_initial_frame()` returns
  `{}` — the slice adds frame key `deconstructing` + pure gate + driver
  wiring. `enabled` is already in the frame (the tick preserves it). Live
  fill deferred to the updateTile advance slice.
- SSOT baseline re-verified from the generated JSONs (base `0fb61ffc`):
  symbols 11413 + slices 1648 + contracts 1571 + schemas 2933; audit
  `totalSourceFunctions` 1336. Expected after N2210 (single-slice):
  **11415/1649/1572/2935** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_payload_deconstructor_should_consume_state(frame)` →
  `{should_consume, deconstructing_present}` (the N2201 precedent: the
  second result symbol is the value the gate reads).
- Frame key `deconstructing` only (null default). The driver reads the gate
  through the pure function; the machinery folds efficiency to 0 when the
  gate is false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07PayloadDeconstructorShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 14:17 +07, worker-N2210)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_payload_deconstructor_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_payload_deconstructor_should_consume.py`.
- Register script verified standalone: **exit 0**. **15 exact exprs, 0 missing**;
  DEFERRED 257 entries. OWNER
  `SourcePayloadDeconstructorBuildState.source_payload_deconstructor_should_consume_state`, PROOF
  `/root/C07PayloadDeconstructorShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2210'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 14:17 +07, worker-N2210)

- Pure gate + driver wiring + frame key `deconstructing` (5 files, +494/−7);
  proof scene (6 keys); all 15 exact exprs present, each on ONE comment
  line. The limit comment in the PayloadDeconstructor power row now says the
  gate is LIVE.
- SSOT at GREEN (single-slice): **11415/1649/1572/2935**, audit 1336,
  legacy 0. Payload shard CHANGED (payload_api_contracts +
  payload_slices). `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  15/15, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean.

## Neighbours (DONE 2026-11-15 ~14:20 +07, coordinator, main thread — wave-level)

- Payload family power_status (20 tests): 15 PASS + 5 Godot-absent, 0 other
  failures. Targeted 4 wave modules (16 tests): 12 PASS + 4 proof tests
  Godot-absent. No regression.
- Coordinator fix `53ed2029` at integration (by design, not a regression):
  seed a deconstructing fixture into the N2166 power proof — the
  deconstructor there has no deconstructing payload, so its
  `efficiency_folds_power_min` key would read 0 on Godot now that the gate
  closes on an empty frame (the 481315f8 precedent from wave items). Same
  fix for the N2162 + N2163 power proofs in the same commit.

## Exact exprs (15, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_payload_deconstructor_should_consume.py` EXACT_EXPRS (15 entries,
including `return deconstructing != null && enabled;`, the field line, and
the Blocks.java def lines).

## Next

- Targets (RepairTurret/RepairTower/RegenProjector gates — see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) →
  plans → units.
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07PayloadDeconstructorShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `ba3f6bbd` — C07: N2210 PayloadDeconstructor shouldConsume gate, 5 files (+494/−7).
  Cherry-pick `1abaed7c` on `integration/wave-payload-n2208-n2211`.
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
