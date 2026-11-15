# Handoff — N2209 PayloadUnloader shouldConsume gate

Date: 2026-11-15. Slice branch `slice/N2209-payload-unloader-should-consume`, base
`0fb61ffc` (wave-liquids docs tip). Integrated on `integration/wave-payload-n2208-n2211`
(cherry-pick `d9e2df14`). Status: **DONE (code + SSOT + neighbours + gate
clean except Godot; slice cb77521d, merged SSOT 231be5f1; NOT merged into
main; slice branch pushed 14:18, integration branch pushed immediately
after the docs commit).**

Done by worker-N2209 (slice, done 14:18 +07); integrated and documented by
coordinator lượt 4.

## Scoping (DONE 2026-11-15 14:1x +07, SCOPE-payload-wave.md + brief-n2209-payload-unloader.md)

- `PayloadUnloader extends PayloadLoader` (PayloadUnloader.java:8),
  `PayloadUnloaderBuild extends PayloadLoaderBuild` (:32); grep finds NO
  shouldConsume override in PayloadUnloader.java (0 matches) → the gate is
  inherited verbatim from PayloadLoader.java:240-242: `return payload !=
  null;` — NO `&& enabled`.
- Def: payload-unloader only (consumePower 2f, size 3, Blocks.java:6691-6698);
  no large-payload-unloader exists. The shouldExport gate
  (PayloadUnloader.java:116-122) is a DIFFERENT gate — NOT this slice.
- Port: `SourcePayloadUnloaderBuildState.gd`, `_initial_frame()` returns `{}` —
  the slice adds frame key `payload` + pure gate + driver wiring (the
  N2198/N2207 inherited-gate precedent: separate driver, own pure gate).
  Live fill deferred to the updateTile advance slice.
- SSOT baseline re-verified from the generated JSONs (base `0fb61ffc`):
  symbols 11413 + slices 1648 + contracts 1571 + schemas 2933; audit
  `totalSourceFunctions` 1336. Expected after N2209 (single-slice):
  **11415/1649/1572/2935** — confirmed.

## Design (decided in scoping, recorded in test + register)

- Pure `source_payload_unloader_should_consume_state(frame)` →
  `{should_consume, has_payload}`. New symbols carry java_source
  `PayloadLoader.java` (the N2198/N2207 precedent: an inherited gate cites
  the parent class/method).
- Frame key `payload` only (null default). The driver reads the gate through
  the pure function; the machinery folds efficiency to 0 when the gate is
  false (BuildingComp.java:1960/:1992-1994).
- Proof scene `C07PayloadUnloaderShouldConsumeProof.gd/.tscn` (6 keys, N2185 pattern).

## RED (DONE 2026-11-15 14:18 +07, worker-N2209)

- Test module `tools/mindustry_godot_transpiler/tests/test_c07_payload_unloader_should_consume.py`
  + register script `tools/mindustry_godot_transpiler/register_c07_payload_unloader_should_consume.py`.
- Register script verified standalone: **exit 0**. **14 exact exprs, 0 missing**;
  DEFERRED 257 entries. OWNER
  `SourcePayloadUnloaderBuildState.source_payload_unloader_should_consume_state`, PROOF
  `/root/C07PayloadUnloaderShouldConsumeProof`.
- Targeted RED run: the expected pattern — `KeyError: 'N2209'`
  (registration + exact-evidence), the missing pure function (state test),
  proof test fails Godot-absent (`AssertionError: unexpectedly None` at
  `assertIsNotNone(godot)`). No other failures. `git diff --check` clean.

## GREEN (DONE 2026-11-15 14:18 +07, worker-N2209)

- Pure gate + driver wiring + frame key `payload` (5 files, +764/−9);
  proof scene (6 keys); all 14 exact exprs present, each on ONE comment
  line. The limit comment in the PayloadUnloader power row now says the gate
  is LIVE.
- SSOT at GREEN (single-slice): **11415/1649/1572/2935**, audit 1336,
  legacy 0. Payload shard CHANGED (payload_api_contracts +
  payload_slices). `git diff --check` clean.
- Targeted run: **Ran 4 tests, 3/4 PASS** (registration, exact-evidence
  14/14, state) + proof test FAIL, exactly `AssertionError: unexpectedly
  None` — no Godot on this VM (user order: no Godot runs here at all).
- Coordinator verification (lượt 4): commit + 5 files match the brief;
  register exit 0; targeted 3/4 after register; generated/ reverted,
  working tree clean.

## Neighbours (DONE 2026-11-15 ~14:20 +07, coordinator, main thread — wave-level)

- Payload family power_status (20 tests): 15 PASS + 5 Godot-absent, 0 other
  failures. Targeted 4 wave modules (16 tests): 12 PASS + 4 proof tests
  Godot-absent. No regression.
- Coordinator fix `53ed2029` at integration (by design, not a regression):
  seed a payload fixture into the N2163 power proof — the unloader there has
  no payload, so its `efficiency_folds_power_min` key would read 0 on Godot
  now that the gate closes on an empty frame (the 481315f8 precedent from
  wave items). Same fix for the N2162 + N2166 power proofs in the same
  commit.

## Exact exprs (14, all verified verbatim at scoping — script check, 0 missing)

See `register_c07_payload_unloader_should_consume.py` EXACT_EXPRS (14 entries,
including `return payload != null;`, the PayloadUnloader extends lines, and
the Blocks.java def lines).

## Next

- Targets (RepairTurret/RepairTower/RegenProjector gates — see
  `DESIGN-frame-state-infra.md` in `~/workspace/mindustry-parallel/`) →
  plans → units.
- Standalone coordinator-serial work still pending: the driver-wide disabled
  early return fix (BuildingComp.java:1954-1957); the raw-delta audit of
  remaining runtime files; the N2198 tick cross-def fix slice.
- Godot proof debt: `C07PayloadUnloaderShouldConsumeProof`, 6 keys, status
  "chờ agent Godot test" (GOAL.md §5).

## Commits

- Slice: `cb77521d` — C07: N2209 PayloadUnloader shouldConsume gate, 5 files (+764/−9).
  Cherry-pick `d9e2df14` on `integration/wave-payload-n2208-n2211`.
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
