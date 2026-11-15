# N2274 BlockProducer UpdateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## What this slice did

BlockProducer/Constructor updateTile advance: progress/heat/time/moveOutPayload. Pure `source_constructor_update_tile_advance_state` → 8 keys (progress, heat, time, payload, pay_vector, pay_rotation, items, consumed). Progress += buildSpeed × edelta when producing; at buildTime → consume recipe stacks (N2265 trigger now wired live), spawn BuildPayload, payVector zero, progress %= 1f (remainder kept); heat lerps toward produce; time += heat × delta; moveOutPayload via the shared helper.

## Key facts for the next agent

- **updateTile() is BlockProducer.java:107-128, not :109-131** — super :108, recipe :109, produce :110, progress += :113, completion :115-120, heat :124, time += :125 (not :126), moveOutPayload :127 (not :128).
- **The catalog has NO buildSpeed/buildTime** — buildSpeed is a per-def const (0.6/0.75, fallback class 0.4f); buildTime is computed by the Block.init formula (Σ amount×item.cost, default 20f, × buildCostMultiplier).
- **Heat lerp uses RAW Time.delta** (Mathf.lerpDelta multiplies progress by Time.delta — N2193 precedent); progress/time use scaled delta/edelta.
- **moveOutPayload is PayloadBlock.java:199-228** (the N2231 cite :199-226 is also off by 2).
- The pure returns 8 keys, not the brief's 6: `items` (consume() must persist subtracted stacks) and `pay_rotation` (moveOutPayload rotates every tick — N2231 precedent).
- SSOT +8/+1/+1/+2 → 11803/1724/1655/3102 (audit 1336). Exact-evidence 60/60. DEFERRED 290 (−3 resolved + 3 new: explicit-def recipe buildTime, spawned-payload block flags, moveOutPayload live front gather).

## Godot debt (this slice)

`C07BlockProducerUpdateTileProof` — 8 keys: progress_accumulates_when_producing, progress_completes_spawns_payload, progress_keeps_remainder_mod_one, heat_lerps_toward_produce, time_accumulates_with_heat, no_progress_without_recipe, move_out_payload_approaches_dest, live_tick_advances_progress (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_block_producer_update_tile`. Do NOT mark done until it passes there.
