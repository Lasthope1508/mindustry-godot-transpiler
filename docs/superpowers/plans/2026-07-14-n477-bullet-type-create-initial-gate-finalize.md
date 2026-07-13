# N477 BulletType Create Initial Gate Finalize

## Scope

- Slice: `N477`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)`
- Godot owner: `PortGame.source_bullet_type_create_initial_gate_state`
- Runtime proof: `/root/Main.source_bullet_type_create_initial_gate_state`

## Source Evidence

```java
public @Nullable Bullet create(
    @Nullable Entityc owner, @Nullable Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl,
    float lifetimeScl, Object data, @Nullable Mover mover, float aimX, float aimY, @Nullable Teamc target
){
    angle += angleOffset + Mathf.range(randomAngleOffset);

    if(!Mathf.chance(createChance)) return null;
    if(ignoreSpawnAngle) angle = 0;
    if(spawnUnit != null){
```

Field/default source:

```java
public float angleOffset = 0f, randomAngleOffset = 0f;
public float createChance = 1;
public boolean ignoreSpawnAngle = false;
```

Arc `Mathf` expressions registered in SSOT for this slice:

```java
return random(-range, range);
return d >= 1f || rand.nextFloat() < d;
```

Finalized in this slice:

```java
angle += angleOffset + Mathf.range(randomAngleOffset);
if(!Mathf.chance(createChance)) return null;
if(ignoreSpawnAngle) angle = 0;
```

Deferred to later source-backed slices:

- `if(spawnUnit != null){`

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N477`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed `PortGame.source_bullet_type_create_initial_gate_state` is backed by exact source expressions.
- [x] Confirmed `N1423` and `N478` remain `source-backed`.
- [x] Added RED status assertion for `N477`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N477` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N477` canonical and nested status are `done`.
- [x] Godot TCP proof confirmed angle uses `angle + angleOffset + randomAngleOffset`.
- [x] Godot TCP proof confirmed createChance failure returns null.
- [x] Godot TCP proof confirmed `ignoreSpawnAngle` resets angle to `0.0`.
- [x] Godot TCP proof confirmed prior non-continuing create state returns null without creating.
- [x] Godot TCP regression proof confirmed `N476` heals still returns `true` for positive `healAmount`.
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
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_create_initial_gate`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_create_initial_gate`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_create_initial_gate_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_create_initial_gate`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 381.51s (0:06:21)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N477")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_bullet_type_create_initial_gate_state(...)` with `angle=30`, `angleOffset=5`, `randomAngleOffset=2`, `createChance=1`: `angle=37.0`, `createChancePassed=true`, `bulletCreateReturnsNull=false`.
  - TCP `/root/Main.source_bullet_type_create_initial_gate_state(...)` with `createChance=0.25`, `createChanceRoll=0.75`: `createChancePassed=false`, `bulletCreateReturnsNull=true`.
  - TCP `/root/Main.source_bullet_type_create_initial_gate_state(...)` with `ignoreSpawnAngle=true`: `angle=0.0`, `ignoreSpawnAngleApplied=true`.
  - TCP `/root/Main.source_bullet_type_create_initial_gate_state(...)` with `bulletContinues=false`: `bulletCreateCalled=false`, `bulletCreateReturnsNull=true`.
  - TCP `/root/Main.source_bullet_type_heals_state({"healPercent":0,"healAmount":2.5})`: `heals=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1071`
- Not done: `2`
- Source-backed remaining: `2`
- Progress: `99.81%`
- Remaining: `0.19%`
- Remaining slice ids: `N1423`, `N478`
- Next bullet slice: `N478`
- Next bullet slice status: `source-backed`
- Next bullet slice Godot owner: `PortGame.source_bullet_type_create_spawn_unit_state`
