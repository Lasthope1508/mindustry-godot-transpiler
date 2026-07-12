# N1268 Ability Add Stats Finalize

## Scope

- Slice: `N1268`
- Title: `Generated Ability addStats bridge state`
- Java source: `core/src/mindustry/entities/abilities/Ability.java`
- Java method: `Ability.addStats(Table t)`
- Godot owner: `PortGame.source_ability_add_stats_state`
- Generated owner: `Ability.java_method_addStats_7`
- Runtime proof: `/root/Main.generated_ability_add_stats_bridge_state`

## Source Evidence

```java
protected static final float descriptionWidth = 350f;
```

```java
public void addStats(Table t){
    if(Core.bundle.has(getBundle() + ".description")){
        t.add(Core.bundle.get(getBundle() + ".description")).wrap().width(descriptionWidth);
        t.row();
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1268`.
- [x] Read exact upstream Java `Ability.java`.
- [x] Confirmed `N1268` ledger status was already `done` before this normalization.
- [x] Confirmed generated `Ability.java_method_addStats_7` preserves explicit `get_bundle_value`, `bundle_has_description`, and `bundle_description` inputs.
- [x] Added RED status assertion for `N1268`.
- [x] Status assertion passed immediately because `N1268` was already `done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `ability_add_stats_result`.
- [x] Added `ability_add_stats_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1268` canonical and nested status are `done`.
- [x] Godot TCP true-guard proof confirmed `matches=true`, `description_key="ability.repairfield.description"`, `guard_passed=true`, `add_description_call.width=350`, and `row_call="t.row();"`.
- [x] Godot TCP false-guard proof confirmed `matches=true`, `description_key="ability.empty.description"`, `guard_passed=false`, and both `add_description_call` and `row_call` are `null`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused status check:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_add_stats_slice_is_registered_with_source_backing`
  - Result before GREEN: `1 passed, 1064 deselected` because `N1268` was already `done`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_add_stats_bridge_state`
  - Result: failed as expected because `var ability_add_stats_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_add_stats_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_add_stats_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k ability_add_stats`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 384.13s (0:06:24)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1268")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_ability_add_stats_bridge_state({"id":"stats-table","children":0}, "ability.repairfield", true, "Repairs nearby blocks.")`: `matches=true`, `description_key="ability.repairfield.description"`, `guard_passed=true`, `add_description_call.width=350`, `row_call="t.row();"`.
  - TCP `/root/Main.generated_ability_add_stats_bridge_state({"id":"stats-table","children":0}, "ability.empty", false, "")`: `matches=true`, `description_key="ability.empty.description"`, `guard_passed=false`, `add_description_call=null`, `row_call=null`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `964`
- Not done: `109`
- Source-backed remaining: `71`
- Other remaining: `38`
- Progress: `89.84%`
- Remaining: `10.16%`
- Note: progress did not increase in this normalization because `N1268` was already counted as `done`.
- Current first unresolved ledger slice by numeric order: `N1290 Block.removeConsumers(Boolf<Consume>)`
- Current next owner: `PortGame.source_block_remove_consumers_state`
