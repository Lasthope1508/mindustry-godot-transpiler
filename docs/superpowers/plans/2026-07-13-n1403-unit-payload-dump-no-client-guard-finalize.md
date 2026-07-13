# N1403 UnitPayload Dump No Client Guard Finalize

## Scope

- Slice: `N1403`
- Title: `Generated UnitPayload dump no-client guard bridge state`
- Java source: `core/src/mindustry/world/blocks/payloads/UnitPayload.java`
- Java method: `UnitPayload.dump()`
- Godot owner: `PortGame.source_unit_payload_dump_no_client_guard_state`
- Generated owner: `UnitPayload.java_method_dump_13`
- Runtime proof: `/root/Main.generated_unit_payload_dump_no_client_guard_bridge_state`

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
- [x] Read design spec and SSOT entries for `N1403`.
- [x] Read exact upstream Java `UnitPayload.java`.
- [x] Confirmed `PortGame.source_unit_payload_dump_no_client_guard_state` is backed by exact source expressions.
- [x] Confirmed generated `UnitPayload.java_method_dump_13` bridges to canonical no-client guard state with slice projection.
- [x] Added RED status assertion for `N1403`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED projected-bridge assertion after runtime exposed full-method superset mismatch.
- [x] Focused RED failed for expected reason: projected bridge comparison was missing.
- [x] Flipped `N1403` status to `done` in canonical ledger and shard mirrors.
- [x] Updated generated bridge proof to compare canonical slice keys against full generated result.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused source helper and generated bridge tests passed.
- [x] Focused upstream parity test passed.
- [x] Focused emitter test passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1403` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed type-null, can-create, solid, overlap, client, and server fallthrough paths.
- [x] Godot TCP generated bridge proof confirmed no-client guard and early guard cases with `matches=true`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_dump_no_client_guard_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Projected bridge RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_unit_payload_dump_no_client_guard_bridge_state`
  - Result: failed as expected because projected bridge comparison was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_generated_unit_payload_dump_no_client_guard_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper and generated bridge:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k "source_unit_payload_dump_no_client_guard or generated_unit_payload_dump_no_client_guard"`
  - Result: `2 passed, 1543 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k unit_payload_dump_no_client_guard`
  - Result: `1 passed, 842 deselected`.
- Focused emitter:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k unit_payload_dump_no_client_guard`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k unit_payload_dump_no_client_guard`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 388.08s (0:06:28)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N1403")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_unit_payload_dump_no_client_guard_state(true, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false)`: `dump=true`, `returned=true`, `net_client_evaluated=false`.
  - TCP `/root/Main.source_unit_payload_dump_no_client_guard_state(false, false, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false)`: `can_create_guard=true`, `dump=false`, `overlayTime_after=1`.
  - TCP `/root/Main.source_unit_payload_dump_no_client_guard_state(false, true, true, 0.0, 16.0, 24.0, true, false, 10.0, 0, false)`: `solid_guard=true`, `dump=false`.
  - TCP `/root/Main.source_unit_payload_dump_no_client_guard_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 2, false)`: `overlap_guard=true`, `dump=false`.
  - TCP `/root/Main.source_unit_payload_dump_no_client_guard_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, true)`: `client_guard=true`, `dump=true`, `deferred_remaining_dump=false`.
  - TCP `/root/Main.source_unit_payload_dump_no_client_guard_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false)`: `returned=false`, `deferred_remaining_dump=true`, `dump=null`.
  - TCP `/root/Main.generated_unit_payload_dump_no_client_guard_bridge_state(false, true, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, true)`: `matches=true`, `result.dump=true`, `canonical.dump=true`.
  - TCP `/root/Main.generated_unit_payload_dump_no_client_guard_bridge_state(false, false, false, 0.0, 16.0, 24.0, false, false, 10.0, 0, false)`: `matches=true`, `result.dump=false`, `canonical.dump=false`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1039`
- Not done: `34`
- Source-backed remaining: `34`
- Active remaining: `0`
- Progress: `96.83%`
- Remaining: `3.17%`
- Current next active slice: none
- Current next active status: none
- Current next active owner: none
