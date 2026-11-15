# N2291 PayloadDeconstructor Deconstructing Fill — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-8, integration branch `integration/wave-advances-8-n2288-n2294`, base `2fcdc554`).

## What this slice did

PayloadDeconstructor live deconstructing fill: handlePayload intake + moveInPayload(false) handoff. 2 pures (handle + move-in/handoff → 2 contracts + 4 schemas).

## Key facts for the next agent

- handlePayload: super (PayloadBlock.java:121-127) then `accum = null;` (PayloadDeconstructor.java:98-101).
- Handoff: `else if(moveInPayload(false) && payload != null){ accum = new float[...]; deconstructing = payload; payload = null; progress = 0f; }` (PayloadDeconstructor.java:197-202).
- moveInPayload boolean overload is **:186-197** (not :181-199); updatePayload is **:174-178** (not :174-179). **The Deconstructor calls moveInPayload(FALSE) — NO rotation.**
- hasArrived = `payVector.isZero(0.01f)` (PayloadBlock.java:242-244). Move-in uses SCALED delta (advance passes source_delta × time_scale).
- **Frame keeps Vector2 pay_vector; new pures speak dict** (the N2233 proof pins Vector2) — conversion at both boundaries. `_deconstructor_move_in_payload` is KEPT (the N2233 test pins its presence); the new pure delegates approach+arrival to it.
- Intake drops the push either way (N2278 precedent, not N2279's keep-for-retry).
- acceptPayload (:104-106) is NOT in this slice (acceptPayload wave). The dump loop (:111-115) is live since N2276.
- Flag: pre-existing driver comments cite PayloadBlock fields :94/:95/:96 — actual is **:92/:94/:95** (not fixed, out of scope — cleanup slice).
- SSOT **+10/+1/+2/+4** → 11865/1738/1672/3136 (scope estimated +8 symbols — the brief's own return spec gives 4+6=10). Exact-evidence 42/42. DEFERRED 314 (−1 +2 new; entry 12 updated in place).

## Godot debt (this slice)

`C07PayloadDeconstructorDeconstructingFillProof` — 6 keys: handle_sets_payload_and_clears_accum, move_in_approaches_zero, handoff_sets_deconstructing_on_arrival, no_handoff_before_arrival, no_handoff_without_payload, live_tick_fills_deconstructing (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_payload_deconstructor_deconstructing_fill`. Do NOT mark done until it passes there.
