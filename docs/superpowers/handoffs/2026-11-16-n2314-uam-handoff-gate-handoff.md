# Handoff N2314 — UAM handoff-gate wiring

## What this slice did

Wired the UAM handoff gate through the LINK verdict: the tick evaluates the
link acceptPayload verdict BEFORE the advance and stamps
`frame["accept_payload"]` from it; the module verdict still runs AFTER the
advance. 6 files, +905/−45, commit `cbdce965` on
`slice/N2314-uam-handoff-gate`.

## Key facts for the next agent

- The handoff gate is the ASSEMBLER's gate (`link.acceptPayload`,
  UnitAssemblerModule.java:137–139), NOT the module's own gate (:110-111).
  The worker confirmed this from Java independently.
- Ordering pinned by string index in the test: link call < advance call <
  module call. N2299's tick-call string is pinned verbatim (preserved); N2248's
  advance call string is unchanged.
- The module verdict does NOT drive the gate — proof key
  `module_verdict_does_not_drive_gate` pins it.
- **The N2248 fixture needed the seed replaced:** the seeded
  `accept_payload=true` is overwritten by the tick (false without an offer),
  so the worker seeded a live offer instead (offered_payload {router} +
  assembler + plan_requirements + unit_cost 1.0 → TRUE verdict). Key assertion
  unchanged. → N2248 proof is a RE-RUN.
- N2299 proof untouched (live tick holds no payload); the coordinator fixed one
  wording-stale comment line in it at integration (b9ca6d7e).
- SSOT +0/+1/+0/+0 (shared ownership of the link pure's 5 symbols). DEFERRED
  324 (−1 #318 +0).

## Godot debt (this slice)

- NEW proof `C07UnitAssemblerModuleHandoffGateProof` (6 keys) — never run.
- RE-RUN of proof N2248 (`C07UnitAssemblerModuleUpdateTileProof`).
