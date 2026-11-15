# N2245 PayloadMassDriver updateTile Advance Part 1 (Frame + State) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- PayloadDriverBuild.updateTile() frame/state part (PayloadMassDriver.java:155-234): `super.updateTile();` (:156, PayloadBlock:158-162 `payload.update(null, this)` — deferred, no live payload entity); link refresh (:157-158, linkValid :466-468); charge discharge (:161-164); curSize/targetSize (:166-171); effectDelayTimer (:173-183); charging reset (:184); link pos (:186-188); reload decay (:191-192); shooter cleanup (:194-205); state switch (:208-215); dump (:218-229); no-power return (:232-234).
- **Scope corrections (all verified by grep)**: no-power return :232-234 (not :235-237); branches start :236; **updateTile ends :332** (not :347 — :342 is inside updatePayload(), a different method). **Shooter validity is INLINE (:199-202) — NO helper shooterValid like MassDriver — and does NOT check team** (unlike linkValid). `same_block` must match BLOCK-id (the 2 defs are different blocks). Dump payLength is NOT clamped at 0 (Java only flips `loaded`). **Charge/timer use RAW Time.delta** (run even at efficiency 0); reload decay uses edelta.
- Defs payload-mass-driver (Blocks.java:6617-6628: size 3, reload 130f, chargeTime 90f, range 700f, maxPayloadSize 2.5f, consumePower 0.5f) + large (Blocks.java:6629-6639: size 5, chargeTime 100f, range 2100f, maxPayloadSize 4f, consumePower 3f). Class: range 100f, rotateSpeed 5f, length 89/8f, knockback 5f, reload 30f, chargeTime 100f, maxPayloadSize 3.

## Implementation

- `SourcePayloadMassDriverBuildState.gd`:
  - Pure `source_payload_mass_driver_update_tile_advance_state(frame, ...)` → 13 result symbols: link, charge, cur_size, target_size, effect_delay_timer, charging, reload_counter, waiting_shooters, state, pay_length, pay_rotation, pay_vector, loaded. turret_rotation / last_other / payload are read-only in part 1 (written by the N2246 branches / transfer).
  - moveOutPayload (PayloadBlock.java:199-228) ported in PURE vector/rotation form only (dest + payRotation moveToward + payVector.approach through the shared source_payload_move_out_dest / source_vec2_approach helpers) — front() query + pushOutput + dumpPayload / movePayload defer.
  - `_initial_frame` adds turret_rotation (90.0, only READ in part 1), payload (null), last_other (−1 = null) beyond the brief. Driver reads range/reload/size from catalog properties with small-def defaults (700f/130f/3); `rotdeg` from rotation meta × 90. **pay_vector is stored as a {"x":, "y":} dict in the frame** (the N2231 precedent) — the N2246 branches read Vector2, so the tick wiring converts at the boundary (merged at integration, 2 new helpers).

## Commits

- Slice `d995b023` (worker-N2245, branch `slice/N2245-payload-mass-driver-update-tile`, 5 files +1471/−2; đã push 19:50, remote tip d995b023).
- Integration cherry-pick `5573dcd3` (clean); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +13/+1/+1/+2 → 11655/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 87/87 + 25 backed exprs, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2164: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +13/+1/+1/+2 → 11655/1692/1614/3019; audit 1336, legacy 0. **Payload shard CHANGED** (`payload_slices` + `payload_api_contracts`).
- DEFERRED 286 (283 − 1 + 4: updateTile advance entry reworded to the branches half for N2246 + 3 new: effects/sound/shake rows, moveOutPayload world interaction, super.updateTile payload update).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PayloadMassDriverUpdateTileProof` — 6 keys: `charge_discharges_when_idle`, `reload_counter_decays`, `state_switches_to_accepting`, `state_switches_to_shooting`, `dump_unloads_when_idle`, `no_power_skips_branches`.
