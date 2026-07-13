# N1406 UnitPayload Draw Type-Null Finalize

## Scope

- Slice: `N1406`
- Title: `Generated UnitPayload draw type-null guard bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/UnitPayload.java`
- Java method: `UnitPayload.draw()`
- Godot owner: `PortGame.source_unit_payload_draw_type_null_state`
- Generated owner: `UnitPayload.java_method_draw_15`
- Runtime proof: `/root/Main.generated_unit_payload_draw_type_null_bridge_state`

## Source Evidence

```java
@Override
public void draw(){
    //TODO should not happen
    if(unit.type == null) return;

    float e = unit.elevation;
    unit.elevation = 0f;
    Draw.scl(1f, 1f);
    unit.type.draw(unit);
    unit.elevation = e;

    //draw warning
    if(overlayTime > 0){
        float z = Draw.z();
        Draw.z(Layer.groundUnit + 1f);
        var region = overlayRegion == null ? Icon.warning.getRegion() : overlayRegion;
        Draw.color(Color.scarlet);
        Draw.alpha(0.8f * Interp.exp5Out.apply(overlayTime));

        float size = 8f;
        Draw.rect(region, unit.x, unit.y, size, size);

        Draw.reset();

        overlayTime = Math.max(overlayTime - Time.delta/overlayDuration, 0f);
        Draw.z(z);
    }
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1406`.
- [x] Read exact upstream Java `UnitPayload.java`.
- [x] Confirmed `PortGame.source_unit_payload_draw_type_null_state` is backed by exact source expressions.
- [x] Confirmed generated `UnitPayload.java_method_draw_15` bridges to canonical draw type-null state.
- [x] Added RED status assertion for `N1406`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1406` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1407` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1406` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed type-null guard returns before remaining draw.
- [x] Godot TCP source proof confirmed non-null type defers to `float e = unit.elevation;`.
- [x] Godot TCP generated bridge proof confirmed null and continue cases with `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_draw_type_null_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_draw_type_null_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_unit_payload_draw_type_null or generated_unit_payload_draw_type_null"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k unit_payload_draw_type_null`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k unit_payload_draw_type_null`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k unit_payload_draw_type_null`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 433.70s (0:07:13)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1406")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_unit_payload_draw_type_null_state(true)`: `returned_early=true`, `deferred_remaining_draw=false`.
  - TCP `/root/Main.source_unit_payload_draw_type_null_state(false)`: `returned_early=false`, `deferred_remaining_draw=true`, `next_expr="float e = unit.elevation;"`.
  - TCP `/root/Main.generated_unit_payload_draw_type_null_bridge_state(true)`: `matches=true`, `result.returned_early=true`, `canonical.returned_early=true`, `generated_owner=UnitPayload.java_method_draw_15`.
  - TCP `/root/Main.generated_unit_payload_draw_type_null_bridge_state(false)`: `matches=true`, `result.deferred_remaining_draw=true`, `canonical.deferred_remaining_draw=true`, `generated_owner=UnitPayload.java_method_draw_15`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1042`
- Not done: `31`
- Source-backed remaining: `31`
- Active remaining: `0`
- Progress: `97.11%`
- Remaining: `2.89%`
- Current next active slice: none
- Current next active status: none
- Current next active owner: none
