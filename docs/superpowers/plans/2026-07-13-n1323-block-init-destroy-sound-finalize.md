# N1323 Block Init DestroySound Finalize

## Scope

- Slice: `N1323`
- Title: `Generated Block init destroySound bridge state`
- Java source: `core/src/mindustry/world/Block.java`
- Java method: `Block.init()`
- Godot owner: `PortGame.source_block_init_destroy_sound_state`
- Generated owner: `Block.java_method_init_123`
- Runtime proof: `/root/Main.generated_block_init_destroy_sound_bridge_state`

## Source Evidence

```java
public void init(){
    super.init();

    if(destroySound == Sounds.unset){
        destroySound =
            size >= 3 ? Sounds.blockExplode3 :
            size >= 2 ? new RandomSound(Sounds.blockExplode2, Sounds.blockExplode2Alt) :
            new RandomSound(Sounds.blockExplode1, Sounds.blockExplode1Alt);
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1323`.
- [x] Read exact upstream Java `Block.java`.
- [x] Confirmed slice rule limits this bridge to destroySound only and does not claim placeSound, breakSound, health, liquid, fog, or other init branches.
- [x] Confirmed generated `Block.java_method_init_123` preserves method boundary, `super.init()`, destroySound guard, assignment, and size branches.
- [x] Added RED status assertion for `N1323`.
- [x] Focused RED failed for expected reason: `active != done`.
- [x] Flipped `N1323` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1324` stayed `active`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1323` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `Sounds.unset` and `size=3` assigns `Sounds.blockExplode3`.
- [x] Godot TCP source proof confirmed `Sounds.unset` and `size=2` assigns `RandomSound(Sounds.blockExplode2, Sounds.blockExplode2Alt)`.
- [x] Godot TCP source proof confirmed `Sounds.unset` and `size=1` assigns `RandomSound(Sounds.blockExplode1, Sounds.blockExplode1Alt)`.
- [x] Godot TCP source proof confirmed custom destroySound stays unchanged.
- [x] Godot TCP generated bridge proof confirmed `matches=true` for size 3, size 2, size 1, and custom cases.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_block_init_destroy_sound_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'active' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -p no:cacheprovider -k test_generated_block_init_destroy_sound_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -p no:cacheprovider -k "test_port_game_exposes_source_block_init_destroy_sound_state or test_port_game_exposes_generated_block_init_destroy_sound_bridge_state"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -p no:cacheprovider -k test_block_init_destroy_sound_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -p no:cacheprovider -k test_emit_bridges_block_init_destroy_sound_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k block_init_destroy_sound`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, 'tools/mindustry_godot_transpiler'); from mindustry_port import source_ssot; report = source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']}); raise SystemExit(1 if report['errors'] else 0)"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 396.79s (0:06:36)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1323")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_block_init_destroy_sound_state("Sounds.unset", 3)`: `destroy_sound_assigned=true`, `destroy_sound_after="Sounds.blockExplode3"`.
  - TCP `/root/Main.source_block_init_destroy_sound_state("Sounds.unset", 2)`: `destroy_sound_assigned=true`, `destroy_sound_after={"type":"RandomSound","sounds":["Sounds.blockExplode2","Sounds.blockExplode2Alt"]}`.
  - TCP `/root/Main.source_block_init_destroy_sound_state("Sounds.unset", 1)`: `destroy_sound_assigned=true`, `destroy_sound_after={"type":"RandomSound","sounds":["Sounds.blockExplode1","Sounds.blockExplode1Alt"]}`.
  - TCP `/root/Main.source_block_init_destroy_sound_state("Custom.destroy", 3)`: `destroy_sound_assigned=false`, `destroy_sound_after="Custom.destroy"`.
  - TCP `/root/Main.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 3)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 2)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_destroy_sound_bridge_state("Sounds.unset", 1)`: `matches=true`.
  - TCP `/root/Main.generated_block_init_destroy_sound_bridge_state("Custom.destroy", 3)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1001`
- Not done: `72`
- Source-backed remaining: `35`
- Active remaining: `37`
- Progress: `93.29%`
- Remaining: `6.71%`
- Current next slice: `N1324 Generated Block init placeSound bridge state`
- Current next status: `active`
- Current next owner: `PortGame.source_block_init_place_sound_state`
