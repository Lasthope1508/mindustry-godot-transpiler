# N1404 UnitPayload Dump Spawn Side Effects Finalize

## Scope

- Slice: `N1404`
- Title: `Generated UnitPayload dump spawn side effects bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/UnitPayload.java`
- Java method: `UnitPayload.dump()`
- Godot owner: `PortGame.source_unit_payload_dump_spawn_side_effects_state`
- Generated owner: `UnitPayload.java_method_dump_13`
- Runtime proof: `/root/Main.generated_unit_payload_dump_spawn_side_effects_bridge_state`

## Source Evidence

```java
@Override
public boolean dump(){
    //TODO should not happen
    if(unit.type == null) return true;

    if(!Units.canCreate(unit.team, unit.type)){
        overlayTime = 1f;
        overlayRegion = null;
        return false;
    }

    //check if unit can be dumped here
    SolidPred solid = unit.solidity();
    if(solid != null){
        Tmp.v1.trns(unit.rotation, 1f);

        int tx = World.toTile(unit.x + Tmp.v1.x), ty = World.toTile(unit.y + Tmp.v1.y);

        //cannot dump on solid blocks
        if(solid.solid(tx, ty)) return false;
    }

    //cannot dump when there's a lot of overlap going on
    if(!unit.type.flying && Units.count(unit.x, unit.y, unit.physicSize() * 1.05f, o -> o.isGrounded() && (o.type.allowLegStep == unit.type.allowLegStep)) > 0){
        return false;
    }

    //no client dumping
    if(Vars.net.client()) return true;

    //prevents stacking
    unit.vel.add(Mathf.range(0.5f), Mathf.range(0.5f));
    unit.add();
    unit.unloaded();
    Events.fire(new UnitUnloadEvent(unit));
    Units.notifyUnitSpawn(unit);

    return true;
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N1404`.
- [x] Read exact upstream Java `UnitPayload.java`.
- [x] Confirmed `PortGame.source_unit_payload_dump_spawn_side_effects_state` is backed by exact source expressions.
- [x] Confirmed generated `UnitPayload.java_method_dump_13` bridges to canonical spawn side effects state.
- [x] Added RED status assertion for `N1404`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N1404` status to `done` in canonical ledger and shard mirrors.
- [x] Fixed mirror status mismatch found by SSOT validator without changing `N1405`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1404` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed spawn side effects after all guards pass.
- [x] Godot TCP source proof confirmed client guard and can-create guard do not spawn.
- [x] Godot TCP generated bridge proof confirmed spawn and client cases with `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_dump_spawn_side_effects_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_dump_spawn_side_effects_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_unit_payload_dump_spawn_side_effects or generated_unit_payload_dump_spawn_side_effects"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k unit_payload_dump_spawn_side_effects`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k unit_payload_dump_spawn_side_effects`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k unit_payload_dump_spawn_side_effects`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 403.23s (0:06:43)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1404")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_unit_payload_dump_spawn_side_effects_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false, 0.25, -0.5, "unit-alpha")`: `spawn_evaluated=true`, `velocity_add_call={call="unit.vel.add(Mathf.range(0.5f), Mathf.range(0.5f));", unit="unit-alpha", x=0.25, y=-0.5}`, `unit_add_called=true`, `unit_unloaded_called=true`, `event_fire_call.unit="unit-alpha"`, `notify_unit_spawn_call.unit="unit-alpha"`, `returned=true`, `dump=true`, `deferred_remaining_dump=false`.
  - TCP `/root/Main.source_unit_payload_dump_spawn_side_effects_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, true, 0.25, -0.5, "unit-alpha")`: `client_guard=true`, `spawn_evaluated=false`, `dump=true`, `unit_add_called=false`.
  - TCP `/root/Main.source_unit_payload_dump_spawn_side_effects_state(false, false, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false, 0.25, -0.5, "unit-alpha")`: `can_create_guard=true`, `spawn_evaluated=false`, `dump=false`, `unit_add_called=false`.
  - TCP `/root/Main.generated_unit_payload_dump_spawn_side_effects_bridge_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false, 0.25, -0.5, "unit-alpha")`: `matches=true`, `result.dump=true`, `canonical.dump=true`, `generated_owner=UnitPayload.java_method_dump_13`.
  - TCP `/root/Main.generated_unit_payload_dump_spawn_side_effects_bridge_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, true, 0.25, -0.5, "unit-alpha")`: `matches=true`, `result.spawn_evaluated=false`, `canonical.spawn_evaluated=false`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1040`
- Not done: `33`
- Source-backed remaining: `33`
- Active remaining: `0`
- Progress: `96.92%`
- Remaining: `3.08%`
- Current next active slice: none
- Current next active status: none
- Current next active owner: none
