# N1266 Ability Display Bars Finalize

## Scope

- Slice: `N1266`
- Title: `Generated Ability displayBars bridge state`
- Java source: `core/src/mindustry/entities/abilities/Ability.java`
- Java method: `Ability.displayBars(Unit unit, Table bars)`
- Godot owner: `PortGame.source_ability_display_bars_state`
- Generated owner: `Ability.java_method_displayBars_5`
- Runtime proof: `/root/Main.generated_ability_display_bars_bridge_state`

## Source Evidence

```java
import arc.scene.ui.layout.*;
```

```java
import mindustry.gen.*;
```

```java
public abstract class Ability implements Cloneable{
```

```java
public void displayBars(Unit unit, Table bars){}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1266`.
- [x] Read exact upstream Java `Ability.java`.
- [x] Confirmed generated `Ability.java_method_displayBars_5` preserves empty body as `no_op=true`.
- [x] Added RED status assertion for `N1266`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `ability_display_bars_result`.
- [x] Flipped `N1266` status to `done` in canonical ledger and shard mirrors.
- [x] Added `ability_display_bars_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1266` canonical and nested status are `done`.
- [x] Godot TCP bridge proof confirmed `matches=true`, `no_op=true`, exact method string, preserved `unit`, preserved `bars`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_display_bars_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_display_bars_bridge_state`
  - Result: failed as expected because `var ability_display_bars_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_display_bars_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_display_bars_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k ability_display_bars`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 388.23s (0:06:28)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1266")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.generated_ability_display_bars_bridge_state({"id":11,"name":"display-bars-unit"}, {"id":"bars-table","rows":0})`: `matches=true`, `no_op=true`, `method="public void displayBars(Unit unit, Table bars){}"`, preserved `unit`, preserved `bars`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total source-backed slices: `1073`
- Done: `963`
- Not done: `110`
- Source-backed remaining: `72`
- Other remaining: `38`
- Progress: `89.75%`
- Remaining: `10.25%`
- Current sequence next slice: `N1267 Ability.display(Table t)`
- Current sequence next owner: `PortGame.source_ability_display_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
