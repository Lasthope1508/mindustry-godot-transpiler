# N1257 TractorBeamBuild.updateTile Status Apply Finalize

## Scope

- Slice: `N1257`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() status apply`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_status_apply_state`
- Generated owner: `TractorBeamTurret.TractorBeamBuild.updateTile.status_apply`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state`

## Source Evidence

```java
public StatusEffect status = StatusEffects.none;
public float statusDuration = 300;
```

```java
if(Angles.within(rotation, dest, shootCone)){
    if(damage > 0){
        target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));
    }

    if(status != StatusEffects.none){
        target.apply(status, statusDuration);
    }

    any = true;
```

```java
public void apply(StatusEffect effect, float duration){
    if(effect == StatusEffects.none || effect == null || isImmune(effect)) return; //don't apply empty or immune effects
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1257 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1257.
- [x] Added RED status assertion for `N1257`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `status_apply_result`.
- [x] Added RED emitter assertion for generated return key `status_is_none`.
- [x] Focused emitter RED failed for expected reason: generated return omitted `status_is_none`.
- [x] Added RED SSOT assertion for contract/schema `status_is_none`.
- [x] Focused SSOT RED failed for expected reason: contract return keys omitted `status_is_none`.
- [x] Flipped `N1257` status to `done` in canonical ledger and shard mirrors.
- [x] Added `status_apply_result` subset in `PortGame.gd`.
- [x] Exposed generated `status_is_none` return key from the existing source-derived local.
- [x] Registered `status_is_none` in API contract and result state schema canonical/shard mirrors.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused GREEN passed for emitter generated return key.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1257` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_status_apply_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state`
  - Result: failed as expected because `var status_apply_result := {` was missing.
- Emitter RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_tractor_beam_turret_build_update_tile_status_apply_to_source_state`
  - Result: failed as expected because generated return omitted `"status_is_none": status_is_none`.
- SSOT RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_status_apply_slice_is_registered_with_source_backing`
  - Result: failed as expected because contract `return_keys` omitted `status_is_none`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_status_apply_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Emitter GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_emitter.py -q -k test_emit_bridges_tractor_beam_turret_build_update_tile_status_apply_to_source_state`
  - Result: `1 passed, 538 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k status_apply`
  - Result: `6 passed, 4011 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state(...)` guard off: `matches=true`, `status_gate_evaluated=false`, `status_gate=false`, `status_apply_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state(...)` status none: `matches=true`, `status_gate_evaluated=true`, `status_is_none=true`, `status_gate=false`, `status_apply_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state(...)` active status: `matches=true`, `status_gate=true`, `status_apply_call.call="target.apply(status, statusDuration);"`, `status_apply_call.status="burning"`, `status_apply_call.duration=300.0`.
  - Result keys were limited to N1257 status-apply fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1257")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_api_contract_state("PortGame.source_tractor_beam_turret_build_update_tile_status_apply_state")`: `entry.return_keys` includes `status_is_none`.
  - TCP `/root/Main.source_state_schema_state("source_tractor_beam_turret_build_update_tile_status_apply_result")`: `entry.keys.status_is_none.java_expr="status == StatusEffects.none"`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 419.73s (0:06:59)`.

## Progress

- Total source-backed slices: `1073`
- Done: `954`
- Not done: `119`
- Source-backed remaining: `81`
- Other remaining: `38`
- Progress: `88.91%`
- Remaining: `11.09%`
- Current sequence next slice: `N1258 TractorBeamBuild.updateTile() any true`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_any_true_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
