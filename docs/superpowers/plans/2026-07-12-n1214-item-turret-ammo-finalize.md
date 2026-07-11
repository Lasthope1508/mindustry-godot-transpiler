# N1214 ItemTurret.ammo Finalize

## Scope
- Slice: `N1214`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java`
- Java method: `ItemTurret.ammo(Object...)`
- Godot owner: `PortGame.source_item_turret_ammo_state`
- Runtime proof: `/root/Main.generated_item_turret_ammo_bridge_state`

## Source Evidence
- `public ObjectMap<Item, BulletType> ammoTypes = new OrderedMap<>();`
- `/** Initializes accepted ammo map. Format: [item1, bullet1, item2, bullet2...] */`
- `public void ammo(Object... objects){`
- `ammoTypes = OrderedMap.of(objects);`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1214`.
- [x] Read SSOT roots and N1214 shard entries.
- [x] Read upstream Java `ItemTurret.ammo(Object...)`.
- [x] Added RED assertion for `N1214.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1214` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1214.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_item_turret_ammo_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.47s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 400.23s (0:06:40)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_item_turret_ammo_bridge_state([])`: `matches=true`, `ammo_types_after=[]`.
  - TCP `/root/Main.generated_item_turret_ammo_bridge_state([{item:"copper"}, {bullet:"standardCopper"}])`: `matches=true`, `ammo_types_after` preserves input order.
  - TCP `/root/Main.generated_item_turret_ammo_bridge_state([{item:"copper"}, {bullet:"standardCopper"}, {item:"graphite"}, {bullet:"standardDense"}])`: `matches=true`, `ammo_types_after` preserves input order.
  - TCP `/root/Main.ssot_slice_ledger_state("N1214")`: `status=done`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `911`
- Not done: `162`
- Active: `58`
- Progress: `84.90%`
- Remaining: `15.10%`
- Next slice: `N1215 ContinuousTurret.setStats()`
- Next owner: `PortGame.source_continuous_turret_set_stats_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1214`.
- Continue with max 1-3 source-backed slices per turn.
