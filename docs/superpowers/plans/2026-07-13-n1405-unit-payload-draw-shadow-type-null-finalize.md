# N1405 UnitPayload DrawShadow Type-Null Finalize

## Scope

- Slice: `N1405`
- Title: `Generated UnitPayload drawShadow type-null guard bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/UnitPayload.java`
- Java method: `UnitPayload.drawShadow(float alpha)`
- Godot owner: `PortGame.source_unit_payload_draw_shadow_type_null_state`
- Generated owner: `UnitPayload.java_method_drawShadow_14`
- Runtime proof: `/root/Main.generated_unit_payload_draw_shadow_type_null_bridge_state`

## Source Evidence

```java
@Override
public void drawShadow(float alpha){
    //TODO should not happen
    if(unit.type == null) return;

    unit.type.drawSoftShadow(unit, alpha);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1405`.
- [x] Read exact upstream Java `UnitPayload.java`.
- [x] Confirmed `PortGame.source_unit_payload_draw_shadow_type_null_state` is backed by exact source expressions.
- [x] Confirmed generated `UnitPayload.java_method_drawShadow_14` bridges to canonical drawShadow state.
- [x] Added RED status assertion for `N1405`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1405` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1406` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1405` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed type-null guard returns before drawing.
- [x] Godot TCP source proof confirmed non-null type records `unit.type.drawSoftShadow(unit, alpha);`.
- [x] Godot TCP generated bridge proof confirmed null and draw cases with `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_draw_shadow_type_null_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_draw_shadow_type_null_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_unit_payload_draw_shadow_type_null or generated_unit_payload_draw_shadow_type_null"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k unit_payload_draw_shadow_type_null`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k unit_payload_draw_shadow_type_null`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k unit_payload_draw_shadow_type_null`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 394.91s (0:06:34)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1405")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_unit_payload_draw_shadow_type_null_state(true, 0.75, "unit-alpha")`: `returned_early=true`, `draw_soft_shadow_called=false`, `draw_soft_shadow_call={}`.
  - TCP `/root/Main.source_unit_payload_draw_shadow_type_null_state(false, 0.75, "unit-alpha")`: `returned_early=false`, `draw_soft_shadow_called=true`, `draw_soft_shadow_call={call="unit.type.drawSoftShadow(unit, alpha);", unit="unit-alpha", alpha=0.75}`.
  - TCP `/root/Main.generated_unit_payload_draw_shadow_type_null_bridge_state(true, 0.75, "unit-alpha")`: `matches=true`, `result.draw_soft_shadow_called=false`, `canonical.draw_soft_shadow_called=false`, `generated_owner=UnitPayload.java_method_drawShadow_14`.
  - TCP `/root/Main.generated_unit_payload_draw_shadow_type_null_bridge_state(false, 0.75, "unit-alpha")`: `matches=true`, `result.draw_soft_shadow_call=canonical.draw_soft_shadow_call`, `generated_owner=UnitPayload.java_method_drawShadow_14`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1041`
- Not done: `32`
- Source-backed remaining: `32`
- Active remaining: `0`
- Progress: `97.02%`
- Remaining: `2.98%`
- Current next active slice: none
- Current next active status: none
- Current next active owner: none
