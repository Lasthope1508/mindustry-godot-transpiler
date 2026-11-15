# N2231 PayloadLoader updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-3, integration branch `integration/wave-advances-3-n2229-n2234`, base `ff82ab1d`).

## Source

- PayloadLoaderBuild.updateTile (PayloadLoader.java:148-220): super.updateTile = `payload.update(null, this)` (:158-162, NOT modeled — deferred); shouldExport → moveOutPayload else moveInPayload → load items (:163-173, timer-gated loadTime/efficiency, itemsLoaded 8, content-id order, acceptedAny/exporting logic) / liquids (:175-192, flow = min(min(liquidsLoaded * edelta, capacity − current), total)) / battery (:202-213, powerInput = power.status * (basePowerUse + maxPowerConsumption 40f); status += availableInput/cap * edelta; >= 1f → exporting + clamp).
- **PayloadLoader HAS rotate** (`rotate = true;`, PayloadLoader.java:45) — the wave scope's "no rotate" claim was WRONG; moveIn target is rotdeg() (kept as the Java branch via a `block_rotate` param).
- **Default acceptItem is NOT `items.total() < capacity`** — it is `block.consumesItem(item) && items.get(item) < getMaximumAccepted(item)` (BuildingComp.java:864-866). The payload contract adds `accept_item_open` (StorageBlock) / `accept_liquid_open` (LiquidRouter) flags + LiquidVoid.
- `hasArrived` is `len2 < 0.01` (Vec2.isZero compares the SQUARED length against the margin).
- The separate-reject branch in the load loop is only reachable when the payload fills UP during the loop (a payload already full at tick start goes down the shouldExport branch) — the proof fixture handles this.
- PayloadLoader.java:202-213 battery rows are the SAME lines as the advance entry — removing only the advance row would leave a false entry behind (removed together).
- Constants: loadTime 2f, itemsLoaded 8, liquidsLoaded 40f, maxBlockSize 3 (:22-25), maxPowerConsumption 40f, basePowerUse = consPower.usage = 2f (def consumePower 2f, Blocks.java:6686).

## Implementation

- `SourcePayloadLoaderBuildState.gd`:
  - Pure `source_payload_loader_update_tile_advance_state(frame, source_delta, time_scale, load_tick, rotdeg_value, block_rotate, item_order, liquid_names_by_id, front, move_payload_result, base_power_use)` → 14 result symbols: should_export, has_arrived, exporting, pay_vector, pay_rotation, items, liquids, payload, payload_moved, payload_dumped, liquid_flow, power_charged, items_loaded, pushed_output_fraction.
  - shouldExport → moveOut (helper reuse) else moveIn → load items/liquids/power, in Java order. Tick wiring after the consumption fold, **no enabled guard** (PayloadLoader `noUpdateDisabled = false` default, Block.java:170 — Java runs updateTile even when disabled). Driver passes `load_tick=false`, live rotdeg from rotation meta, `block_rotate=true`, `item_order` from catalog, default no-front.
  - **moveOut helper REUSE SUCCESS** via preload (`SourceBlockProducerMoveOutPayloadState.move_out_payload_state`, N2224 precedent): signature matches completely (same PayloadBlock.moveOutPayload, generic params), helper implements the arrival guard dst2 < 0.001² correctly. MoveIn approach reuses the helper's `source_vec2_approach`; rotation reuses `SourceMathState.source_angles_move_toward`; liquids reuse `SourceLiquidModuleState`; items reuse inventory helpers. MoveIn is ported in the driver (no helper exists).
  - `_initial_frame` extended with `exporting` / `pay_vector` / `pay_rotation` / `items` / `liquids` (keeps `"payload": null` for N2208).

## Commits

- Slice `d8f2a916` (worker-N2231, survived VM restart 4, branch `slice/N2231-payload-loader-update-tile`, 5 files +1623/−4; đã push 17:43, remote tip d8f2a916).
- Integration cherry-pick `39b24a9d`; SSOT gộp `b5129382` (wave advances-3): 11568/1675/1598/2987 (slice riêng +14/+1/+1/+2 → 11521/1670/1593/2977).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 132/132, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2162 power + N2208 gate: 6/8 PASS, 2 fail đều là proof Godot-absent — không regression.
- Targeted wave (6 module): Ran 24, 18 PASS + 6 proof Godot-absent. Neighbours 12 module power+gate: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-3: Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors — 175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).

## SSOT / DEFERRED

- SSOT slice riêng +14/+1/+1/+2 → 11521/1670/1593/2977; audit 1336, legacy 0. Payload shards đổi (`payload_slices` + `payload_api_contracts`).
- DEFERRED 263 (260 − 3 resolved: updateTile advance + load params + battery-charge rows + 6 new: load timer cadence, movePayload/dumpPayload application, live front gather, payload acceptItem/acceptLiquid per-type rows, super.updateTile payload update, payload dict contract unify). Kept verbatim: "live payload fill", dynamic power consumer, accept/handle payload rows.
- DEFERRED gộp sau wave advances-3: 265 entries (260 − 14 resolved + 19 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PayloadLoaderUpdateTileProof` — 6 keys: move_in_arrives_at_center, load_items_on_timer_tick, load_liquids_folds_edelta, battery_charges_and_exports_when_full, should_export_folds_flags, move_out_pushes_payload.
