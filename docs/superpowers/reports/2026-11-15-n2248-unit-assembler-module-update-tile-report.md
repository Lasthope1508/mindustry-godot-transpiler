# N2248 UnitAssemblerModule updateTile Advance (Link + Handoff) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- UnitAssemblerModuleBuild.updateTile() (UnitAssemblerModule.java:132-141): link refresh on tileChanges (findLink :75-83; getLink :65-69; lastChange init −2 :73) + moveInPayload handoff to the linked assembler.
- **Scope corrections (all verified by grep): updateTile is :132-141** (not :129-141 as the brief/scope/N2168 driver said); **getLink is :65-69** (not :64-69); **moduleFits is UnitAssembler.java:338** (not :323 — :323 is the `modules` list). **moveInPayload runs rotate=TRUE** (no-arg delegates to `moveInPayload(true)`) — unlike N2233's deconstructor `moveInPayload(false)` — so the payRotation moveToward branch runs, target rotdeg() since the module sets `rotate = true` (:26). **The assembler-side yeetPayload receive is ALREADY ported** (N2131 intake state, `blocks.add(payload.content(), 1)`), so there is no yeetPayload deferral — instead the handoff→intake *wiring* is the new deferral. No payloadSpeed override in the module (class defaults 0.7f/5f apply). `wasOccupied` default false matches the Java field default (UnitAssembler.java:328).
- Single def basic-assembler-module (Blocks.java:6566, consumePower 3.5f :6568, size 5, tier 1). `tile_changes` default 1 (World.java:35), `last_change` −2.

## Implementation

- `SourceUnitAssemblerModuleBuildState.gd`:
  - Pure `source_unit_assembler_module_update_tile_advance_state(frame, ...)` → 8 result symbols: last_change, link, link_refreshed, pay_vector, pay_rotation, moved_in, payload, handed_off.
  - The handoff clears the module payload and reports handed_off when the assembler accepts (moduleFits + link + power); blocked when occupied or without power.

## Commits

- Slice `0ecf1534` (worker-N2248, branch `slice/N2248-unit-assembler-module-update-tile`, 5 files +885/−4; đã push 19:50, remote tip 0ecf1534).
- Integration cherry-pick `2c3ded1b` (clean); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +8/+1/+1/+2 → 11650/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 56/56, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Sibling N2168: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +8/+1/+1/+2 → 11650/1692/1614/3019; audit 1336, legacy 0. **No shard changes** (no shard selects UnitAssemblerModule.java).
- DEFERRED 284 (283 − 2 + 3: link/findLink + updateTile advance entries resolved/reworded; 2 new: handoff-to-intake wiring, updateTile live fill).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07UnitAssemblerModuleUpdateTileProof` — 6 keys: `link_refreshes_on_tile_change`, `no_refresh_without_change`, `handoff_needs_link_and_fit`, `handoff_clears_payload`, `handoff_blocked_when_occupied`, `handoff_blocked_without_power`.
