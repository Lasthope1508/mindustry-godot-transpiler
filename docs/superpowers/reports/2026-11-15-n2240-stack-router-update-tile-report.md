# N2240 StackRouter updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- StackRouterBuild.updateTile (StackRouter.java:28-70): eff = enabled ? efficiency + baseEfficiency : 0f — DIFFERS from StackConveyor (:268-315, disabled eff 1f); progress += eff (NO delta!); cap = speed; unloading handoff loop via DuctRouter.target() :139-157 (proximity + cdump rotation + acceptItem — live query deferred, explicit targets list).
- Def surge-router (Blocks.java:2255-2268, single def): speed **6f**, baseEfficiency 1f, itemCapacity 10.
- **Scope corrections:** unloading field :25 (not :26), unload `if` :45, current-pick :62-63, empty reset :66-68, def closes Blocks.java:2268; field `current` at DuctRouter.java:80; target() :139-157. **The enabled gate is EXACT** (DuctRouter sets noUpdateDisabled = true :32). `item_order` param added for items.first() (N2225 precedent); charge + unload run the same tick (2 separate `if`s). N2181 driver comments have some drifted line cites (for the cite-cleanup slice).

## Implementation

- `SourceStackRouterBuildState.gd`:
  - Pure `source_stack_router_update_tile_advance_state(frame, ...)` → 6 result symbols: unloading, current, progress, items, handed_off, handed_to.
  - target() live proximity selection + handleItem application deferred (explicit targets list).

## Commits

- Slice `4fb9f447` (worker-N2240 re-spawned after daemon restart ~18:17, branch `slice/N2240-stack-router-update-tile`, 5 files +1108/−7; đã push 18:24, remote tip 4fb9f447).
- Integration cherry-pick `e31f88e0`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +6/+1/+1/+2 → 11574/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 64/64, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2181 power: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +6/+1/+1/+2 → 11574/1676/1599/2989; audit 1336, legacy 0. **NO shard changes.**
- DEFERRED 265 (265 − 1 resolved: StackRouter updateTile advance + 1 new merged live-fill entry, N2226 precedent).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07StackRouterUpdateTileProof` — 6 keys: `current_picks_first_item`, `empty_resets_unloading`, `handoff_drains_current_item`, `live_tick_writes_advance_frame_keys`, `progress_charges_when_full`, `unloading_starts_at_cap`.
