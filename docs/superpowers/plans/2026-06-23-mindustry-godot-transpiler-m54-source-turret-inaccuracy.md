# M54 Source Turret Inaccuracy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source duo turret `inaccuracy` and use it when computing playable bullet shot angle.

**Architecture:** `source_parity.py` reads duo `inaccuracy = 2f` directly from `Blocks.java` and compares generated registry data against it. `content_registry.py` extracts block `inaccuracy` and bullet `inaccuracy` where present. `PortGame.gd` computes `source_turret_total_inaccuracy(turret, data)`, samples a source-bounded random angle offset, records the fired range/offset for MCP, and stores a fixed bullet velocity derived from the source shot angle instead of retargeting every frame.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo `inaccuracy = 2f`. `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defaults `inaccuracy = 0f`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` computes `shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy)` before creating the bullet.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M54 tasks | 8 |
| Done | 8 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M54-1 | Add failing source-parity test | `test_source_parity.py` asserted duo source `inaccuracy=2.0`; before implementation, targeted test failed with `None != 2.0`. |
| M54-2 | Add failing generator test | `test_content_registry.py` added `inaccuracy = 2f` to the fixture duo turret and expected generated `properties.inaccuracy=2.0`; before implementation, targeted test failed because the registry omitted it. |
| M54-3 | Add failing playable runtime test | `test_playable.py` required `source_turret_inaccuracy()`, `source_bullet_inaccuracy()`, `source_turret_total_inaccuracy()`, fired inaccuracy summary fields, `randf_range(-inaccuracy_range, inaccuracy_range)`, and fixed bullet velocity; before implementation, targeted test failed because runtime lacked those symbols. |
| M54-4 | Extract source inaccuracy | `source_parity.py` and `content_registry.py` now parse block `inaccuracy`, and `content_registry.py` also records bullet `inaccuracy` when a bullet initializer assigns it. |
| M54-5 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` regenerated content files with counts `22` items, `11` liquids, `417` blocks, `56` units; duo properties include `inaccuracy=2.0`. |
| M54-6 | Use inaccuracy in playable turret fire | `PortGame.gd` computes total inaccuracy from turret plus bullet data, samples a bounded random angle offset, records `last_turret_fired_inaccuracy_range` and `last_turret_fired_inaccuracy_offset`, passes the offset into `spawn_turret_bullet()`, and stores bullet `velocity` from `source_bullet_velocity()`. |
| M54-7 | Verify tests and Godot diagnostics | Targeted source-parity/content/playable tests passed, then `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `61` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`. |
| M54-8 | Verify deterministic MCP runtime behavior | MCP runtime disabled `_process`, spawned an enemy wave, loaded one copper item, called `simulate_turrets(100.0)`, and read `selected_turret_inaccuracy=2`, `last_turret_fired_inaccuracy_range=2`, `last_turret_fired_inaccuracy_offset=1.83383791437429` within source bounds, `last_turret_fired_ammo_item="copper"`, `turret_shot_count=1`, `bullet_count=1`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M54 task | Add new tracked work before next milestone. |
