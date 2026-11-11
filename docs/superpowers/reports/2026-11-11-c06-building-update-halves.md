# Report — N2126: BuildingComp.update() live-loop halves (belt timeScale + conduit updateTile gate)

Date: 2026-11-11. Batch: N2126 (single slice). Status: built, registered, proof 21/21 verified, test module 4/4 standalone. **Targeted gate re-run 5601 OK; full Python suite 5601 OK.**

## What changed

`BuildingComp.update()` (BuildingComp.java:2262-2277) decays each building's `timeScaleDuration` per tick (resetting `timeScale` to 1f on expiry) and runs `updateTile()` only when `enabled || !block.noUpdateDisabled`. The decay already ran live, but neither half reached the tick drivers that consume the values — N2126 wires each half where it bites:

- **Belt:** the wrapper reads each belt sprite's live per-building timeScale and the advance now moves items by `speed * delta * time_scale` (`moved = speed * edelta()`, Conveyor.java:266), so a boosted belt moves faster until its duration expires.
- **Conduit:** the tick reads the conduit frame's `enabled` flag and applies the gate (Conduit.java:53 sets `noUpdateDisabled`); a disabled conduit returns `update_tile_called: false` with its liquid, smoothLiquid and flow timer untouched.

## Verified numbers

- Godot proof `C06BuildingUpdateProof`: **21/21 true** (`matches: true`, 0 false). Belt at timeScale 2.0 advances 0.06/tick; expiry resets it to 1.0 and the advance returns to 0.03/tick. Disabled conduit flows 0.0 with timers frozen; re-enabling swaps the water forward; over 120 live ticks a disabled conduit accumulates pump water while its downstream starves, then drains when re-enabled.
- Test module `test_c06_building_update_halves.py`: **4/4 OK standalone in 26.636s**; the affected existing modules (`test_conveyor_advance_binding`, `test_conduit_update_binding`) pass too — 10 tests OK in 52.075s.
- SSOT +2/+1/+0/+0 → **11232 / 1577 / 1500 / 2791**; audit stays 1335. All 77 shards equal a fresh `build_extension_shard`.
- Suite size: 5597 + 4 new tests = **5601** expected.

## Deferred

A disabled belt still advances (Java reads efficiency 0 for it, but the port carries no per-belt efficiency yet); the battery's live `enabled` stamp; the shouldConsumePower half for a failed non-power consumer; `ConsumeItemDynamic.trigger`; UnitAssembler plan dynamics; source-exhaustion/output-full acts. C06–C12 remain open.

See `handoffs/2026-11-11-c06-building-update-halves-handoff.md` for the full detail.

## Gate / suite

- Targeted gate: first run FAILED 1 (Godot MCP port 7777 flake — proof JSON matches:true, all checks true); re-run **5601 tests OK in 1931.790s** (`targeted-n2126-rerun.log`).
- Full Python suite: **5601 tests OK in 1915.753s** (`full-suite-n2126.log`).
