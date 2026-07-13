# N465 BulletType Init Type Defaults Finalize

## Scope

- Slice: `N465`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `init()`
- Godot owner: `PortGame.source_bullet_type_init_type_defaults_state`
- Runtime proof: `/root/Main.source_bullet_type_init_type_defaults_state`

## Source Evidence

```java
if(pierceCap >= 1){
    pierce = true;
}
if(setDefaults){
    if(lightning > 0){
        if(status == StatusEffects.none){
            status = StatusEffects.shocked;
        }
    }

    if(fragBullet != null || splashDamageRadius > 0 || lightning > 0){
        despawnHit = true;
    }
}
```

Deferred to later source-backed slices:

```java
if(fragBullet != null){
if(lightningType == null){
if(lightRadius <= -1){
drawSize = Math.max(drawSize, trailLength * speed * 2f);
range = calculateRange();
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N465`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed `PortGame.source_bullet_type_init_type_defaults_state` is backed by exact source expressions.
- [x] Confirmed `N466` remains `source-backed`.
- [x] Added RED status assertion for `N465`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N465` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N465` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed pierce default assignment.
- [x] Godot TCP source proof confirmed default shocked status assignment.
- [x] Godot TCP source proof confirmed default despawnHit assignment.
- [x] Godot TCP source proof confirmed `setDefaults=false` prevents default status/despawnHit assignment.
- [x] Godot TCP regression proof confirmed `N466` frag velocity helper still applies frag velocity defaults.
- [x] Godot debug output returned `errors=[]`.
- [x] Godot stop returned `finalErrors=[]`.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_source_slice_ledger_tracks_registered_source_owners`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k test_source_slice_ledger_tracks_registered_source_owners`
  - Result: `1 passed, 1064 deselected`.
- Focused source helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_init_type_defaults`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_init_type_defaults`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_init_type_defaults_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_init_type_defaults`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 388.95s (0:06:28)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N465")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_bullet_type_init_type_defaults_state({"pierceCap":2,"setDefaults":true,"lightning":3,"status":"none","fragBullet":null,"splashDamageRadius":0,"despawnHit":false})`: `pierceApplied=true`, `statusShockedApplied=true`, `despawnHitApplied=true`, `bulletType.status=shocked`.
  - TCP `/root/Main.source_bullet_type_init_type_defaults_state({"pierceCap":0,"setDefaults":true,"lightning":0,"status":"burning","fragBullet":{"name":"frag"},"splashDamageRadius":0,"despawnHit":false})`: `pierceApplied=false`, `statusShockedApplied=false`, `despawnHitApplied=true`.
  - TCP `/root/Main.source_bullet_type_init_type_defaults_state({"pierceCap":-1,"setDefaults":false,"lightning":5,"status":"none","fragBullet":null,"splashDamageRadius":4,"despawnHit":false})`: `pierceApplied=false`, `statusShockedApplied=false`, `despawnHitApplied=false`.
  - TCP `/root/Main.source_bullet_type_init_frag_velocity_state({"bulletType":{"fragBullet":{"keepVelocity":true,"scaleKeepVelocity":true}}})`: `fragBulletVelocityApplied=true`, `fragBullet.keepVelocity=false`, `fragBullet.scaleKeepVelocity=false`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1059`
- Not done: `14`
- Source-backed remaining: `14`
- Progress: `98.70%`
- Remaining: `1.30%`
- Next slice: `N466`
- Next slice status: `source-backed`
- Next slice Godot owner: `PortGame.source_bullet_type_init_frag_velocity_state`
