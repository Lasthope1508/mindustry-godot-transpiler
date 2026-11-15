# Handoff N2304 — PMD per-def maxPayloadSize threshold

## What this slice did

Ported the per-def `maxPayloadSize` threshold for the PayloadMassDriver
acceptPayload gate: NEW pure
`source_payload_mass_driver_accept_payload_state_for_def(payload_size,
has_payload, max_payload_size)` + helper
`_payload_mass_driver_max_payload_size_for_block(block_id)` returning 2.5 / 4.0 /
3.0 (class default). The tick now passes the per-def value. 6 files, +940/−17,
commit `a174435c` on `slice/N2304-pmd-per-def-threshold`.

## Key facts for the next agent

- Both real defs override the class default 3: payload-mass-driver 2.5f → 20
  (Blocks.java:6624), large-payload-mass-driver 4f → 32 (Blocks.java:6636).
  Threshold 24 is NOT Java behavior for either def.
- NEW pure, not an extension: the N2298 test pins the exact 2-arg tick call
  string + the class-default threshold line. The N2298 pure stays untouched as
  the class-default gate.
- The catalog has NO maxPayloadSize property (grep-verified) — per-def values
  need the driver helper (N2273 boostItemUseTime precedent).
- The N2298 test HAD to be updated (6th file) — it pins the tick-call string
  (N2290 precedent). Proof discriminator: size 24 fits class default but
  rejects at the small def.
- SSOT +3/+1/+1/+2 (brief estimated +5 symbols — the pure mirrors N2298's 3
  outputs). DEFERRED 324 (−1 per-def entry + 0 new).

## Godot debt (this slice)

- NEW proof `C07PayloadMassDriverPerDefThresholdProof` (6 keys) — never run.
- RE-RUN of proof N2298 RECOMMENDED (tick path changed; live-tick values 16/32
  still hold).
