# M35 Source Bullet Lifetime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable turret bullets expire from source `BasicBulletType.lifetime` instead of living until they hit or lose a target.

**Architecture:** Generated ammo data already carries `lifetime` in source frames. `PortGame.gd` converts that to seconds with `lifetime / 60.0`, stores `lifetime_remaining` on each spawned turret bullet, decrements it in `simulate_bullets()`, and frees expired bullets before movement/collision.

**Source facts:** `BulletType.lifetime` defaults to `40f`; duo copper ammo in `Blocks.java` sets `lifetime = 60f`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M35 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M35-1 | Confirm source bullet lifetime facts | `BulletType.java` defines default `lifetime = 40f`; `Blocks.java` duo copper ammo sets `lifetime = 60f`. |
| M35-2 | Add failing runtime lifetime test | Targeted test failed because `PortGame.gd` had no `source_bullet_lifetime_seconds()`, no bullet `lifetime_remaining`, and no summary lifetime field. |
| M35-3 | Apply source lifetime in runtime | `PortGame.gd` converts source lifetime frames to seconds, stores `lifetime_remaining` on spawned bullets, decrements it, and removes expired bullet sprites. |
| M35-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `42` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_lifetime_seconds=1`; debug output returned `errors: []`. |
| M35-5 | Update ledger | Design spec now tracks `38` total / `38` done / `0` not done and adds N36/M35 evidence for source bullet lifetime. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M35 task | Add new tracked work before next milestone. |
