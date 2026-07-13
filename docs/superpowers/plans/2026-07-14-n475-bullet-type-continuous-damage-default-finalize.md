# N475 BulletType Continuous Damage Default Finalize

## Scope

- Slice: `N475`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `continuousDamage()`
- Godot owner: `PortGame.source_bullet_type_continuous_damage_default_state`
- Runtime proof: `/root/Main.source_bullet_type_continuous_damage_default_state`

## Source Evidence

```java
/** @return continuous damage in damage/sec, or -1 if not continuous. */
public float continuousDamage(){
    return -1f;
}

public boolean heals(){
```

Finalized in this slice:

```java
return -1f;
```

Deferred to later source-backed slices:

- Subclass `continuousDamage()` overrides stay covered by later dedicated slices.

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N475`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed `PortGame.source_bullet_type_continuous_damage_default_state` is backed by exact source expressions.
- [x] Confirmed `N1423`, `N476`, `N477`, and `N478` remain `source-backed`.
- [x] Added RED status assertion for `N475`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N475` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N475` canonical and nested status are `done`.
- [x] Godot TCP proof confirmed `continuousDamage` returns `-1.0`.
- [x] Godot TCP proof confirmed input `bulletType` state is preserved in output.
- [x] Godot TCP regression proof confirmed `N474` zero-drag fallback still returns `80.0`.
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
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_continuous_damage_default`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_continuous_damage_default`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_continuous_damage_default_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_continuous_damage_default`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 378.69s (0:06:18)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N475")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_bullet_type_continuous_damage_default_state({"damage":99,"lifetime":40,"continuousDamage":123,"customMarker":"preserve"})`: `continuousDamage=-1.0`, `continuousDamageReturnSource="return -1f"`, `bulletType.customMarker="preserve"`.
  - TCP `/root/Main.source_bullet_type_calculate_range_fallback_state({"bulletType":{"speed":2,"lifetime":40,"drag":0,"maxRange":-1},"returnEarly":false,"range":null})`: `fallbackRange=80.0`, `range=80.0`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1069`
- Not done: `4`
- Source-backed remaining: `4`
- Progress: `99.63%`
- Remaining: `0.37%`
- Remaining slice ids: `N1423`, `N476`, `N477`, `N478`
- Next bullet slice: `N476`
- Next bullet slice status: `source-backed`
- Next bullet slice Godot owner: `PortGame.source_bullet_type_heals_state`
