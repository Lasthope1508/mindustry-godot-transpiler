# N467 BulletType Init Lightning Type Finalize

## Scope

- Slice: `N467`
- Java source: `core/src/mindustry/entities/bullet/BulletType.java`
- Java method: `init()`
- Godot owner: `PortGame.source_bullet_type_init_lightning_type_state`
- Runtime proof: `/root/Main.source_bullet_type_init_lightning_type_state`

## Source Evidence

```java
if(lightningType == null){
    lightningType =
    !collidesAir ? Bullets.damageLightningGround :
    !collidesGround ? Bullets.damageLightningAir :
    Bullets.damageLightning;
}
```

Deferred to later source-backed slices:

```java
drawSize = Math.max(drawSize, trailLength * speed * 2f);
range = calculateRange();
```

## Checklist

- [x] Read `AGENTS.md`.
- [x] Read design spec and SSOT entries for `N467`.
- [x] Read exact upstream Java `BulletType.java`.
- [x] Confirmed `PortGame.source_bullet_type_init_lightning_type_state` is backed by exact source expressions.
- [x] Confirmed `N468` remains `source-backed`.
- [x] Added RED status assertion for `N467`.
- [x] Focused RED failed for expected reason: `source-backed != done`.
- [x] Flipped `N467` status to `done` in canonical ledger and shard mirrors.
- [x] Focused GREEN passed for source slice ledger registration.
- [x] Focused source helper test passed.
- [x] Focused upstream parity test passed.
- [x] Focused source symbol tests passed.
- [x] Focused slice suite passed.
- [x] SSOT validator passed.
- [x] Full Python suite passed.
- [x] Godot MCP runtime proof passed on TCP port `7777`.
- [x] Godot MCP ledger runtime proof confirmed `N467` canonical and nested status are `done`.
- [x] Godot TCP source proof confirmed ground lightning choice when `!collidesAir`.
- [x] Godot TCP source proof confirmed air lightning choice when `collidesAir && !collidesGround`.
- [x] Godot TCP source proof confirmed default lightning choice when both collision flags are true.
- [x] Godot TCP source proof confirmed non-null `lightningType` skips assignment.
- [x] Godot TCP regression proof confirmed `N466` frag velocity helper still applies.
- [x] Godot TCP regression proof confirmed `N468` light radius helper still applies.
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
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k source_bullet_type_init_lightning_type`
  - Result: `1 passed, 1544 deselected`.
- Focused upstream parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_init_lightning_type`
  - Result: `1 passed, 842 deselected`.
- Focused source symbols:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k "bullet_type_init_lightning_type_symbols_are_registered_with_source_backing or test_source_slice_ledger_tracks_registered_source_owners"`
  - Result: `2 passed, 1063 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider -k bullet_type_init_lightning_type`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `python -c "import sys; from pathlib import Path; sys.path.insert(0, str(Path('tools/mindustry_godot_transpiler'))); from mindustry_port import source_ssot; report=source_ssot.validate_json_modules(Path('godot-mindustry')); print({'errors': report['errors'], 'module_count': report['module_count']})"`
  - Result: `{'errors': [], 'module_count': 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -p no:cacheprovider`
  - Result: `4017 passed, 39290 subtests passed in 404.21s (0:06:44)`.
- Godot MCP runtime proof:
  - Runtime: Godot MCP editor bridge started `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
  - Version: `4.6.2.stable.official.71f334935`.
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N467")`: `entry.status=done`, `entry.slice.status=done`, `count=1073`.
  - TCP `/root/Main.source_bullet_type_init_lightning_type_state({"bulletType":{"lightningType":null,"collidesAir":false,"collidesGround":true}})`: `lightningTypeApplied=true`, `lightningType=Bullets.damageLightningGround`.
  - TCP `/root/Main.source_bullet_type_init_lightning_type_state({"bulletType":{"lightningType":null,"collidesAir":true,"collidesGround":false}})`: `lightningTypeApplied=true`, `lightningType=Bullets.damageLightningAir`.
  - TCP `/root/Main.source_bullet_type_init_lightning_type_state({"bulletType":{"lightningType":null,"collidesAir":true,"collidesGround":true}})`: `lightningTypeApplied=true`, `lightningType=Bullets.damageLightning`.
  - TCP `/root/Main.source_bullet_type_init_lightning_type_state({"bulletType":{"lightningType":"customLightning","collidesAir":false,"collidesGround":false}})`: `lightningTypeApplied=false`, `lightningType=customLightning`.
  - TCP `/root/Main.source_bullet_type_init_frag_velocity_state({"bulletType":{"fragBullet":{"keepVelocity":true,"scaleKeepVelocity":true}}})`: `fragBulletVelocityApplied=true`, `fragBullet.keepVelocity=false`, `fragBullet.scaleKeepVelocity=false`.
  - TCP `/root/Main.source_bullet_type_init_light_radius_state({"bulletType":{"lightRadius":-1,"hitSize":6}})`: `lightRadiusApplied=true`, `lightRadius=30`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.

## Progress

- Total tracked slices: `1073`
- Done: `1061`
- Not done: `12`
- Source-backed remaining: `12`
- Progress: `98.88%`
- Remaining: `1.12%`
- Next slice: `N468`
- Next slice status: `source-backed`
- Next slice Godot owner: `PortGame.source_bullet_type_init_light_radius_state`
