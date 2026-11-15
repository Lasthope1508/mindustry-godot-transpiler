# N2278 PayloadLoader Live Payload Fill — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

PayloadLoader live payload fill: 2 pure functions (`source_payload_loader_handle_payload_state` → payload/pay_vector/pay_rotation/exporting=false + `source_payload_loader_take_payload_state` → payload_taken/payload_after=null). The intake applies BEFORE the consumption fold + advance when `frame["incoming_payload"] != null` and the frame payload is null; the one-tick push is consumed either way. takePayload is pure + tested only (the driver never calls it).

## Key facts for the next agent

- **The Loader handlePayload override is PayloadLoader.java:104–107** (not :102-105 — :102–103 are the tail of acceptPayload).
- **No large-payload-loader exists** — only `payload-loader` (size 3, Blocks.java:6682–6689); the size-4 clamp is a param case, not a def.
- **The DEFERRED accept/handle cites were both wrong**: acceptPayload :90–101 (not :102–115), handlePayload :104–107 (not :118–121) — replaced by a corrected acceptPayload-only entry at integration (fix d0ea2b64, applied to all 7 registers).
- Positions arrive as frame inputs (`incoming_source_pos` / `world_pos`): the port has no live world-position model — `sprite.position` is never set by placement and `origin_cell` is a cell, so no cell→pixel mapping was invented.
- ⚠️ **Divergence vs N2279 (documented, kept):** N2278 drops the incoming input whether or not it applies; N2279 keeps it for a retry next tick. Java: the pusher checks acceptPayload first, so a push to an occupied building never happens — the difference only shows on frame-input edges. A future alignment slice may unify them.
- moveInPayload is already ported in the N2231 advance (not re-ported). `updatePayload()` is not ported (no live payload entity).
- SSOT +6/+1/+2/+4 → 11801/1724/1656/3104 (audit 1336). 2 pure → 2 contracts + 4 schemas. Exact-evidence 25/25. DEFERRED 292 (−1 resolved + 3 new: updatePayload live positioning, takePayload live wiring, incoming_payload live sources).

## Godot debt (this slice)

`C07PayloadLoaderLiveFillProof` — 6 keys: handle_sets_payload_and_vector, handle_clamps_pay_vector_to_half_size, handle_sets_pay_rotation, handle_clears_exporting, handle_ignored_when_payload_present, take_returns_and_clears_payload (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_payload_loader_live_fill`. Do NOT mark done until it passes there.
