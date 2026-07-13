# N1356 Block Load Team Regions Finalize

## Scope

- Slice: `N1356`
- Title: `Generated Block load team regions bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.load()`
- Godot owner: `PortGame.source_block_load_team_regions_state`
- Generated owner: `Block.java_method_load_126`
- Runtime proof: `/root/Main.generated_block_load_team_regions_bridge_state`

## Source Evidence

```java
//load specific team regions
teamRegions = new TextureRegion[Team.all.length];
for(Team team : Team.all){
    teamRegions[team.id] = teamRegion.found() && team.hasPalette ? Core.atlas.find(name + "-team-" + team.name, teamRegion) : teamRegion;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1356`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed `PortGame.source_block_load_team_regions_state` is backed by exact source expressions.
- [x] Confirmed generated `Block.java_method_load_126` bridges to canonical team region state.
- [x] Added RED status assertion for `N1356`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1356` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1356` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `Team.all.length` maps to `team_all_length=3`.
- [x] Godot TCP source proof confirmed palette teams use `Core.atlas.find(name-team-name, teamRegion)`.
- [x] Godot TCP source proof confirmed non-palette and missing-team-region fallback to `teamRegion`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_load_team_regions_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_load_team_regions_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_block_load_team_regions or generated_block_load_team_regions"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k block_load_team_regions`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k block_load_team_regions`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_load_team_regions`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 390.42s (0:06:30)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1356")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_block_load_team_regions_state("duo", true, "teamRegion", teams)`: `team_all_length=3`, `team_regions[0]=Core.atlas.find(duo-team-sharded, teamRegion)`, `team_regions[1]=teamRegion`, `team_regions[2]=Core.atlas.find(duo-team-blue, teamRegion)`.
  - TCP `/root/Main.source_block_load_team_regions_state("duo", false, "teamRegion", teams)`: all `team_regions` entries remain `teamRegion`.
  - TCP `/root/Main.generated_block_load_team_regions_bridge_state("duo", true, "teamRegion", teams)`: `matches=true`, `generated_owner=Block.java_method_load_126`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1031`
- Not done: `42`
- Source-backed remaining: `35`
- Active remaining: `7`
- Progress: `96.09%`
- Remaining: `3.91%`
- Current next active slice: `N1357 Generated Block load variant regions bridge state`
- Current next active status: `active`
- Current next active owner: `PortGame.source_block_load_variant_regions_state`
