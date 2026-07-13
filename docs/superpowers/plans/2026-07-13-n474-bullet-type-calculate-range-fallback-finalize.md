# N474 BulletType Calculate Range Fallback Finalize

## Scope

- Slice: `N474`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `calculateRange()`
- Godot owner: `PortGame.source_bullet_type_calculate_range_fallback_state`
- Runtime proof: `/root/Main.source_bullet_type_calculate_range_fallback_state`

## Source Evidence

```java
public float speed = 1f;
public float lifetime = 40f;
public float drag = 0f;
public float maxRange = -1f;

protected float calculateRange(){
    if(rangeOverride > 0) return rangeOverride;
    if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;
    if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;
    return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);
}
```

Arc `Mathf` expressions registered in SSOT for this slice:

```java
public static final float FLOAT_ROUNDING_ERROR = 0.000001f;
return Math.abs(value) <= FLOAT_ROUNDING_ERROR;
return (float)Math.pow(a, b);
```

Finalized in this slice:

```java
return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);
```

Deferred to later source-backed slices: none.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N474`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed local `Mathf.java` is not present, and used existing SSOT-registered Arc `Mathf.zero` and `Mathf.pow` expressions already verified by source parity tests.
- [x] Confirmed `PortGame.source_bullet_type_calculate_range_fallback_state` is backed by exact source expressions.
- [x] Confirmed `N1423` and `N475` remain `source-backed`.
- [x] Added RED status assertion for `N474`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N474` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N474` canonical and nested status are `done`.
- [x] Godot TCP proof confirmed zero-drag fallback returns `speed * lifetime`.
- [x] Godot TCP proof confirmed `maxRange` floors fallback range through `Math.max`.
- [x] Godot TCP proof confirmed nonzero-drag fallback uses `speed * (1 - pow(1 - drag, lifetime)) / drag`.
- [x] Godot TCP proof confirmed prior early return preserves existing `range`.
- [x] Godot TCP regression proof confirmed `N473` despawnUnit branch still returns early.
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
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_calculate_range_fallback`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_calculate_range_fallback`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_calculate_range_fallback_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_calculate_range_fallback`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 386.99s (0:06:26)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N474")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_bullet_type_calculate_range_fallback_state({"bulletType":{"speed":2,"lifetime":40,"drag":0,"maxRange":-1},"returnEarly":false,"range":null})`: `zeroDrag=true`, `fallbackRange=80`, `range=80`.
  - TCP `/root/Main.source_bullet_type_calculate_range_fallback_state({"bulletType":{"speed":2,"lifetime":40,"drag":0,"maxRange":100},"returnEarly":false,"range":null})`: `fallbackRange=80`, `range=100`.
  - TCP `/root/Main.source_bullet_type_calculate_range_fallback_state({"bulletType":{"speed":3,"lifetime":5,"drag":0.1,"maxRange":-1},"returnEarly":false,"range":null})`: `zeroDrag=false`, `fallbackRange=12.2853`, `range=12.2853`.
  - TCP `/root/Main.source_bullet_type_calculate_range_fallback_state({"bulletType":{"speed":3,"lifetime":5,"drag":0.1,"maxRange":999},"returnEarly":true,"range":330})`: `fallbackRangeGatePassed=false`, `range=330`.
  - TCP `/root/Main.source_bullet_type_calculate_range_despawn_unit_state({"bulletType":{"rangeOverride":-1,"despawnUnit":{"lifetime":240,"speed":1.25}},"returnEarly":false,"range":null})`: `despawnUnitRangeGatePassed=true`, `range=300`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1068`
- Not done: `5`
- Source-backed remaining: `5`
- Progress: `99.53%`
- Remaining: `0.47%`
- Next bullet slice: `N475`
- Next bullet slice status: `source-backed`
- Next bullet slice Godot owner: `PortGame.source_bullet_type_continuous_damage_default_state`
