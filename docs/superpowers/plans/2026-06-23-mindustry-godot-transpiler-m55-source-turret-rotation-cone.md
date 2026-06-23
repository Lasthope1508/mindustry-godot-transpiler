# M55 Source Turret Rotation Cone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source duo `rotateSpeed` and `shootCone`, then use them to rotate the playable turret toward its target before firing.

**Architecture:** `source_parity.py` reads duo `rotateSpeed = 10f` and `shootCone = 15f` directly from `Blocks.java` and compares generated registry data against it. `content_registry.py` emits both values into generated block properties. `PortGame.gd` tracks per-turret rotation, moves it toward the target by source rotate speed, blocks firing until angle distance is within source shoot cone, and uses the current turret rotation for bullet velocity.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo `shootCone = 15f` and `rotateSpeed = 10f`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` calls `turnToTarget(targetRot)`, implements `rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency)`, and calls `updateShooting()` only when `Angles.angleDist(rotation, targetRot) < shootCone && canShoot`.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M55 tasks | 9 |
| Done | 9 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M55-1 Add failing source-parity test for `rotateSpeed` and `shootCone`.
- [x] M55-2 Add failing generator test for `rotateSpeed` and `shootCone`.
- [x] M55-3 Add failing playable runtime test for rotation gate and bullet velocity from turret angle.
- [x] M55-4 Extract source rotation/cone values.
- [x] M55-5 Regenerate Godot content registry.
- [x] M55-6 Use rotation/cone in playable turret fire.
- [x] M55-7 Verify targeted and full tests.
- [x] M55-8 Verify MCP LSP/runtime behavior.
- [x] M55-9 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M55-1 | Add failing source-parity test for `rotateSpeed` and `shootCone` | Targeted source-parity test failed before implementation with `None != 10.0` for `rotateSpeed`. |
| M55-2 | Add failing generator test for `rotateSpeed` and `shootCone` | Targeted content registry test failed before implementation because generated duo properties omitted `rotateSpeed` and `shootCone`. |
| M55-3 | Add failing playable runtime test for rotation gate and bullet velocity from turret angle | Targeted playable test failed before implementation because `PortGame.gd` lacked `SOURCE_TICK_RATE`, turret rotation state, and rotation/cone helpers. |
| M55-4 | Extract source rotation/cone values | `source_parity.py` and `content_registry.py` now parse `rotateSpeed` and `shootCone` numeric assignments from source initializers. |
| M55-5 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` reported `content items=22 liquids=11 blocks=417 units=56`. |
| M55-6 | Use rotation/cone in playable turret fire | Targeted playable tests passed with `SOURCE_TICK_RATE`, per-turret rotations, source angle move, `shootCone` gate, and bullet velocity from `shoot_angle_degrees`. |
| M55-7 | Verify targeted and full tests | Targeted 4-test command passed; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran 62 tests with `OK`. |
| M55-8 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics returned `[]`; MCP runtime reported `selected_turret_rotate_speed=10`, `selected_turret_shoot_cone=15`, fired only with `last_turret_angle_delta=14.036 < 15`, then blocked firing with forced `last_turret_angle_delta=165.964 >= 15`; debug output errors `[]`. |
| M55-9 | Update docs total/done/not done and commit | Spec now records N56 and status `58/58`; this plan records M55 `9/9`; explicit-file stage and commit follow fresh verification. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M55 item | Add next source-backed migration item after reading upstream Java and writing RED tests. |
