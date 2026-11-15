# N2278 PayloadLoader Live Payload Fill — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## Source

`handlePayload(Building source, Payload payload)` (PayloadBlock.java:121-127): `this.payload = (T)payload;` `this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, -size * tilesize / 2f, size * tilesize / 2f, size * tilesize / 2f);` `this.payRotation = payload.rotation();` `updatePayload();` Loader override (**PayloadLoader.java:104–107**, not :102-105 as the brief/SCOPE said — :102–103 are the tail of acceptPayload): `super.handlePayload(source, payload); exporting = false;` `takePayload()` (PayloadBlock.java:145-149): `T t = payload; payload = null; return t;` **No large-payload-loader exists** — only `payload-loader` (size 3, Blocks.java:6682–6689); the size-4 clamp (±16.0) is tested as a param case of the pure function, not a def. **The DEFERRED entry "PayloadLoader accept/handle payload rows" cites were both wrong**: acceptPayload is **:90–101** (not :102–115) and handlePayload **:104–107** (not :118–121) — the entry is replaced by a corrected acceptPayload-only entry at integration (fix d0ea2b64). `moveInPayload()` (PayloadBlock.java:181-199) is already ported in the N2231 advance — not re-ported. `updatePayload()` only sets the live payload entity position — the port has no live payload entity, so it is not ported.

## Implementation

`SourcePayloadLoaderBuildState.gd`: 2 pure functions — `source_payload_loader_handle_payload_state` → {payload, pay_vector, pay_rotation, exporting=false} (clamp ±size·tilesize/2 per axis via `clampf`) + `source_payload_loader_take_payload_state` → {payload_taken, payload_after=null}. Tick wiring: the intake applies BEFORE the consumption fold + advance when `frame["incoming_payload"] != null` and the frame payload is null; the one-tick push is consumed either way. takePayload is pure + tested only — the driver never calls it (asserted via `assertNotIn` in the row-state test; move-out clear is already live via N2231). Positions arrive as frame inputs (`incoming_source_pos` / `world_pos`): the port has no live world-position model for placed buildings — `sprite.position` is never set by placement and `origin_cell` is a cell, so no cell→pixel mapping was invented; the live position fill is covered by the new "incoming_payload live sources" deferral. ⚠️ **Divergence vs N2279 (documented, kept):** N2278 drops the incoming input whether or not it applies; N2279 keeps it for a retry next tick when a payload is already present. Java: the pusher checks acceptPayload first, so a push to an occupied building never happens — the difference only shows on frame-input edges. Both behaviors are kept as-is; a future alignment slice may unify them.

## Commits

Slice `46b659ad` (worker-N2278, branch `slice/N2278-payload-loader-live-fill`, 5 files, +934/−9, đã push, remote tip verified by ls-remote). Integration cherry-pick `d4abe20e` on `integration/wave-advances-6-n2274-n2280` (base 253151ad). The wave cite fix d0ea2b64 applied this slice's corrected acceptPayload-only entry to all 7 registers.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 25/25, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (12/16 PASS: power + should-consume + update-tile + dynamic-power), the fails all their Godot proof tests — 0 other failures. Proof's live-tick math accounts for the N2231 advance running after intake in the same tick: payVector (12,0) → approach 0.7 → (11.3,0); payRotation 45 → moveToward 5 → 40. Full wave gate run 2 (PID 4988, launch 01:07 by coordinator lượt 10, done 01:47 +07 16/11): Ran 6210 in 2126.929s, failures=229, skipped=5, 0 errors — 229/229 Godot-absent (222 inherited + 7 new proof tests N2274–N2280). Run 1 (PID 2132, launch 00:31, done 01:07) invalid: Ran 5527, failures=231, errors=15 — all javalang-import (VM restart #6 ~00:27 wiped javalang; reinstalled 0.13.0 at 01:00).

## SSOT / DEFERRED

SSOT single-slice +6/+1/+2/+4 → 11801/1724/1656/3104; audit stays 1336. 2 pure → 2 contracts + 4 schemas, as scoped. DEFERRED 292 (290 − 1 resolved: live payload fill + 3 new: updatePayload live positioning, takePayload live wiring, incoming_payload live sources; the accept/handle entry replaced by a corrected acceptPayload-only entry, net 0). Merged wave DEFERRED: 298 entries (DEFERRED-after-advances-6.py) — 290 − 9 resolved/removed + 17 new, resolved by entry TEXT not number.

## Godot debt

`C07PayloadLoaderLiveFillProof` — 6 keys: handle_sets_payload_and_vector, handle_clamps_pay_vector_to_half_size, handle_sets_pay_rotation, handle_clears_exporting, handle_ignored_when_payload_present, take_returns_and_clears_payload (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
