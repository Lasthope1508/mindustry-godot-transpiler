# N462 BulletType.updateWeaving circleShooter Finalize

Goal: finalize source-backed Godot runtime state for `BulletType.updateWeaving(Bullet b)` circleShooter branch.

## Source

- Java: `C:/Users/Admin/Documents/Game/mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java`
- Method: `public void updateWeaving(Bullet b){`
- Exact lines:
  - `if(circleShooter && b.owner instanceof Healthc h && h.isValid()){`
  - `Tmp.v1.set(h).sub(b);`
  - `Tmp.v1.rotate(90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth)));`
  - `b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed);`

## Checklist

- [x] Read `AGENTS.md`, design spec, SSOT roots/shards, and upstream Java.
- [x] Confirm existing runtime helper is source-backed and uses SSOT names.
- [x] Add RED status test for `N462`.
- [x] Confirm RED fails with `source-backed != done`.
- [x] Mark root ledger and shard mirror statuses `done`.
- [x] Run focused GREEN tests.
- [x] Run focused slice suite.
- [x] Run SSOT validator.
- [x] Run full Python test suite.
- [x] Prove through Godot MCP runtime `/root/Main`.
- [x] Check debug output `errors=[]` and stop with `finalErrors=[]`.
- [x] Run `git diff --check`.
- [x] Stage exact files and commit.

## Verification

- Focused RED:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k bullet_type_update_weaving_circle_shooter_symbols_are_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k bullet_type_update_weaving_circle_shooter_symbols_are_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- PortGame helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_bullet_type_update_weaving_circle_shooter_state`
  - Result: `1 passed, 1544 deselected`.
- Source parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_update_weaving_circle_shooter_state_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k update_weaving_circle_shooter`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 402.68s (0:06:42)`.
- Godot MCP runtime proof:
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N462")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_bullet_type_update_weaving_circle_shooter_state(...)`: `circleShooterApplied=true`, `circleShooterGatePassed=true`, `tmpBeforeRotate.len=10.0`, `rotationDegrees=90.0`, `tmpLimit=0.6`, `velocity.x=1.0`, `velocity.y=0.6`.
  - TCP guard with `circleShooter=false`: `circleShooterApplied=false`, `circleShooterGatePassed=false`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Diff check:
  - Command: `git diff --check`
  - Result: exit `0`; only CRLF warnings.

## Progress

- Total tracked slices: `1073`
- Done before slice: `981`
- Not done before slice: `92`
- Source-backed remaining before slice: `54`
- Other remaining before slice: `38`
- Done after slice: `982`
- Not done after slice: `91`
- Source-backed remaining after slice: `53`
- Other remaining after slice: `38`
- Progress after slice: `91.52%`
- Remaining after slice: `8.48%`
- Current first numeric non-done ledger slice: `N463 updateTrailEffects(Bullet b)`
- Current next source-backed finalize slice: `N463 updateTrailEffects(Bullet b)`
- Current next source-backed owner: `PortGame.source_bullet_type_update_trail_effects_chance_state`
