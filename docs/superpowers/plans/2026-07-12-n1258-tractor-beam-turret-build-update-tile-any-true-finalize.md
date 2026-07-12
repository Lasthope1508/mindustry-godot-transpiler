# N1258 TractorBeamBuild.updateTile Any True Finalize

## Scope

- Slice: `N1258`
- Java source: `core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java`
- Java method: `TractorBeamBuild.updateTile() any true`
- Godot owner: `PortGame.source_tractor_beam_turret_build_update_tile_any_true_state`
- Generated owner: `TractorBeamTurret.TractorBeamBuild.updateTile.any_true`
- Runtime proof: `/root/Main.generated_tractor_beam_turret_build_update_tile_any_true_bridge_state`

## Source Evidence

```java
if(Angles.within(rotation, dest, shootCone)){
    if(damage > 0){
        target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));
    }

    if(status != StatusEffects.none){
        target.apply(status, statusDuration);
    }

    any = true;
    target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));
}
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read transpiler design spec.
- [x] Read N1258 SSOT ledger, API contract, state schema, module registration, and shard mirrors.
- [x] Read upstream Java source lines for N1258.
- [x] Added RED status assertion for `N1258`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Added RED bridge subset assertion to prevent whole generated-result serialization.
- [x] Focused bridge RED failed for expected reason: missing `any_true_result`.
- [x] Flipped `N1258` status to `done` in canonical ledger and shard mirrors.
- [x] Added `any_true_result` subset in `PortGame.gd`.
- [x] Focused GREEN passed for source symbol registration.
- [x] Focused GREEN passed for bridge subset.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N1258` canonical and nested status are `done`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.
- [x] Full Python suite passed.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_any_true_slice_is_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Bridge subset RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_any_true_bridge_state`
  - Result: failed as expected because `var any_true_result := {` was missing.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k generated_tractor_beam_turret_build_update_tile_any_true_slice_is_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- Bridge subset GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_generated_tractor_beam_turret_build_update_tile_any_true_bridge_state`
  - Result: `1 passed, 1544 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k any_true`
  - Result: `5 passed, 4012 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge connected to `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_any_true_bridge_state(...)` guard off: `matches=true`, `shoot_within_guard=false`, `any_true_evaluated=false`, `any_after=false`, `any_true_call={}`.
  - TCP `/root/Main.generated_tractor_beam_turret_build_update_tile_any_true_bridge_state(...)` active: `matches=true`, `shoot_within_guard=true`, `any_true_evaluated=true`, `any_after=true`, `any_true_call.call="any = true;"`.
  - Result keys were limited to N1258 any-true fields.
  - TCP `/root/Main.ssot_slice_ledger_state("N1258")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 424.19s (0:07:04)`.

## Progress

- Total source-backed slices: `1073`
- Done: `955`
- Not done: `118`
- Source-backed remaining: `80`
- Other remaining: `38`
- Progress: `89.00%`
- Remaining: `11.00%`
- Current sequence next slice: `N1259 TractorBeamBuild.updateTile() impulse net`
- Current sequence next owner: `PortGame.source_tractor_beam_turret_build_update_tile_impulse_net_state`
- First unresolved ledger slice by numeric order: `N462 updateWeaving(Bullet b)`
