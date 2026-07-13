# N471 BulletType Calculate Range Override Finalize

## Scope

- Slice: `N471`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `calculateRange()`
- Godot owner: `PortGame.source_bullet_type_calculate_range_override_state`
- Runtime proof: `/root/Main.source_bullet_type_calculate_range_override_state`

## Source Evidence

```java
public float rangeOverride = -1f;

protected float calculateRange(){
    if(rangeOverride > 0) return rangeOverride;
    if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;
    if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;
    return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);
}
```

Finalized in this slice:

```java
if(rangeOverride > 0) return rangeOverride;
```

Deferred to later source-backed slices:

```java
if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;
if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;
return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N471`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed `PortGame.source_bullet_type_calculate_range_override_state` is backed by exact source expressions.
- [x] Confirmed `N1423` and `N472` remain `source-backed`.
- [x] Added RED status assertion for `N471`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N471` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N471` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed positive `rangeOverride` returns early with `range`.
- [x] Godot TCP source proof confirmed non-positive `rangeOverride` does not return early and keeps `range=null`.
- [x] Godot TCP regression proof confirmed `N470` range assignment still writes the provided calculateRange result.
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
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_calculate_range_override`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_calculate_range_override`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_calculate_range_override_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_calculate_range_override`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 391.40s (0:06:31)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N471")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_bullet_type_calculate_range_override_state({"rangeOverride":125})`: `rangeOverrideGatePassed=true`, `returnEarly=true`, `range=125`.
  - TCP `/root/Main.source_bullet_type_calculate_range_override_state({"rangeOverride":-1})`: `rangeOverrideGatePassed=false`, `returnEarly=false`, `range=null`.
  - TCP `/root/Main.source_bullet_type_init_range_assignment_state({"bulletType":{"range":12}}, 144)`: `rangeBefore=12`, `range=144`, `calculateRangeDeferred=true`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1065`
- Not done: `8`
- Source-backed remaining: `8`
- Progress: `99.25%`
- Remaining: `0.75%`
- Next bullet slice: `N472`
- Next bullet slice status: `source-backed`
- Next bullet slice Godot owner: `PortGame.source_bullet_type_calculate_range_spawn_unit_state`
