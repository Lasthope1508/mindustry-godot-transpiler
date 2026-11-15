# N2238 LaunchPad updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- LaunchPad counter edelta / full-and-timed launch / stacks copy / items.clear / counter reset as a pure advance in `SourceLaunchPadBuildState.gd` (LaunchPad.java:143-161).
- 4 result symbols. LaunchPayload entity + sound/Fx deferred.

## Key facts for the next agent

- **consume() is a no-op for BOTH items AND liquids** on both defs (only ConsumeItems/ConsumeItemDynamic have trigger overrides, Consume.java:50).
- LaunchPayload is a generated entity from LaunchPayloadComp inside LaunchPad.java:227 (no separate file).
- Sibling N2186 (LaunchPad shouldConsume gate) does NOT exist on this line — the worker skipped it per coordinator correction; the `items` frame key was added fresh.
- **Unification flags (batch 1–3 unification, see STATUS.md): this slice mirrors N2186's `launch_time` stamp + `launch_counter` tick preservation verbatim**; N2186's inline counter-advance line is superseded by the advance call — N2186's test asserting that inline line must be updated at unification.
- Register: 40 exact exprs, 0 missing. DEFERRED: 267 (265 − 1 + 3 new: LaunchPayload entity creation, disabled/cheating/no-power advance, launch sound/effects). **NO shard changes.**
- Slice commit `1ed044a3` (branch `slice/N2238-launch-pad-update-tile`, đã push 18:23); integration cherry-pick `624ae329`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07LaunchPadUpdateTileProof` — 6 keys (`launch_clears_items_and_resets`, `launch_counter_advances_with_edelta`, `launch_fires_when_full_and_timed`, `live_tick_writes_advance_frame_keys`, `no_launch_before_launch_time`, `no_launch_when_not_full`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
