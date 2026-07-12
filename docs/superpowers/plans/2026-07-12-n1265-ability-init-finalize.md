# N1265 Ability Init Finalize

## Scope

- Slice: `N1265`
- Java source: `core/src/mindustry/entities/abilities/Ability.java`
- Java method: `Ability.init(UnitType type)`
- Godot owner: `PortGame.source_ability_init_state`
- Generated owner: `Ability.java_method_init_4`
- Runtime proof: `/root/Main.generated_ability_init_bridge_state`

## Source Evidence

```java
import mindustry.type.*;
```

```java
public abstract class Ability implements Cloneable{
```

```java
public void init(UnitType type){}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1265`.
- [x] Read exact upstream Java `Ability.java`.
- [x] Confirmed generated `Ability.java_method_init_4` preserves empty body as `no_op=true`.
- [x] Added RED status assertion for `N1265`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `ability_init_result`.
- [x] Flipped `N1265` status to `done` in canonical ledger and shard mirrors.
- [x] Added `ability_init_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1265` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_init_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_init_bridge_state`
  - Result: failed as expected because `var ability_init_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_ability_init_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_ability_init_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k ability_init`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_ability_init_bridge_state({"id":"dagger","name":"Dagger"})`: `matches=true`, `no_op=true`, `method="public void init(UnitType type){}"`, preserved `type`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1265")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.60s (0:06:32)`.

## Progress

- Total source-backed slices: `1073`
- Done: `962`
- Not done: `111`
- Source-backed remaining: `73`
- Other remaining: `38`
- Progress: `89.66%`
- Remaining: `10.34%`
- Current sequence next slice: `N1266 Ability.displayBars(Unit unit, Table bars)`
- Current sequence next owner: `PortGame.source_ability_display_bars_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
