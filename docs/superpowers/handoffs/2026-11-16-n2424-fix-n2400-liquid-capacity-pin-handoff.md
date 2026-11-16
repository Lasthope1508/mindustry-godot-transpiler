# Handoff N2424 — Fix N2400 liquid_capacity pin

## What this slice did

Coordinator-serial fix at advances-25 integration: the N2400 pin
`assertNotIn('liquid_capacity')` broke because the N2420 draw pure
takes `liquid_capacity` as an explicit input. The pin now asserts
the narrowed discrepancy: exactly 2 mentions (param + alpha ratio)
and still NO supplier (no catalog get, no frame read). 1 file,
+15/−8, commit `7ec7a249d`.

## Key facts for the next agent

- **The discrepancy narrowed, not closed:** the draw pure (like the
  sense pure) takes the value caller-supplied; nothing supplies the
  Java 40f yet (no catalog key, no frame stamp, no tick wiring) —
  that remains the coordinator-serial generator follow-up.
- SSOT +0. DEFERRED unchanged.

## Godot debt (this slice)

- None (no new proof, no re-run — no proof file changed).
