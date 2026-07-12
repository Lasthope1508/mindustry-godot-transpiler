# N1322 Block PostInit ShownPlanets Finalize

## Scope

- Slice: `N1322`
- Title: `Generated Block postInit shownPlanets bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.postInit()`
- Godot owner: `PortGame.source_block_post_init_shown_planets_state`
- Generated owner: `Block.java_method_postInit_122`
- Runtime proof: `/root/Main.generated_block_post_init_shown_planets_bridge_state`

## Source Evidence

```java
public void postInit(){
    //usually, an empty set of planets is a configuration error. auto-assign based on requirements
    if(requirements.length > 0 && shownPlanets.isEmpty()){
        for(Planet planet : content.planets()){
            if(planet.isLandable()){
                if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){
                    shownPlanets.add(planet);
                }
            }
        }
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1322`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed generated `Block.java_method_postInit_122` preserves method boundary, shownPlanets auto-assign guard, content.planets loop, landable guard, requirements containment guard, and `shownPlanets.add(planet)`.
- [x] Added RED status assertion for `N1322`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1322` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1323` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1322` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed empty requirements keep `auto_assign_guard_passed=false`.
- [x] Godot TCP source proof confirmed non-empty shownPlanets keep `auto_assign_guard_passed=false`.
- [x] Godot TCP source proof confirmed landable planet is added when all requirements are on that planet.
- [x] Godot TCP source proof confirmed non-landable planet is skipped and blocked landable planets are recorded.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for guard-false, add, and blocked cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_post_init_shown_planets_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -p no:cacheprovider -k test_generated_block_post_init_shown_planets_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -p no:cacheprovider -k "test_port_game_exposes_source_block_post_init_shown_planets_state or test_port_game_exposes_generated_block_post_init_shown_planets_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -p no:cacheprovider -k test_block_post_init_shown_planets_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -p no:cacheprovider -k test_emit_bridges_block_post_init_shown_planets_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_post_init_shown_planets`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 387.30s (0:06:27)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1322")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_post_init_shown_planets_state([], [], planets)`: `auto_assign_guard_passed=false`, `shown_planets_after=[]`.
  - TCP `/root/Main.source_block_post_init_shown_planets_state(requirements, ["preset"], planets)`: `auto_assign_guard_passed=false`, `shown_planets_after=["preset"]`.
  - TCP `/root/Main.source_block_post_init_shown_planets_state(requirements, [], planets)`: `auto_assign_guard_passed=true`, `added_planets=["serpulo"]`, `blocked_planets=[{"planet":"tantalos","blocking_requirement_indices":[0,1]}]`.
  - TCP `/root/Main.source_block_post_init_shown_planets_state(blocked_requirements, [], planets)`: `auto_assign_guard_passed=true`, `added_planets=[]`, `blocked_planets` includes `serpulo` and `tantalos`.
  - TCP `/root/Main.generated_block_post_init_shown_planets_bridge_state([], [], planets)`: `matches=true`.
  - TCP `/root/Main.generated_block_post_init_shown_planets_bridge_state(requirements, [], planets)`: `matches=true`.
  - TCP `/root/Main.generated_block_post_init_shown_planets_bridge_state(blocked_requirements, [], planets)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1000`
- Not done: `73`
- Source-backed remaining: `35`
- Active remaining: `38`
- Progress: `93.20%`
- Remaining: `6.80%`
- Current next slice: `N1323 Generated Block init destroySound bridge state`
- Current next status: `active`
- Current next owner: `PortGame.source_block_init_destroy_sound_state`
