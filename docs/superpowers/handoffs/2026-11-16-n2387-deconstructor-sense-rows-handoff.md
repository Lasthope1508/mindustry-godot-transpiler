# Handoff N2387 — PayloadDeconstructor sense rows

## What this slice did

2 pures (the Java overloads differ): `sense(LAccess)` — progress
as-is, NO clamp; `sense(Content)` — reads `kind` from the N2233
descriptor, equality via caller-supplied `payload_content_id`.
Pure-only. 5 files, +1022/−1, commit `fa2448999` on
`slice/N2387-deconstructor-sense-rows`.

## Key facts for the next agent

- **No identity key invented:** the frame descriptor carries `kind`
  / `requirements` / `build_time` but no unit type or block — the
  equality operand is an explicit caller input (the N2383
  precedent).
- **Progress as-is, NO clamp** — 1.25 stays 1.25 (unlike
  MendProjector).
- super.sense rides the already-modeled `SourceBuildingSenseState`
  pures — nothing re-modeled.
- SSOT +4/+1/+2/+4. DEFERRED 306→305 (#6 resolved).
- The live call site needs a payload-contract slice to add identity
  keys to the descriptor before `payload_content_id` can come from
  the frame.

## Godot debt (this slice)

- NEW proof `C07PayloadDeconstructorSenseRowsProof` (7 keys) —
  never run.
