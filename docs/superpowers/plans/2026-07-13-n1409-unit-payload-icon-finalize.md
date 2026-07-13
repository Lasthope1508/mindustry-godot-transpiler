# N1409 UnitPayload Icon Finalize

## Scope

- Slice: `N1409`
- Title: `Generated UnitPayload icon bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/UnitPayload.java`
- Java method: `UnitPayload.icon()`
- Godot owner: `PortGame.source_unit_payload_icon_state`
- Generated owner: `UnitPayload.java_method_icon_16`
- Runtime proof: `/root/Main.generated_unit_payload_icon_bridge_state`

## Source Evidence

```java
@Override
public TextureRegion icon(){
    return unit.type.fullIcon;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1409`.
- [x] Read exact upstream Java `UnitPayload.java`.
- [x] Confirmed `PortGame.source_unit_payload_icon_state` is backed by exact source expressions.
- [x] Confirmed generated `UnitPayload.java_method_icon_16` bridges to canonical icon state.
- [x] Added RED status assertion for `N1409`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1409` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1410` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1409` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed `unit.type.fullIcon` input returns as `icon`.
- [x] Godot TCP generated bridge proof confirmed `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_icon_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_icon_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_unit_payload_icon or generated_unit_payload_icon"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k unit_payload_icon`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k unit_payload_icon`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k unit_payload_icon`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 399.62s (0:06:39)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1409")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_unit_payload_icon_state("dagger-full-icon")`: `icon="dagger-full-icon"`, `unit_type_full_icon="dagger-full-icon"`, `return_expr="return unit.type.fullIcon;"`.
  - TCP `/root/Main.generated_unit_payload_icon_bridge_state("dagger-full-icon")`: `matches=true`, `generated_owner="UnitPayload.java_method_icon_16"`, `result.icon="dagger-full-icon"`, `canonical.icon="dagger-full-icon"`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1045`
- Not done: `28`
- Source-backed remaining: `28`
- Progress: `97.39%`
- Remaining: `2.61%`
- Next slice: `N1410`
- Next slice status: `source-backed`
- Next slice title: `Generated BlockProducer icons bridge state`
