# N2248 UnitAssemblerModule updateTile Advance (Link + Handoff) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- UnitAssemblerModule link refresh + moveInPayload handoff as a pure advance in `SourceUnitAssemblerModuleBuildState.gd` (UnitAssemblerModule.java:132-141): link refresh on tileChanges + handoff to the linked assembler.
- 8 result symbols: last_change, link, link_refreshed, pay_vector, pay_rotation, moved_in, payload, handed_off.

## Key facts for the next agent

- **Verified line numbers**: updateTile :132-141 (not :129-141), getLink :65-69 (not :64-69), moduleFits UnitAssembler.java:338 (not :323 — :323 is the `modules` list).
- **moveInPayload runs rotate=TRUE** (no-arg delegates to `moveInPayload(true)`) — unlike N2233's deconstructor `moveInPayload(false)` — so the payRotation moveToward branch runs, target rotdeg() (the module sets `rotate = true` :26).
- **The assembler-side yeetPayload receive is ALREADY ported** (N2131 intake state) — the remaining deferral is the handoff→intake *wiring*, not yeetPayload itself. No payloadSpeed override (class defaults 0.7f/5f). `tile_changes` default 1 (World.java:35), `last_change` −2.
- Register: 56 exact exprs, 0 missing. DEFERRED: 284 (link/findLink + updateTile advance resolved/reworded + 2 new: handoff-to-intake wiring, updateTile live fill). **No shard changes**.
- Slice commit `0ecf1534` (branch `slice/N2248-unit-assembler-module-update-tile`, đã push 19:50); integration cherry-pick `2c3ded1b`; SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07UnitAssemblerModuleUpdateTileProof` — 6 keys (`link_refreshes_on_tile_change`, `no_refresh_without_change`, `handoff_needs_link_and_fit`, `handoff_clears_payload`, `handoff_blocked_when_occupied`, `handoff_blocked_without_power`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
