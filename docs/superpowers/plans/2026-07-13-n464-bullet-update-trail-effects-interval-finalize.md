# N464 BulletType.updateTrailEffects interval Finalize

Goal: finalize source-backed Godot runtime state for `BulletType.updateTrailEffects(Bullet b)` trail interval branch.

## Source

- Java: `C:/Users/Admin/Documents/Game/mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java`
- Method: `public void updateTrailEffects(Bullet b){`
- Exact lines:
  - `if(trailInterval > 0f && canSpawn){`
  - `if(b.timer(0, trailInterval)){`
  - `Tmp.v1.rnd(Mathf.random(trailSpread));`
  - `Tmp.v1.setZero();`
  - `trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);`

## Checklist

- [x] Read `AGENTS.md`, design spec, SSOT roots/shards, and upstream Java.
- [x] Confirm existing runtime helper is source-backed and uses SSOT names.
- [x] Add RED status test for `N464`.
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
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k bullet_type_update_trail_effects_interval_symbols_are_registered_with_source_backing`
  - Result: failed as expected with `AssertionError: 'source-backed' != 'done'`.
- Focused GREEN:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_symbols.py -q -k bullet_type_update_trail_effects_interval_symbols_are_registered_with_source_backing`
  - Result: `1 passed, 1064 deselected`.
- PortGame helper:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -q -k test_port_game_exposes_source_bullet_type_update_trail_effects_interval_state`
  - Result: `1 passed, 1544 deselected`.
- Source parity:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests/test_source_parity.py -q -k bullet_type_update_trail_effects_interval_state_matches_upstream_source`
  - Result: `1 passed, 842 deselected`.
- Focused slice suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q -k update_trail_effects_interval`
  - Result: `3 passed, 4014 deselected`.
- SSOT:
  - Command: `PYTHONPATH=tools/mindustry_godot_transpiler python -c "from pathlib import Path; from mindustry_port import source_ssot; ..."`
  - Result: `{"errors": [], "module_count": 112}`.
- Full suite:
  - Command: `python -m pytest tools/mindustry_godot_transpiler/tests -q`
  - Result: `4017 passed, 39290 subtests passed in 392.07s (0:06:32)`.
- Godot MCP runtime proof:
  - Runtime status: `runtimeAddon=connected`.
  - TCP `/root/Main.ssot_slice_ledger_state("N464")`: `entry.status=done`, `entry.slice.status=done`.
  - TCP `/root/Main.source_bullet_type_update_trail_effects_interval_state(...)` applied path: `trailIntervalEffectApplied=true`, `canSpawn=true`, `intervalGatePassed=true`, `timerGetResult=true`, `tmpOffset={"x":-1.5,"y":0.5}`, `effectCalls.size=2`, last effect `x=8.5`, `y=20.5`, `rotation=7.0`.
  - TCP timer false path: `trailIntervalEffectApplied=false`, `timerGetResult=false`, existing `effectCalls` preserved.
  - TCP blocked path with `canSpawn=false`: `trailIntervalEffectApplied=false`, `intervalGatePassed=false`.
  - After TCP: `errors=[]`.
  - Stop: `finalErrors=[]`.
- Diff check:
  - Command: `git diff --check`
  - Result: exit `0`; only CRLF warnings.

## Progress

- Total tracked slices: `1073`
- Done before slice: `983`
- Not done before slice: `90`
- Source-backed remaining before slice: `52`
- Other remaining before slice: `38`
- Done after slice: `984`
- Not done after slice: `89`
- Source-backed remaining after slice: `51`
- Other remaining after slice: `38`
- Progress after slice: `91.71%`
- Remaining after slice: `8.29%`
- Current first numeric non-done ledger slice: `N465 init()`
- Current next source-backed finalize slice: `N465 init()`
- Current next source-backed owner: `PortGame.source_bullet_type_init_type_defaults_state`
