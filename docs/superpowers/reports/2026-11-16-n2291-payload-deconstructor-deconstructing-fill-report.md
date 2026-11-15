# N2291 PayloadDeconstructor Deconstructing Fill — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## Source

handlePayload (PayloadDeconstructor.java:98-101): `super.handlePayload(source, payload); accum = null;`. super.handlePayload (PayloadBlock.java:121-127): `this.payload = (T)payload; this.payVector.set(source).sub(this).clamp(-size * tilesize / 2f, ..., size * tilesize / 2f, ...); this.payRotation = payload.rotation(); updatePayload();`. Handoff (PayloadDeconstructor.java:197-202): `else if(moveInPayload(false) && payload != null){ accum = new float[payload.requirements().length]; deconstructing = payload; payload = null; progress = 0f; }`. moveInPayload (PayloadBlock.java:181-199): no-arg overload (:181-183) → `moveInPayload(true)`; boolean overload (**:186-197** — the brief's :181-199 was off: :198-199 are blank + moveOutPayload doc): payload null → false; updatePayload(); if rotate → payRotation moveToward (block.rotate ? rotdeg() : 90f, payloadRotateSpeed * delta()); `payVector.approach(Vec2.ZERO, payloadSpeed * delta())`; return hasArrived(). **The Deconstructor calls moveInPayload(FALSE) — NO rotation.** hasArrived (PayloadBlock.java:242-244): `return payVector.isZero(0.01f);`. updatePayload (**:174-178** — the brief's :174-179 was off, :179 is blank): sets the payload position from payVector/payRotation (presentation — the port tracks pay_vector, updatePayload is a no-op for state). `delta()` = Time.delta × timeScale (BuildingComp.java:1922-1924) — move-in uses SCALED delta.

## Implementation

`SourcePayloadDeconstructorBuildState.gd`: **2 pures** (→ 2 contracts + 4 schemas):
1. `source_payload_deconstructor_handle_payload_state` → payload + pay_vector + pay_rotation + accum=null (pay_vector dict is canonical, N2246/N2278/N2279 precedent; clamp ±size×tilesize/2).
2. `source_payload_deconstructor_move_in_payload_state` → {arrived, pay_vector_after, deconstructing, payload_after, progress_after, accum_after} — approach Vec2.ZERO with payloadSpeed × scaled delta; hasArrived at 0.01f; on arrival → deconstructing = payload, payload = null, progress = 0f, accum = zero array by requirements length.

**Frame keeps Vector2 pay_vector; new pures speak dict.** The N2233 proof + register pin the advance's pay_vector as Vector2 — converting the frame to dict would break N2233's proof. Conversion happens at both boundaries (tick intake dict→Vector2; advance elif Vector2→dict→Vector2). `_deconstructor_move_in_payload` is KEPT (the N2233 test pins its presence) — now takes a `payload_speed` param; the new pure delegates approach+arrival to it, so the math is byte-identical to N2233. Handle intake wired into the tick BEFORE the consumption fold (frame `incoming_payload`/`incoming_source_pos`/`world_pos` inputs, applies only when frame payload is null, **push consumed either way** — N2278 precedent, not N2279's keep-for-retry; divergence documented in the driver). The N2233 advance's else-if branch now calls the move-in pure (Java order preserved). acceptPayload (:104-106) is NOT in this slice (acceptPayload wave). The dump loop (:111-115) is live since N2276 — untouched.

## Commits

Slice `847ac589` (worker-N2291, branch `slice/N2291-payload-deconstructor-deconstructing-fill`, 5 files, +1210/−21, đã push, remote tip verified by ls-remote). Integration cherry-pick `dc9de962` on `integration/wave-advances-8-n2288-n2294` (base 2fcdc554). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 42/42, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (18/24 PASS: deconstructor power-status, should-consume, update-tile N2233, dump N2276, Loader live-fill N2278, Unloader live-fill N2279): all 6 failures are the proof tests, each exactly `AssertionError: unexpectedly None` — 0 other failures. The advance refactor did not break N2233. Full gate (wave advances-8 integration, PID 7543, 03:03–03:24): Ran 6262 tests in 1223.176s, FAILED (failures=242, skipped=5), 0 errors — 242/242 Godot-absent `AssertionError: unexpectedly None` (236 inherited + 6 new proof tests N2288/N2289/N2291/N2292/N2293/N2294; N2290 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+10/+1/+2/+4** → 11865/1738/1672/3136 (scope estimated +8 symbols — the brief's own return spec gives the move-in pure 6 keys including `accum_after`, so 4+6=10); audit stays 1336. Shards touched: `payload_api_contracts.json`, `payload_slices.json`. DEFERRED 314 (313 − 1 resolved: live deconstructing fill + 2 new: incoming-payload live source, handlePayload live positioning; entry 12 updated in place — handlePayload live since N2291, acceptPayload/acceptUnitPayload still deferred, intake guard is null-check-only). Merged wave DEFERRED: 321 entries (DEFERRED-after-advances-8.py) — 313 − 8 resolved/removed + 16 new, resolved by entry TEXT not number.

## Godot debt

`C07PayloadDeconstructorDeconstructingFillProof` — 6 keys: handle_sets_payload_and_clears_accum, move_in_approaches_zero, handoff_sets_deconstructing_on_arrival, no_handoff_before_arrival, no_handoff_without_payload, live_tick_fills_deconstructing (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.

**Flag (not this slice):** pre-existing driver comments cite the PayloadBlock fields as :94/:95/:96 — actual is **:92/:94/:95** (`payload` :92, `payVector` :94, `payRotation` :95; the Loader cites :92 correctly). The worker's new code cites the correct lines but did NOT fix the pre-existing comments elsewhere in the file (out of scope — flagged for a cleanup slice).
