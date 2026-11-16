# Handoff N2454 — Narrow N2348 pin (serial fix)

## What this slice did

Coordinator-serial pin fix (N2432/N2424 precedent): the N2348
tier_stamp pin asserted 'onRemoved / drawSelect still defer' —
N2447 ported both, so the pin now asserts 'Select / remove rows
live (N2447)' + the remaining true gap (wasOccupied predicate /
handoff-to-intake wiring / live payload fill wait for their own
slices) + the stale phrase absent. 1 file, +10/−2, commit
`45d41d41a` on the integration branch.

## Key facts for the next agent

- **Pin narrowed, not weakened:** still asserts a live row + a
  remaining gap + the stale phrase absent.
- SSOT +0/+0/+0/+0. No proof file changed — NO re-run.

## Godot debt (this slice)

- None.
