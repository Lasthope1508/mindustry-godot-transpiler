# N1267 Ability Display Finalize

## Scope

- Slice: `N1267`
- Title: `Generated Ability display bridge state`
- Java source: `core/src/mindustry/entities/abilities/Ability.java`
- Java method: `Ability.display(Table t)`
- Godot owner: `PortGame.source_ability_display_state`
- Generated owner: `Ability.java_method_display_6`
- Runtime proof: `/root/Main.generated_ability_display_bridge_state`

## Source Evidence

```java
import arc.scene.ui.layout.*;
```

```java
import mindustry.ui.*;
```

```java
public void display(Table t){
    t.table(Styles.grayPanel, a -> {
        a.add("[accent]" + localized()).padBottom(4).center().top().expandX();
        a.row();
        a.left().top().defaults().left();
        addStats(a);
    }).pad(5).margin(10).growX().top().uniformX();
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1267`.
- [x] Read exact upstream Java `Ability.java`.
- [x] Confirmed generated `Ability.java_method_display_6` preserves table, localized title, row/defaults, addStats dispatch, and outer table chain.
- [x] Added RED status assertion for `N1267`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `ability_display_result`.
- [x] Flipped `N1267` status to `done` in canonical ledger and shard mirrors.
- [x] Added `ability_display_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1267` canonical and nested status are `done`.
- [x] Godot TCP bridge proof confirmed `matches=true`, exact method string, `title_text="[accent]Repair Field"`, `table_mutation=true`, and preserved `table`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_display_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_display_bridge_state`
  - Result: failed as expected because `var ability_display_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_display_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_display_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k ability_display`
  - Result: `10 passed, 4007 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 383.07s (0:06:23)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1267")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_ability_display_bridge_state({"id":"display-table","children":0}, "Repair Field")`: `matches=true`, `method="public void display(Table t){"`, `title_text="[accent]Repair Field"`, `table_mutation=true`, preserved `table`.
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
- Current sequence next slice: `N1268 Ability.addStats(Table t)`
- Current sequence next owner: `PortGame.source_ability_add_stats_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
