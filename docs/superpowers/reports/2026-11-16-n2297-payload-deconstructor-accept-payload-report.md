# Report N2297 — PayloadDeconstructor acceptPayload + acceptUnitPayload

**Slice:** N2297 — PayloadDeconstructor acceptPayload + acceptUnitPayload gates (2 pures).
**Wave:** advances-9.
**Commit:** `b03dbc84` on `slice/N2297-payload-deconstructor-accept-payload` (base `9ca87a72`).
**Files:** 5, +1123/−4.

## Source

acceptPayload (PayloadDeconstructor.java:104-106): `deconstructing == null &&
this.payload == null && super.acceptPayload(source, payload) &&
payload.requirements().length > 0 && payload.fits(maxPayloadSize)`. acceptUnitPayload
(PayloadDeconstructor.java:92-95): `payload == null && deconstructing == null &&
unit.type.allowedInPayloads && !unit.spawnedByCore &&
unit.type.getTotalRequirements().length > 0 && unit.hitSize / tilesize <=
maxPayloadSize`. `maxPayloadSize = 4` (PayloadDeconstructor.java:18). tilesize = 8.
`super.acceptPayload` = `return this.payload == null;` (PayloadBlock.java:116-118) —
redundant here (the Deconstructor already checks `this.payload == null` explicitly);
the pure ANDs it in again to stay Java-exact (the redundancy is Java's, not ours).

## Implementation

**Pure 1** `source_payload_deconstructor_accept_payload_state(payload, has_payload,
has_deconstructing)` → 5 outputs: {accepts, deconstructing_empty, payload_empty,
has_requirements, fits} (fits = block_size <= 4 via the Payload default
`size()/tilesize <= s`). **Pure 2**
`source_payload_deconstructor_accept_unit_payload_state(unit, has_payload,
has_deconstructing)` → 4 outputs: {accepts, allowed (= allowed_in_payloads &&
!spawned_by_core), has_requirements, fits (= hitSize/8 ≤ 4, i.e. hitSize ≤ 32)}.
Missing descriptor keys default to rejecting (requirements 0, block_size = max+1).
Tick computes `frame["accepts_payload"]` / `frame["accepts_unit_payload"]` from
`frame["offered_payload"]` / `frame["offered_unit"]` (default null → both false).
N2291 intake guard, N2276 dump rows, N2233 advance untouched.

Design note: a UnitPayload offered through the acceptPayload gate supplies
`ceil(hitSize/tilesize)` as `block_size`, which preserves the `<=` comparison exactly.

## Commits

- Slice: `b03dbc84` (pushed, ls-remote verified).
- Integration cherry-pick: `e5ed06d5`.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 23/23, row-state) +
proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings
(payload-deconstructor family, 6 modules): Ran 24 — 18 PASS + 6 proof fails, 0 other
failures. Full gate (wave advances-9 integration, PID 13482, 03:38–03:59): Ran 6286 tests in 1229.839s, FAILED (failures=248, skipped=5), 0 errors — 248/248 Godot-absent `AssertionError: unexpectedly None` (242 inherited + 6 new proof tests N2295/N2296/N2297/N2298/N2299/N2301; N2300 adds no test).

## SSOT / DEFERRED

SSOT single-slice +9/+1/+2/+4 → 11897/1744/1679/3150; audit stays 1336 (2 pures → 2
contracts + 4 schemas). DEFERRED 321 (321 − 1 entry 13 resolved + 1 new: intake
full-gate wiring — the N2291 intake guard stays the frame null check only and does
not consult the new verdicts yet, because the incoming payload dict carries
requirements but no block size, so the fits term has no live input).

## Godot debt

Proof `C07PayloadDeconstructorAcceptPayloadProof` (6 keys:
`accepts_payload_when_empty_with_requirements`, `accepts_unit_when_allowed`,
`rejects_core_spawned_unit`, `rejects_empty_requirements_payload`,
`rejects_oversize_unit`, `rejects_payload_when_deconstructing_busy` + registry) —
written, NEVER run on this VM (no Godot binary, user order 2026-11-15). See GOAL.md §5.
