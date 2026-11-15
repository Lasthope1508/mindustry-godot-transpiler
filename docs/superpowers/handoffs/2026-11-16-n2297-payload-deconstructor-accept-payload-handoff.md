# Handoff N2297 — PayloadDeconstructor acceptPayload + acceptUnitPayload

## What this slice did

Ported both Deconstructor acceptance gates as 2 pures:
`source_payload_deconstructor_accept_payload_state` → 5 outputs (accepts,
deconstructing_empty, payload_empty, has_requirements, fits) and
`source_payload_deconstructor_accept_unit_payload_state` → 4 outputs (accepts,
allowed, has_requirements, fits). The tick exposes `frame["accepts_payload"]` /
`frame["accepts_unit_payload"]` from `frame["offered_payload"]` /
`frame["offered_unit"]`. Commit `b03dbc84`
(`slice/N2297-payload-deconstructor-accept-payload`).

## Key facts for the next agent

- acceptPayload :104-106, acceptUnitPayload :92-95, maxPayloadSize = 4 (:18).
- The `super.acceptPayload` term is redundant (same as `this.payload == null`) but
  ANDed in to stay Java-exact — Java's redundancy, not ours.
- UnitPayload through the acceptPayload gate supplies `ceil(hitSize/tilesize)` as
  `block_size` — preserves the `<=` comparison exactly.
- Missing descriptor keys default to rejecting (requirements 0, block_size = max+1).
- The N2291 intake guard does NOT consult the new verdicts yet (the incoming payload
  dict carries requirements but no block size — new DEFERRED entry "intake
  full-gate wiring").
- DEFERRED entry 13 resolved. SSOT +9/+1/+2/+4 → 11897/1744/1679/3150.

## Godot debt (this slice)

Proof `C07PayloadDeconstructorAcceptPayloadProof` (6 keys) — written, NEVER run on
this VM. See GOAL.md §5. Run targeted test
`tests.test_c07_payload_deconstructor_accept_payload` with Godot 4.6.2 on PATH, port
7777 free.
