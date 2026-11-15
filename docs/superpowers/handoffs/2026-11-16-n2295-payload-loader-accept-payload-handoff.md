# Handoff N2295 — PayloadLoader acceptPayload

## What this slice did

Ported `PayloadLoaderBuild.acceptPayload` (PayloadLoader.java:90-101) as pure
`source_payload_loader_accept_payload_state` → {accepts, fits, is_item_container,
is_liquid_container, is_battery}. The tick stamps `frame["accepts_payload"]` from
`frame["offered_payload"]` BEFORE the N2278 intake. Commit `762ff9a1`
(`slice/N2295-payload-loader-accept-payload`).

## Key facts for the next agent

- Base gate is `this.payload == null` (PayloadBlock.java:116-118); fits =
  `size()/tilesize <= maxBlockSize` with maxBlockSize = 3 (:25); BuildPayload.size()
  = block.size × tilesize, so fits = size <= 3 is Java-exact.
- The payload descriptor has 9 keys; missing keys default to REJECTING (a partial
  fixture never accepts).
- Non-build payload nuance: Java's fits for UnitPayload uses `unit.hitSize`, which
  the descriptor doesn't carry — inert because the instanceof gate rejects anyway.
- The N2296 pure ports the SAME Java method for the Unloader driver (Unloader
  extends Loader) — duplicated logic is correct per Java, do not dedup.
- DEFERRED entry 161 resolved. New entries: offered_payload live sources (no live
  source pushes an offer yet), payload-descriptor contract.
- SSOT +5/+1/+1/+2 → 11893/1744/1678/3148.

## Godot debt (this slice)

Proof `C07PayloadLoaderAcceptPayloadProof` (6 keys) — written, NEVER run on this VM.
See GOAL.md §5. Run targeted test `tests.test_c07_payload_loader_accept_payload`
with Godot 4.6.2 on PATH, port 7777 free.
