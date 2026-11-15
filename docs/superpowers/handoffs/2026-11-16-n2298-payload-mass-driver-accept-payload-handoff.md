# Handoff N2298 — PayloadMassDriver acceptPayload

## What this slice did

Ported `PayloadMassDriverBuild.acceptPayload` (PayloadMassDriver.java:462-463) as pure
`source_payload_mass_driver_accept_payload_state` → {accepts, size_fits, threshold}.
The tick wires the verdict AFTER the N2246 branches (post-tick payload read) from
frame input `offered_payload_size`. Commit `ea7c5609`
(`slice/N2298-payload-mass-driver-accept-payload`).

## Key facts for the next agent

- DEFERRED entry 10's cite (:317-319) was WRONG — that's shoot/reset code. Real gate
  is :462-463.
- Threshold 24 = maxPayloadSize 3 × tilesize 8 (class default).
- **Both real defs override maxPayloadSize** (2.5f → threshold 20, 4f → threshold 32,
  Blocks.java:6624/6636) — the class-default threshold is NOT Java-exact for either
  def. A per-def threshold slice (or a `max_payload_size` param) is needed; recorded
  as a new DEFERRED entry.
- The PMD gate is size-based (world units), unlike the Loader/Deconstructor block-size
  fits checks.
- DEFERRED entry 10 resolved. SSOT +3/+1/+1/+2 → 11891/1744/1678/3148.

## Godot debt (this slice)

Proof `C07PayloadMassDriverAcceptPayloadProof` (6 keys) — written, NEVER run on this
VM. See GOAL.md §5. Run targeted test `tests.test_c07_payload_mass_driver_accept_payload`
with Godot 4.6.2 on PATH, port 7777 free.
