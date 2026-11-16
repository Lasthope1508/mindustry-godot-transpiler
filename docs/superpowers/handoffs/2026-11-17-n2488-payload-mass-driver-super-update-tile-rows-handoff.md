# Handoff N2488 — PayloadMassDriver super.updateTile rows

## What this slice did

One pure-only CALL record: `source_payload_mass_driver_payload_update_state`
returns {payload_update_call} — null when the payload is null,
else {method: "payload.update", unit_holder: null,
building_holder: "self", payload_kind}. NO tick wiring: the
N2245 advance still skips the call. 5 files, +816/−2, commit
`baf1eb7df` on
`slice/N2488-payload-mass-driver-super-update-tile-rows`.

## Key facts for the next agent

- **The PMD generic is NOT BuildPayload** — PayloadDriverBuild
  extends PayloadBlockBuild<Payload> (:132), so BOTH kinds are
  genuinely possible in Java. The "BuildPayload" default for a
  kind-less dict is the N2471 PORT convention, not a Java-exact
  generic default.
- The call is unconditional on payload non-null (the null
  check :158-162 is the ONLY gate; the BuildPayload gate
  short-circuits with unitHolder null).
- The N2471 Loader pure/proof are NOT amended; each driver
  owns its pures.
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #131 resolved
  (231→230) — the generic entry N2471 deliberately left alone.

## Godot debt (this slice)

- NEW proof `C07PayloadMassDriverSuperUpdateTileRowsProof` (6
  keys) — never run.
