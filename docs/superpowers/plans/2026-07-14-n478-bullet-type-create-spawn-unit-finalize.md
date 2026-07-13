# N478 BulletType Create Spawn Unit Finalize

## Scope

- Slice: `N478`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)`
- Godot owner: `PortGame.source_bullet_type_create_spawn_unit_state`
- Runtime proof: `/root/Main.source_bullet_type_create_spawn_unit_state`

## Source Evidence

```java
if(spawnUnit != null){
    //don't spawn units clientside!
    if(!net.client()){
        Unit spawned = spawnUnit.create(team);
        spawned.set(x, y);
        spawned.rotation = angle;
        //immediately spawn at top speed, since it was launched
        if(spawnUnit.missileAccelTime <= 0f){
            spawned.vel.trns(angle, spawnUnit.speed);
        }
        //assign unit owner
        if(spawned.controller() instanceof MissileAI ai){
            if(shooter instanceof Unit unit){
                ai.shooter = unit;
            }

            if(shooter instanceof ControlBlock control){
                ai.shooter = control.unit();
            }

        }
        spawned.add();
        Units.notifyUnitSpawn(spawned);
    }
    //Since bullet init is never called, handle killing shooter here
    if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill();

    //no bullet returned
    return null;
}
```

Field source:

```java
public @Nullable UnitType spawnUnit;
public boolean killShooter;
```

Deferred to later source-backed owner already done:

```java
Bullet bullet = Bullet.create();
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N478`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed `PortGame.source_bullet_type_create_spawn_unit_state` is backed by exact source expressions.
- [x] Confirmed `N1423` remains `source-backed`.
- [x] Added RED status assertion for `N478`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N478` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N478` canonical and nested status are `done`.
- [x] Godot TCP proof confirmed no `spawnUnit` continues to normal bullet creation.
- [x] Godot TCP proof confirmed client spawn guard skips spawned unit but still kills owner when `killShooter` applies.
- [x] Godot TCP proof confirmed server spawn creates unit state, set position, rotation, velocity, add, notify.
- [x] Godot TCP proof confirmed `Unit` shooter assigns `MissileAI.shooter`.
- [x] Godot TCP proof confirmed `ControlBlock` shooter assigns `MissileAI.shooter` from `control.unit()`.
- [x] Godot TCP regression proof confirmed `N477` initial gate angle remains `37.0`.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_source_slice_ledger_tracks_registered_source_owners`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Status guard:
  - Command: `python -c "import json; from pathlib import Path ..."`
  - Result: `N1423 source-backed`, `N477 done`, `N478 done`, `N479 done`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_source_slice_ledger_tracks_registered_source_owners`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_create_spawn_unit`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_create_spawn_unit`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_create_spawn_unit_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_create_spawn_unit`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 387.79s (0:06:27)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N478")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP no `spawnUnit`: `spawnUnitBranchEntered=false`, `bulletCreateReturnsNull=false`, `bulletContinues=true`.
  - TCP client spawn guard: `spawnUnitBranchEntered=true`, `spawnSkippedClient=true`, `spawnedUnit=null`, `bulletCreateReturnsNull=true`, `ownerKilled=true`.
  - TCP server spawn: `type=flare-missile`, `team=sharded`, `x=10.0`, `y=20.0`, `rotation=37.0`, `velocity.angle=37.0`, `velocity.speed=3.5`, `missileAIShooter=dagger-1`, `added=true`, `notified=true`, `ownerKilled=true`.
  - TCP ControlBlock shooter: `missileAIShooter=control-unit-7`.
  - TCP `/root/Main.source_bullet_type_create_initial_gate_state(...)` regression: `angle=37.0`, `createChancePassed=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1072`
- Not done: `1`
- Source-backed remaining: `1`
- Progress: `99.91%`
- Remaining: `0.09%`
- Remaining slice ids: `N1423`
- Next slice: `N1423`
- Next slice Godot owner: `PortGame.source_block_producer_build_update_tile_move_out_payload_state`
