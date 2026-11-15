# N2240 StackRouter updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-4, coordinator lượt 4).

## What this slice did

- StackRouter eff fold / progress charge / unload handoff / current pick / empty reset as a pure advance in `SourceStackRouterBuildState.gd` (StackRouter.java:28-70; DuctRouter.target() :139-157).
- 6 result symbols. target() live proximity selection + handleItem application deferred (explicit targets list).

## Key facts for the next agent

- **eff DIFFERS from StackConveyor**: enabled ? efficiency + baseEfficiency : 0f (StackConveyor disabled eff is 1f). progress += eff (NO delta!); cap = speed.
- Cite corrections: unloading field :25 (not :26), unload `if` :45, current-pick :62-63, empty reset :66-68, def closes Blocks.java:2268; field `current` at DuctRouter.java:80.
- **The enabled gate is EXACT** (DuctRouter sets noUpdateDisabled = true :32). `item_order` param added for items.first() (N2225 precedent); charge + unload run the same tick (2 separate `if`s).
- N2181 driver comments have some drifted line cites — for the cite-cleanup slice.
- Register: 64 exact exprs, 0 missing. DEFERRED: 265 (265 − 1 + 1 merged live-fill entry, N2226 precedent). **NO shard changes.**
- Slice commit `4fb9f447` (branch `slice/N2240-stack-router-update-tile`, đã push 18:24); integration cherry-pick `e31f88e0`; SSOT gộp `4e2a57e8` (11616/1682/1605/3001).

## Godot debt (this slice)

- `C07StackRouterUpdateTileProof` — 6 keys (`current_picks_first_item`, `empty_resets_unloading`, `handoff_drains_current_item`, `live_tick_writes_advance_frame_keys`, `progress_charges_when_full`, `unloading_starts_at_cap`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
