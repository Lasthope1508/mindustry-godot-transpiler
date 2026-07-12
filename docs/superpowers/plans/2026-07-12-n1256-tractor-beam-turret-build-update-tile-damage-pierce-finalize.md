# N1256 TractorBeamBuild.updateTile Damage Pierce Finalize

## Scope

- Slice: `N1256`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() damage pierce`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_damage_pierce_state`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state`

## Source Evidence

```java
if(Angles.within(rotation, dest, shootCone)){
    if(damage > 0){
        target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));
    }

    if(status != StatusEffects.none){
```

```java
public float blockDamage(Team team){
    return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;
}
```

```java
void damageContinuousPierce(float amount){
    damagePierce(amount * Time.delta, hitTime <= -20 + hitDuration);
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1256 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1256.
- [x] Added RED status assertion for `N1256`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent deferred-field serialization.
- [x] Focused RED failed for expected reason: missing `damage_pierce_result`.
- [x] Flipped `N1256` status to `done` in canonical ledger and shard mirrors.
- [x] Added `damage_pierce_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1256` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_damage_pierce_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state`
  - Result: failed as expected because `var damage_pierce_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_damage_pierce_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k damage_pierce`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state(...)` guard off: `matches=true`, `damage_gate_evaluated=false`, `damage_gate=false`, `damage_amount=0.0`, `block_damage_call={}`, `damage_continuous_pierce_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state(...)` damage zero: `matches=true`, `damage_gate_evaluated=true`, `damage_gate=false`, `damage_amount=0.0`, `block_damage_call={}`, `damage_continuous_pierce_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state(...)` damage active: `matches=true`, `damage_gate=true`, `damage_amount=1.08`, `block_damage_call.call="state.rules.blockDamage(team)"`, `damage_continuous_pierce_call.call="target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));"`.
  - Result keys were limited to N1256 damage-pierce fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1256")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 382.15s (0:06:22)`.

## Progress

- Total source-backed slices: `1073`
- Done: `953`
- Not done: `120`
- Source-backed remaining: `82`
- Other remaining: `38`
- Progress: `88.82%`
- Remaining: `11.18%`
- Current sequence next slice: `N1257 TractorBeamBuild.updateTile() status apply`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_status_apply_state`
