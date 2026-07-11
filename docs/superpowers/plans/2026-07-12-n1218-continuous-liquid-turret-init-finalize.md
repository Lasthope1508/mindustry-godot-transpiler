# N1218 ContinuousLiquidTurret.init Finalize

## Scope
- Slice: `N1218`
- Java source: `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java`
- Java method: `ContinuousLiquidTurret.init()`
- Godot owner: `PortGame.source_continuous_liquid_turret_init_state`
- Runtime proof: `/root/Main.generated_continuous_liquid_turret_init_bridge_state`

## Source Evidence
- `@Override`
- `public void init(){`
- `consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){`
- `var ammo = ammoTypes.get(b.liquids.current());`
- `return ammo == null ? 1f : 1f / ammo.ammoMultiplier;`
- `if(targetGround){`
- `ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));`
- `super.init();`

## Checklist
- [x] Read `AGENTS.md`.
- [x] Read design spec entry for `N1218`.
- [x] Read SSOT roots and N1218 shard entries.
- [x] Read upstream Java `ContinuousLiquidTurret.init()`.
- [x] Added RED assertion for `N1218.status == done`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1218` status to `done` in canonical ledger and shards.
- [x] Flipped nested `source_slice_ledger_slices.N1218.slice.status` mirror to `done`.
- [x] Focused GREEN passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot debug output stayed clean.
- [x] Godot stop returned clean final errors.

## Verification
- Focused RED:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_continuous_liquid_turret_init_slice_is_registered_with_source_backing`
  - Result: `1 failed, 1064 deselected`
  - Expected failure: `AssertionError: 'active' != 'done'`
- Focused GREEN:
  - Command: same focused pytest command
  - Result: `1 passed, 1064 deselected in 0.48s`
- SSOT validator:
  - Result: `{"module_count":112,"errors":[],"defense_checked":137,"ledger_checked":1073}`
- Full Python suite:
  - Command: `$env:PYTHONPATH='tools/mindustry_godot_transpiler'; python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 384.92s (0:06:24)`
- Godot MCP runtime:
  - Startup: `errors: []`
  - TCP `/root/Main.generated_continuous_liquid_turret_init_bridge_state`: `n1218-null-ammo` returned `matches=true`, `multiplier_result=1`, `consume_amount=0.0166666666666667`, `overlap_update_count=0`, `overlap_after=12`, `super_init_called=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_init_bridge_state`: `n1218-multiplier` returned `matches=true`, `multiplier_result=0.25`, `consume_amount=0.25`, `overlap_update_count=0`, `overlap_after=12`, `super_init_called=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_init_bridge_state`: `n1218-overlap` returned `matches=true`, `multiplier_result=0.5`, `consume_amount=0.5`, `overlap_update_count=2`, `overlap_after=66`, `super_init_called=true`.
  - TCP `/root/Main.generated_continuous_liquid_turret_init_bridge_state`: `n1218-ledger` returned `status=done`, `nested_status=done`, `java_method=ContinuousLiquidTurret.init()`.
  - After TCP: `errors: []`
  - Stop: `finalErrors: []`

## Progress
- Total slices: `1073`
- Done: `915`
- Not done: `158`
- Active: `54`
- Progress: `85.27%`
- Remaining: `14.73%`
- Next slice: `N1219 ContinuousLiquidTurretBuild.shouldActiveSound()`
- Next owner: `PortGame.source_continuous_liquid_turret_build_should_active_sound_state`
- Next status: `active`

## Notes
- Full game is not complete yet.
- This checklist only closes `N1218`.
- Continue with max 1-3 source-backed slices per turn.
