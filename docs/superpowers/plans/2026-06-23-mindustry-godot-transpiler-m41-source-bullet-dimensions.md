# M41 Source Bullet Dimensions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable turret bullet sprite scale flow from source `BasicBulletType.width` and `BasicBulletType.height` instead of a handwritten tile-size multiplier.

**Architecture:** `content_registry.py` extracts optional `width` and `height` assignments from block ammo `BasicBulletType` double-brace initializers. Generated content carries those fields into `MindustryContentRegistry.gd` and `content_registry.json`. `PortGame.gd` adds `source_bullet_scale(data, texture_size)`, applies it in `spawn_turret_bullet()`, and exposes selected ammo dimensions through the MCP runtime summary.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` defines duo copper ammo as `new BasicBulletType(2.5f, 9)` with `width = 7f`, `height = 9f`, and `lifetime = 60f`.

**Tech Stack:** Python registry generator, generated JSON/GDScript content registry, GDScript runtime, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M41 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M41-1 | Confirm source bullet dimension facts | `Blocks.java` duo copper ammo sets `width=7f` and `height=9f` inside the `BasicBulletType` initializer. |
| M41-2 | Add failing registry/runtime tests | Targeted registry test failed because generated ammo lacked `width/height`; targeted playable test failed because `PortGame.gd` lacked `source_bullet_scale()` and still used `Vector2(tile_size / size.x, tile_size / size.y) * 0.45`. |
| M41-3 | Extract source bullet dimensions | `content_registry.py` now reads optional block ammo `width` and `height` numeric assignments and emits them into ammo entries. |
| M41-4 | Apply source dimensions in runtime | `PortGame.gd` now uses `source_bullet_scale(data, size)` for turret bullet sprites and exposes `selected_turret_ammo_dimensions()`. |
| M41-5 | Regenerate generated content | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` completed with `items=22 liquids=11 blocks=417 units=56`; generated duo ammo is `{"damage": 9, "height": 9.0, "item": "copper", "lifetime": 60.0, "speed": 2.5, "sprite": "bullet", "width": 7.0}`. |
| M41-6 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `48` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_dimensions={width:7,height:9}`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M41 task | Add new tracked work before next milestone. |
