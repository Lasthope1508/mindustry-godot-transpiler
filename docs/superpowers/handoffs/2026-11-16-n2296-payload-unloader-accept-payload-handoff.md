# Handoff N2296 — PayloadUnloader acceptPayload + acceptItem/acceptLiquid false

## What this slice did

Ported the PayloadUnloader's acceptance rows as pure
`source_payload_unloader_accept_payload_state` → {accept_payload, accept_item,
accept_liquid} (the latter two ALWAYS false, PayloadUnloader.java:35-44). The tick
exposes all three verdicts from frame input `offered_payload` (default null → all
false). Commit `14746b76` (`slice/N2296-payload-unloader-accept-payload`).

## Key facts for the next agent

- **Inheritance correction (the brief was wrong):** `PayloadUnloaderBuild extends
  PayloadLoaderBuild` (PayloadUnloader.java:32) — the Unloader inherits the LOADER's
  acceptPayload override (:90-101), NOT the PayloadBlock base gate. DEFERRED entry
  12's cite was correct all along.
- acceptLiquid is :40-43 (:44 is blank), not :40-44 as the brief said.
- No offer → accepts FALSE (the brief's "accepts true" came from the wrong design).
- The N2295 pure ports the SAME Java method for the Loader driver — duplicated logic
  is correct per Java, do not dedup.
- The gate does NOT block the N2279 intake yet (intake-guard wiring is a new
  DEFERRED entry); the N2293 dump rows move items/liquids OUT only, which is why
  acceptItem/acceptLiquid false matters.
- DEFERRED entry 12 resolved. New entries: intake-guard wiring, live offered source,
  descriptor unification.
- SSOT +3/+1/+1/+2 → 11891/1744/1678/3148.

## Godot debt (this slice)

Proof `C07PayloadUnloaderAcceptPayloadProof` (6 keys) — written, NEVER run on this VM.
See GOAL.md §5. Run targeted test `tests.test_c07_payload_unloader_accept_payload`
with Godot 4.6.2 on PATH, port 7777 free.
