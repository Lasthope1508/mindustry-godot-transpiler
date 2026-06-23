# M43 Source Bullet Damage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Route playable turret bullet damage through a source-named helper and expose runtime evidence, keeping the default aligned with `BulletType.damage` instead of an inline gameplay fallback.

**Architecture:** Generated block ammo already carries constructor damage from `BasicBulletType(speed, damage)`. `PortGame.gd` adds `source_bullet_damage(data)`, uses it when spawning turret bullets, and exposes `selected_turret_ammo_damage()` through the MCP runtime summary.

**Source facts:** `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defines `public float damage = 1f;`. Its `BulletType(float speed, float damage)` constructor assigns `this.damage = damage`. `Blocks.java` defines duo copper ammo with constructor damage `9`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M43 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M43-1 | Confirm source bullet damage facts | `BulletType.java` defines default `damage=1f`; `BulletType(float speed, float damage)` assigns constructor damage; generated duo copper ammo has `damage=9`. |
| M43-2 | Add failing runtime test | Targeted playable test failed because `PortGame.gd` lacked `source_bullet_damage()`, still spawned bullets with inline `float(data.get("damage", 1.0))`, and had no selected ammo damage summary field. |
| M43-3 | Apply source damage helper in runtime | `PortGame.gd` now uses `"damage": source_bullet_damage(data)` when spawning turret bullets and exposes `selected_turret_ammo_damage()`. |
| M43-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `50` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_damage=9.0`; MCP debug output returned `errors: []`. |
| M43-5 | Update ledger | Design spec now tracks `46` total / `46` done / `0` not done and adds N44/M43 evidence for source bullet damage. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M43 task | Add new tracked work before next milestone. |
