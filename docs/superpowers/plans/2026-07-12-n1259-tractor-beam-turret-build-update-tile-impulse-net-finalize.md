# N1259 TractorBeamBuild.updateTile Impulse Net Finalize

## Scope

- Slice: `N1259`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() impulse net`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_impulse_net_state`
- Generated owner: `TractorBeamTurret.TractorBeamBuild.updateTile.impulse_net`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state`

## Source Evidence

```java
public float force = 0.3f;
public float scaledForce = 0f;
```

```java
any = true;
target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));
```

```java
void impulseNet(Vec2 v){
    impulse(v.x, v.y);

    //manually move units to simulate velocity for remote players
    if(isRemote()){
        float mass = mass();
        move(v.x / mass, v.y / mass);
    }
}
```

```java
public Vec2 limit(float limit){
    return limit2(limit * limit);
}
```

```java
default float dst(Position other){
    return dst(other.getX(), other.getY());
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1259 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1259.
- [x] Read upstream `PhysicsComp.impulseNet(Vec2 v)`.
- [x] Read upstream `Vec2.limit(float limit)`.
- [x] Read upstream `Position.dst(Position other)`.
- [x] Added RED status assertion for `N1259`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `impulse_net_result`.
- [x] Flipped `N1259` status to `done` in canonical ledger and shard mirrors.
- [x] Added `impulse_net_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1259` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_impulse_net_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state`
  - Result: failed as expected because `var impulse_net_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_impulse_net_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k impulse_net`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state(...)` guard off: `matches=true`, `shoot_within_guard=false`, `impulse_net_called=false`, `impulse_net_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state(...)` active: `matches=true`, `shoot_within_guard=true`, `impulse_net_called=true`, `impulse_limit=0.0213483495705504`, `impulse_vector_x=-0.0150955627484771`, `impulse_vector_y=-0.0150955627484771`, `impulse_net_call.call="target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));"`.
  - Result keys were limited to N1259 impulse-net fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1259")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 424.48s (0:07:04)`.

## Progress

- Total source-backed slices: `1073`
- Done: `956`
- Not done: `117`
- Source-backed remaining: `79`
- Other remaining: `38`
- Progress: `89.10%`
- Remaining: `10.90%`
- Current sequence next slice: `N1260 TractorBeamBuild.updateTile() inactive strength`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_inactive_strength_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
