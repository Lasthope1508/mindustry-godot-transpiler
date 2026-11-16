# Handoff N2471 — PayloadLoader super.updateTile rows

## What this slice did

One pure-only pure (no tick wiring): `source_payload_loader_payload_
update_state` reports the payload.update CALL record when the
payload is non-null. 5 files, +766/−1, commit `a69b8d425` on
`slice/N2471-payload-loader-super-update-tile-rows`.

## Key facts for the next agent

- **kind is caller-supplied, default "BuildPayload"** — the N2231
  contract has NO kind key; Java-exact via
  PayloadBlockBuild<BuildPayload> (:86).
- **The call ALWAYS runs when payload != null** — BuildPayload's
  gate short-circuits on the Loader's null unit holder.
- **The callee behaviour is NOT ported** — no live payload entity
  in the port (BuildPayload.update :52-57 / UnitPayload.update
  :51-53 stay unported).
- **#139 is NOT a duplicate** — generic PayloadBlock entry (PMD
  call site :156), left in place.
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #104 resolved (238→237).

## Godot debt (this slice)

- NEW proof `C07PayloadLoaderSuperUpdateTileRowsProof` (6 keys) —
  never run.
