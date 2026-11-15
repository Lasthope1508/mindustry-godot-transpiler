# N2279 PayloadUnloader Live Payload Fill — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

PayloadUnloader live payload fill: 2 pure functions (`source_payload_unloader_handle_payload_state` → payload/pay_vector/pay_rotation + `source_payload_unloader_take_payload_state` → payload_taken/payload_after=null). Handle is wired live: applies when `incoming_payload != null` and the frame payload is null, BEFORE the consumption fold + advance; the input is cleared only on successful apply. takePayload is pure + tested only.

## Key facts for the next agent

- **acceptPayload is PayloadLoader.java:90-101** (not :102-115); **the Loader handlePayload override is :104-107** (not :102-105 or :118-121) — both old cites were wrong (confirmed by N2278 and N2279 independently).
- The Unloader does NOT override handlePayload and has NO exporting flag (grep 0 matches, asserted in the test). Size 3 (Blocks.java:6696) → clamp ±12.0. The Unloader has NO dynamic consumer (`loadPowerDynamic=false`, PayloadUnloader.java:18).
- `incoming_payload` = `{"payload": <N2232 dict + "rotation">, "source_offset": {"x","y"}}`; `source_offset` is supplied by the pusher (the port has no live building world position). The clamp is component-wise via 4-arg `Vec2.clamp`, not a length clamp. `payRotation` reads key `"rotation"` (default 0.0).
- ⚠️ **Divergence vs N2278 (documented, kept):** N2279 KEEPS the incoming input for a retry next tick when a payload is already present; N2278 drops it either way. Java: the pusher checks acceptPayload first, so a push to an occupied building never happens — the difference only shows on frame-input edges. A future alignment slice may unify them.
- moveInPayload/moveOutPayload are live since N2232 (not re-ported). acceptPayload/acceptItem/acceptLiquid are NOT this slice. `updatePayload()` is not ported (no live payload entity).
- Coordinator fix 11cb9158: the wave cite fix replaced the accept/handle DEFERRED entry, breaking this slice's registration test prefix assertion — the test now asserts the corrected prefix.
- SSOT +5/+1/+2/+4 → 11800/1724/1656/3104 (audit 1336). 2 pure → 2 contracts + 4 schemas. Exact-evidence 31/31. DEFERRED 291 (−1 resolved + 2 new: takePayload live wiring, live incoming payload source).

## Godot debt (this slice)

`C07PayloadUnloaderLiveFillProof` — 7 keys: handle_sets_payload_and_vector, handle_clamps_pay_vector_to_half_size, handle_sets_pay_rotation, handle_ignored_when_payload_present, take_returns_and_clears_payload, no_exporting_flag_on_unloader, live_tick_fills_payload_from_incoming (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_payload_unloader_live_fill`. Do NOT mark done until it passes there.
