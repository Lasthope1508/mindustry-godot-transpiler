# N2238 LaunchPad updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-4, integration branch `integration/wave-advances-4-n2235-n2241`, base `706e1cd9`).

## Source

- LaunchPadBuild.updateTile (LaunchPad.java:143-161): launchCounter += edelta; launch when >= launchTime && items.total() >= itemCapacity; LaunchPayload entity + stacks + lifetime 120f; items.clear; launchCounter=0.
- Defs launch-pad (Blocks.java:6790-6798): itemCapacity 100, launchTime **1200f**, acceptMultipleItems true, consumePower 4f; advanced-launch-pad (:6800-6811): launchTime **1800f**, liquidCapacity 40f, consumeLiquid oil 9f/60f (second consumer, NOT in slice), consumePower 8f.
- **Scope corrections: consume() is a no-op for BOTH items AND liquids** on both defs (only ConsumeItems/ConsumeItemDynamic have trigger overrides, Consume.java:50). LaunchPayload is a generated entity from LaunchPayloadComp inside LaunchPad.java:227 (no separate file).

## Implementation

- `SourceLaunchPadBuildState.gd`:
  - Pure `source_launch_pad_update_tile_advance_state(frame, ...)` → 4 result symbols: launched, launched_stacks, launch_counter, items.
  - Sibling N2186 (LaunchPad shouldConsume gate) does NOT exist on this line — per coordinator correction sent 18:22 the worker skipped it; the `items` frame key was added fresh. **Unification flags (for the batch 1–3 unification, see STATUS.md): this slice mirrors N2186's `launch_time` stamp + `launch_counter` tick preservation verbatim** (needed for the advance to work on this base); N2186's inline counter-advance line is superseded by the advance call — N2186's test asserting that inline line must be updated at unification.

## Commits

- Slice `1ed044a3` (worker-N2238 re-spawned after daemon restart ~18:17, branch `slice/N2238-launch-pad-update-tile`, 5 files +1068/−7; đã push 18:23, remote tip 1ed044a3).
- Integration cherry-pick `624ae329`; SSOT gộp `4e2a57e8` (wave advances-4): 11616/1682/1605/3001 (slice riêng +4/+1/+1/+2 → 11572/1676/1599/2989).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 40/40, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2172 power: 3/4 PASS, proof Godot-absent — không regression. (No N2186 gate exists on this line — nothing to check there.)
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 7 module power: Ran 28, 21 PASS + 7 proof Godot-absent, 0 error.
- Full gate wave advances-4: Ran 6021 in 1071.101s, failures=182, skipped=5, 0 errors — 182/182 Godot-absent (175 inherited + 7 new proof tests N2235–N2241).

## SSOT / DEFERRED

- SSOT slice riêng +4/+1/+1/+2 → 11572/1676/1599/2989; audit 1336, legacy 0. **NO shard changes.**
- DEFERRED 267 (265 − 1 resolved: LaunchPad updateTile advance + 3 new: LaunchPayload entity creation, disabled/cheating/no-power advance, launch sound/effects).
- DEFERRED gộp sau wave advances-4: 270 entries (265 − 8 resolved + 13 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07LaunchPadUpdateTileProof` — 6 keys: `launch_clears_items_and_resets`, `launch_counter_advances_with_edelta`, `launch_fires_when_full_and_timed`, `live_tick_writes_advance_frame_keys`, `no_launch_before_launch_time`, `no_launch_when_not_full`.
