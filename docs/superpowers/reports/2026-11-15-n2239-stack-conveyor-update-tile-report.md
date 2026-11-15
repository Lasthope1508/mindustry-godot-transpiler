# N2239 StackConveyor updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- StackConveyorBuild.updateTile (StackConveyor.java:268-315): eff = enabled ? efficiency + baseEfficiency : 1f — disabled still reels; cooldown reel with RAW delta; link == −1 return; lastItem pick; stateUnload while-loop `&&` binds tighter than `?:`; transfer branch writes the front building's frame; fields state/link/cooldown/lastItem.
- Defs plastanium-conveyor (Blocks.java:2084-2090): speed **4f/60f**, itemCapacity 10, outputRouter true; surge-conveyor (:2237-2250): speed **5f/60f**, outputRouter **false**, baseEfficiency **1f**.
- **Scope corrections: moveForward is at BuildingComp.java:1129-1137** (not in StackConveyor.java). Unload precedence verified: outputRouter=true ALWAYS dumps; the `last_item != null` guard is equivalent because pick :282-284 guarantees lastItem null ⟺ items empty + dump(null) on empty items returns false. poofOut() sets link = −1 when the last item drains; transfer fires even when items are empty if state != stateLoad; `e.items.add` has NO capacity cap; getMaximumAccepted = block.itemCapacity; the catalog lacks speed/baseEfficiency/outputRouter → per-def tables (N2219 precedent). The driver passes no-front + move_forward_ok/dump_ok=false and calls the advance for BOTH defs even when disabled (reel-in-when-disabled).

## Implementation

- `SourceStackConveyorBuildState.gd`:
  - Pure `source_stack_conveyor_update_tile_advance_state(frame, ...)` → 10 result symbols: cooldown, link, last_item, items, unloaded, transferred, front_items, front_last_item, front_link, front_cooldown.
  - moveForward / dump application + live front() query deferred (explicit front dict, N2225 precedent).

## Commits

- Slice `c78168a7` (worker-N2239 re-spawned after daemon restart ~18:17, branch `slice/N2239-stack-conveyor-update-tile`, 5 files +1278/−3; đã push 18:25, remote tip c78168a7).
- Integration cherry-pick `2ad1a270`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +10/+1/+1/+2 → 11578/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 69/69, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2180 power: 3/4 PASS, proof Godot-absent — không regression. (Driver calls the advance for both defs even when disabled — N2180 power proof still passes.)
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +10/+1/+1/+2 → 11578/1676/1599/2989; audit 1336, legacy 0. **NO shard changes.**
- DEFERRED 267 (265 − 1 resolved: StackConveyor updateTile advance + 3 new: live front() query, live items intake, moveForward/dump application).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07StackConveyorUpdateTileProof` — 6 keys: `cooldown_reels_with_speed_eff_delta`, `disabled_still_reels_but_not_transfers`, `live_tick_writes_advance_frame_keys`, `no_transfer_without_link`, `transfer_moves_all_items_to_front`, `unload_drains_last_item`.
