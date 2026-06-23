# M36 Source Bullet Speed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable turret bullets move from source `BasicBulletType.speed` instead of the handwritten Godot multiplier `speed * tile_size * 4.0`.

**Architecture:** Generated ammo data already carries `speed` from Java constructors. `PortGame.gd` converts Mindustry bullet units/tick into Godot world pixels/second with `speed * 60.0`, stores that value on spawned bullets, and exposes selected ammo speed through the MCP runtime summary.

**Source facts:** `BulletType.java` documents `speed` as units/tick. `BulletComp.java` reports bullet speed stats as `type.speed * 60f / tilesize`, which means world pixels/second are `type.speed * 60f`. Duo copper ammo in `Blocks.java` uses `new BasicBulletType(2.5f, 9)`, so expected runtime world speed is `150.0`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M36 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M36-1 | Confirm source bullet speed facts | `BulletType.java` defines speed as units/tick; `BulletComp.java` exposes speed stats as `type.speed * 60f / tilesize`; `Blocks.java` duo copper ammo uses `speed=2.5`. |
| M36-2 | Add failing runtime speed test | Targeted test failed because `PortGame.gd` had no `source_bullet_world_speed()`, still used `speed * tile_size * 4.0`, and had no summary speed field. |
| M36-3 | Apply source bullet speed in runtime | `PortGame.gd` adds `source_bullet_world_speed(data)`, stores that value in spawned bullet dictionaries, and exposes `selected_turret_ammo_world_speed()`. |
| M36-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `43` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_world_speed=150.0`; debug output returned `errors: []`. |
| M36-5 | Update ledger | Design spec now tracks `39` total / `39` done / `0` not done and adds N37/M36 evidence for source bullet speed. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M36 task | Add new tracked work before next milestone. |
