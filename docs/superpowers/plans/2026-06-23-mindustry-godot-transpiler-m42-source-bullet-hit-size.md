# M42 Source Bullet Hit Size Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable turret bullet collision distance flow from source `BulletType.hitSize` instead of the handwritten `6.0` runtime threshold.

**Architecture:** `content_registry.py` extracts optional `hitSize` assignments from block ammo bullet initializers where source sets them. `PortGame.gd` keeps the source default in `source_bullet_hit_size(data)` as `4.0`, stores that value on each spawned bullet, uses it during projectile collision checks, and exposes selected ammo hit size through the MCP runtime summary.

**Source facts:** `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defines `public float hitSize = 4;`. `BulletType.create()` assigns `bullet.hitSize = hitSize`. `BulletComp.sense(LAccess.size)` reports `type.hitSize / tilesize`.

**Tech Stack:** Python registry generator, generated JSON/GDScript content registry, GDScript runtime, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M42 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M42-1 | Confirm source bullet hit size facts | `BulletType.java` defines default `hitSize=4`; `BulletType.create()` assigns `bullet.hitSize=hitSize`; `BulletComp` reports size from `type.hitSize`. |
| M42-2 | Add failing registry/runtime tests | Targeted registry test failed because block ammo did not emit explicit `hitSize`; targeted playable test failed because `PortGame.gd` lacked `source_bullet_hit_size()` and still used `direction.length() <= 6.0`. |
| M42-3 | Extract explicit source bullet hit sizes | `content_registry.py` now reads optional block ammo `hitSize` numeric assignments and emits them into ammo entries. |
| M42-4 | Apply source hit size in runtime | `PortGame.gd` now stores `"hit_size": source_bullet_hit_size(data)` on spawned bullets, collides with `float(bullet.get("hit_size", 4.0))`, and exposes `selected_turret_ammo_hit_size()`. |
| M42-5 | Regenerate generated content | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` completed with `items=22 liquids=11 blocks=417 units=56`; generated duo ammo keeps default-only hit size absent, while explicit source ammo samples include `hitSize` such as `spectre=4.8`, `breach=7`, `diffuse=7`, `smite=8`. |
| M42-6 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `49` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_hit_size=4.0`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M42 task | Add new tracked work before next milestone. |
