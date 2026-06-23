# M52 Source Turret ShootY Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source turret `shootY` and use it when spawning playable turret bullets.

**Architecture:** `source_parity.py` reads duo `shootY` directly from `Blocks.java` and compares generated registry data against it. `content_registry.py` extracts `shootY` as a block property. `PortGame.gd` adds `source_turret_shoot_y()` and `source_turret_bullet_origin()`, then offsets fired bullet origin toward the target by the source `shootY` value before `spawn_turret_bullet()`.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo `shootY = 3f`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` computes turret bullet coordinates using `Angles.trnsx(rotation - 90, shootX, shootY)` and `Angles.trnsy(rotation - 90, shootX, shootY)` before firing.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M52 tasks | 7 |
| Done | 7 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M52-1 | Add failing source-parity test | `test_source_parity.py` asserted duo source `shootY=3.0`; before implementation, targeted test failed with `None != 3.0`. |
| M52-2 | Add failing generator test | `test_content_registry.py` added `shootY = 3f` to the fixture duo turret and expected generated `properties.shootY=3.0`; before implementation, targeted test failed because the registry omitted it. |
| M52-3 | Add failing playable runtime test | `test_playable.py` required `last_turret_fired_shoot_y`, `source_turret_shoot_y()`, `source_turret_bullet_origin()`, and `spawn_turret_bullet(bullet_origin, target, data)`; before implementation, targeted test failed because runtime lacked those symbols. |
| M52-4 | Extract source turret shootY | `content_registry.py` now records `shootY` through `_numeric_assignment()`, regenerated content registry includes duo `shootY=3.0`, and `source_parity.py` compares it against Java source. |
| M52-5 | Use shootY in playable bullet origin | `PortGame.gd` now computes `bullet_origin := source_turret_bullet_origin(grid_to_world(cell), target, duo)`, records `last_turret_fired_shoot_y`, and spawns the turret bullet at that offset origin. |
| M52-6 | Verify tests and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `59` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`. |
| M52-7 | Verify deterministic MCP runtime behavior | MCP runtime disabled `_process`, loaded one copper item (`load_selected_turret_ammo("copper", 1)` returned `1`, `selected_turret_total_ammo=2`), called `simulate_turrets(0.0)`, and read `last_turret_fired_ammo_item="copper"`, `last_turret_fired_damage=9`, `last_turret_fired_range=160`, `last_turret_fired_shoot_y=3`, `selected_turret_shoot_y=3`, `selected_turret_total_ammo=1`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M52 task | Add new tracked work before next milestone. |
