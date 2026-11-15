# N2274 BlockProducer UpdateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 10 — wave advances-6, integration branch `integration/wave-advances-6-n2274-n2280`, base `253151ad`).

## Source

`updateTile()` (BlockProducer.java:107-128 — **not :109-131 as the brief/SCOPE said**): `super.updateTile();` (:108); `var recipe = recipe();` (:109); `boolean produce = recipe != null && efficiency > 0 && payload == null;` (:110); if produce: `progress += buildSpeed * edelta();` (:113); `if(progress >= recipe.buildTime){ consume(); payload = new BuildPayload(recipe, team); payload.block().placeEffect.at(...); payVector.setZero(); progress %= 1f; }` (:115-120); `heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);` (:124); `time += heat * delta();` (:125, not :126); `moveOutPayload();` (:127, not :128). `progress %= 1f` keeps the remainder (not a reset to 0). `buildSpeed = 0.4f` class (BlockProducer.java:22); constructor 0.6f / large-constructor 0.75f (Blocks.java:6662/6674). **The catalog has NO buildSpeed/buildTime** — buildSpeed resolves from a per-def const (0.6/0.75, fallback class 0.4f); buildTime is computed by the Block.init formula (Block.java:1432-1443: Σ amount×item.cost, default 20f, × buildCostMultiplier) from catalog requirements + item costs. **Heat lerp uses RAW Time.delta** (arc Mathf.lerpDelta multiplies progress by Time.delta — N2193 precedent); progress/time use scaled delta/edelta. `moveOutPayload` is PayloadBlock.java:199-228 (the N2231 cite :199-226 is also off by 2). `consume()` removes items per the N2265 recipe stacks (BlockProducer.java:39-55); the N2265 trigger was tested pure but NOT wired live until this slice. placeEffect is presentation — deferred.

## Implementation

`SourceConstructorBuildState.gd`: pure `source_constructor_update_tile_advance_state` → 8 keys {progress, heat, time, payload, pay_vector, pay_rotation, items, consumed} — **8, not the brief's 6**: `items` (consume() must persist the subtracted stacks into the frame, or the trigger wiring is fake) and `pay_rotation` (moveOutPayload rotates every tick and only progresses if the driver persists it — N2231 precedent). The driver runs the advance every tick after the consumption fold; frame keys progress/heat/time/payload/pay_vector/pay_rotation/items persist. moveOutPayload reuses the shared helper SourceBlockProducerMoveOutPayloadState.gd (not modified).

## Commits

Slice `f5d6d862` (worker-N2274, branch `slice/N2274-block-producer-update-tile`, 5 files, +1894/−40, đã push, remote tip verified by ls-remote). Integration cherry-pick `9fb4d2e1` on `integration/wave-advances-6-n2274-n2280` (base 253151ad). No coordinator fix needed for this slice (the wave cite fix d0ea2b64 touched its register's DEFERRED snapshot only).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 60/60, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 4988, launch 01:07 by coordinator lượt 10, done 01:47 +07 16/11): Ran 6210 in 2126.929s, failures=229, skipped=5, 0 errors — 229/229 Godot-absent (222 inherited + 7 new proof tests N2274–N2280). Run 1 (PID 2132, launch 00:31, done 01:07) invalid: Ran 5527, failures=231, errors=15 — all javalang-import (VM restart #6 ~00:27 wiped javalang; reinstalled 0.13.0 at 01:00).

## SSOT / DEFERRED

SSOT single-slice +8/+1/+1/+2 → 11803/1724/1655/3102; audit stays 1336. DEFERRED 290 (290 − 3 resolved: updateTile advance + trigger live wiring + buildSpeed rows + 3 new: explicit-def recipe buildTime, spawned-payload block flags, moveOutPayload live front gather). Merged wave DEFERRED: 298 entries (DEFERRED-after-advances-6.py) — 290 − 9 resolved/removed + 17 new, resolved by entry TEXT not number.

## Godot debt

`C07BlockProducerUpdateTileProof` — 8 keys: progress_accumulates_when_producing, progress_completes_spawns_payload, progress_keeps_remainder_mod_one, heat_lerps_toward_produce, time_accumulates_with_heat, no_progress_without_recipe, move_out_payload_approaches_dest, live_tick_advances_progress (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
