# N1309 Block InitBuilding Default Finalize

## Scope

- Slice: `N1309`
- Title: `Generated Block initBuilding default bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.initBuilding()`
- Godot owner: `PortGame.source_block_init_building_default_state`
- Generated owner: `Block.java_method_initBuilding_117`
- Runtime proof: `/root/Main.generated_block_init_building_default_bridge_state`

## Source Evidence

```java
protected void initBuilding(){
    //attempt to find the first declared class and use it as the entity type
    try{
        ...
    }catch(Throwable ignored){
    }

    if(buildType == null){
        //assign default value
        buildType = Building::create;
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1309`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_initBuilding_117` preserves `protected void initBuilding(){`, `try{`, `}catch(Throwable ignored){`, `if(buildType == null){`, `//assign default value`, `buildType = Building::create;`, and `buildType` input.
- [x] Added RED status assertion for `N1309`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1309` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper test passed.
- [x] Focused generated bridge test passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1309` canonical and nested status are `done`.
- [x] Godot TCP null buildType proof confirmed `default_assigned=true`, `build_type_after=Building::create`, `default_guard_expr=if(buildType == null){`, and `default_assignment_expr=buildType = Building::create;`.
- [x] Godot TCP existing buildType proof confirmed `default_assigned=false` and existing value preserved.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for null and existing buildType cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_building_default_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_building_default_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_block_init_building_default_state`
  - Result: `1 passed, 1544 deselected`.
- Focused generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_block_init_building_default_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k test_block_init_building_default_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_block_init_building_default_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k block_init_building_default`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.27s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1309")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_building_default_state(null)`: `default_assigned=true`, `build_type_after=Building::create`, `default_guard_expr=if(buildType == null){`, `default_assignment_expr=buildType = Building::create;`.
  - TCP `/root/Main.source_block_init_building_default_state({"factory":"custom_build_type"})`: `default_assigned=false`, `build_type_after={"factory":"custom_build_type"}`.
  - TCP `/root/Main.generated_block_init_building_default_bridge_state(null)`: `matches=true`, result `default_assigned=true`, result `build_type_after=Building::create`.
  - TCP `/root/Main.generated_block_init_building_default_bridge_state({"factory":"custom_build_type"})`: `matches=true`, result `default_assigned=false`, result existing build type preserved.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `987`
- Not done: `86`
- Source-backed remaining: `48`
- Other remaining: `38`
- Progress: `91.99%`
- Remaining: `8.01%`
- Current next source-backed finalize slice: `N1310 Generated Block researchRequirements researchCost bridge state`
- Current next source-backed owner: `PortGame.source_block_research_requirements_research_cost_state`
