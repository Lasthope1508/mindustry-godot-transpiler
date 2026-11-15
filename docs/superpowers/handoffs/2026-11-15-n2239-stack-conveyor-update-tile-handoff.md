# N2239 StackConveyor updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- StackConveyor eff fold / cooldown reel / link gate / transfer branch / unload branch as a pure advance in `SourceStackConveyorBuildState.gd` (StackConveyor.java:268-315).
- 10 result symbols. moveForward/dump application + live front() query deferred.

## Key facts for the next agent

- **moveForward is at BuildingComp.java:1129-1137** (not in StackConveyor.java).
- Unload precedence: outputRouter=true ALWAYS dumps; the `last_item != null` guard is equivalent because pick :282-284 guarantees lastItem null ⟺ items empty + dump(null) on empty items returns false. poofOut() sets link = −1 when the last item drains; transfer fires even when items are empty if state != stateLoad; `e.items.add` has NO capacity cap; getMaximumAccepted = block.itemCapacity.
- The catalog lacks speed/baseEfficiency/outputRouter → per-def tables (N2219 precedent). The driver passes no-front + move_forward_ok/dump_ok=false and calls the advance for BOTH defs even when disabled (reel-in-when-disabled).
- Register: 69 exact exprs, 0 missing. DEFERRED: 267 (265 − 1 + 3 new: live front() query, live items intake, moveForward/dump application). **NO shard changes.**
- Slice commit `c78168a7` (branch `slice/N2239-stack-conveyor-update-tile`, đã push 18:25); integration cherry-pick `2ad1a270`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07StackConveyorUpdateTileProof` — 6 keys (`cooldown_reels_with_speed_eff_delta`, `disabled_still_reels_but_not_transfers`, `live_tick_writes_advance_frame_keys`, `no_transfer_without_link`, `transfer_moves_all_items_to_front`, `unload_drains_last_item`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
