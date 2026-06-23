# M31 Source Bullet Sprite Assets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render turret bullets with source-derived bullet sprite assets instead of the generic item icon.

**Architecture:** Extract the `BasicBulletType` sprite id from source constructors. Default `BasicBulletType(speed, damage)` maps to source default `"bullet"`; explicit third constructor argument maps to that sprite id. `PortGame.gd` resolves the copied asset under `res://assets/core/assets-raw/sprites/effects/` and uses it for turret bullets.

**Tech Stack:** Python registry extractor, GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M31 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M31-1 | Confirm source and asset facts | `BasicBulletType(float speed, float damage)` delegates to `this(speed, damage, "bullet")`; copied Godot asset exists at `res://assets/core/assets-raw/sprites/effects/bullet.png`. |
| M31-2 | Add failing sprite regression tests | Targeted tests failed because generated ammo/weapon bullet data lacked `sprite` and `PortGame.gd` still used `textures.get("item")` for turret bullets. |
| M31-3 | Extract bullet sprite ids | `_block_ammo()` and `_unit_weapons()` now add `sprite`, defaulting to `"bullet"` when source uses the two-argument `BasicBulletType` constructor. |
| M31-4 | Use source bullet sprite asset in runtime | `PortGame.gd` adds `source_bullet_texture(sprite_id)`, uses it in `spawn_turret_bullet()`, and exposes `selected_turret_ammo_sprite` in runtime summary. |
| M31-5 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `38` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; runtime MCP returned `selected_turret_ammo_sprite="bullet"` and `source_bullet_texture("bullet")` as `res://assets/core/assets-raw/sprites/effects/bullet.png`; debug output returned `errors: []`. |
| M31-6 | Update ledger and commit | Design spec now tracks `34` total / `34` done / `0` not done and adds N32/M31 evidence for source bullet sprite assets; this checkpoint is committed as `feat: use source bullet sprites`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M31 task | Add new tracked work before next milestone. |
