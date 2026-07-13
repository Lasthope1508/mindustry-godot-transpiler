# N1408 UnitPayload Draw Overlay Warning Finalize

## Scope

- Slice: `N1408`
- Title: `Generated UnitPayload draw overlay warning bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/UnitPayload.java`
- Java method: `UnitPayload.draw()`
- Godot owner: `PortGame.source_unit_payload_draw_overlay_warning_state`
- Generated owner: `UnitPayload.java_method_draw_15`
- Runtime proof: `/root/Main.generated_unit_payload_draw_overlay_warning_bridge_state`

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
- [x] Read design spec and SSOT entries for `N1408`.
- [x] Read exact upstream Java `UnitPayload.java`.
- [x] Confirmed `PortGame.source_unit_payload_draw_overlay_warning_state` is backed by exact source expressions.
- [x] Confirmed generated `UnitPayload.java_method_draw_15` bridges to canonical overlay warning state.
- [x] Added RED status assertion for `N1408`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1408` status to `done` in canonical ledger and shard mirrors.
- [x] Confirmed `N1409` remains `source-backed`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1408` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed no-overlay branch skips warning draw side effects.
- [x] Godot TCP source proof confirmed null overlay region uses `Icon.warning.getRegion()`.
- [x] Godot TCP source proof confirmed custom overlay region is preserved.
- [x] Godot TCP generated bridge proof confirmed null-region and no-overlay cases with `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_draw_overlay_warning_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_draw_overlay_warning_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_unit_payload_draw_overlay_warning or generated_unit_payload_draw_overlay_warning"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k unit_payload_draw_overlay_warning`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k unit_payload_draw_overlay_warning`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k unit_payload_draw_overlay_warning`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 389.40s (0:06:29)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1408")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_unit_payload_draw_overlay_warning_state(false, 0.65, "unit-alpha", 0.0, null, 16.0, 24.0, 2.0, 50.0, 0.4)`: `overlay_guard=false`, `overlay_time_after=0`, `draw_reset_called=false`.
  - TCP `/root/Main.source_unit_payload_draw_overlay_warning_state(false, 0.65, "unit-alpha", 0.8, null, 16.0, 24.0, 2.0, 50.0, 0.4)`: `overlay_guard=true`, `overlay_region_resolved="Icon.warning.getRegion()"`, `draw_alpha_value=0.32`, `warning_size=8`, `draw_rect_call={region="Icon.warning.getRegion()", x=16, y=24, width=8, height=8}`, `overlay_time_after=0.75`, `draw_z_restore_call={z=50}`.
  - TCP `/root/Main.source_unit_payload_draw_overlay_warning_state(false, 0.65, "unit-alpha", 0.8, "custom-region", 16.0, 24.0, 2.0, 50.0, 0.4)`: `overlay_region_resolved="custom-region"`.
  - TCP `/root/Main.generated_unit_payload_draw_overlay_warning_bridge_state(false, 0.65, "unit-alpha", 0.8, null, 16.0, 24.0, 2.0, 50.0, 0.4)`: `matches=true`.
  - TCP `/root/Main.generated_unit_payload_draw_overlay_warning_bridge_state(false, 0.65, "unit-alpha", 0.0, null, 16.0, 24.0, 2.0, 50.0, 0.4)`: `matches=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1044`
- Not done: `29`
- Source-backed remaining: `29`
- Progress: `97.30%`
- Remaining: `2.70%`
- Next slice: `N1409`
- Next slice status: `source-backed`
- Next slice title: `Generated UnitPayload icon bridge state`
