# Report N2387 — PayloadDeconstructor sense rows

**Slice:** N2387 — PayloadDeconstructor `sense()` rows: `sense(Content)`
deconstructing type/block match + `sense(LAccess.progress)` progress.
**Wave:** advances-21. **Commit:** `fa2448999` on
`slice/N2387-deconstructor-sense-rows` (base `d35c67781`).
**Files:** 5, +1022/−1.

## Source

Java: PayloadDeconstructor.java:206-210 (`sense(Content)` — 1 when
the deconstructing payload matches the content, 0 otherwise,
`super.sense(content)` when nothing is deconstructing),
:213-216 (`sense(LAccess.progress)` returns `progress` as-is),
:54 (the `deconstructing` field), :142 (`buildTime()`).

## Implementation

**2 pures, not 1** — the Java overloads have different signatures
(Content vs LAccess):
- `source_payload_deconstructor_sense_state(sensor, progress,
  super_value = null)` → `{value, is_progress}`. **Progress
  returns as-is, NO clamp** (unlike MendProjector); a progress of
  1.25 stays 1.25, pinned in the proof.
- `source_payload_deconstructor_sense_content_state(deconstructing,
  content_id, payload_content_id, super_value = null)` → `{value,
  is_unit_payload}`. Reads `kind` from the descriptor; null
  deconstructing falls through to `super_value`.

**Descriptor format verified first (per the brief):** frame
`deconstructing` is the N2233 payload dict contract — `kind`
("build"/"unit"), `requirements`, `build_time`. `kind` DOES
distinguish UnitPayload vs BuildPayload (the instanceof dispatch),
but the descriptor carries **no identity key** — neither unit type
nor block is in the frame, so the `up.unit.type == content` /
`bp.build.block == content` equality cannot come from the
descriptor. **No descriptor key invented.** The equality operand
arrives as the caller-supplied `payload_content_id` explicit input
(the N2383 `reload_value`/`super_value` precedent); the pure is
Java-exact given that input.

**Pure-only (the N2383 pattern):** grep confirms `sense` appears in
the driver only in comment defers — no tick call site. Sense is
called by logic (the processor), not the tick. super.sense rides
the already-modeled `SourceBuildingSenseState` pures (LAccess
switch + `sense_content_state`); nothing re-modeled.

## Commits

- Slice: `fa2448999` (5 files, +1022/−1).
- Integration cherry-pick: `0177486af` (clean).

## Tests

Targeted (new module
`tests.test_c07_payload_deconstructor_sense_rows`): 3/4 PASS + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+2/+4** → 12055/1813/1742/3276 (4 symbols:
`source_payload_deconstructor_sense_state_result.value`,
`.is_progress`,
`source_payload_deconstructor_sense_content_state_result.value`,
`.is_unit_payload`; shards `payload_api_contracts.json` +
`payload_slices.json`). Audit stays 1336. DEFERRED **306 → 305**
(resolves #6, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07PayloadDeconstructorSenseRowsProof` (7 keys:
  `sense_progress_zero`, `sense_progress_partial` (incl. the
  unclamped 1.25 case), `sense_super_sensor` (health 80.0 /
  efficiency 0.75 pass-through), `sense_super_default` (unknown
  sensor → null + null-deconstructing Content default → null),
  `sense_content_unit_match` (dagger/dagger → 1.0, flare/dagger →
  0.0), `sense_content_build_match` (conveyor/conveyor → 1.0,
  router mismatch → 0.0, null → super item amount 5.0),
  `sense_live_frame_values` (placed deconstructor, one N2233
  advance tick 0.0→0.1 progress, both pures read the live frame))
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the live call site cannot supply
  `payload_content_id` from the frame until a payload-contract
  slice adds identity keys to the descriptor (a payload-contract
  concern, not a Deconstructor deferral); the logic-executor call
  site for `sense()` is port-wide; draw / icons / setBars /
  read-write rows still defer.
