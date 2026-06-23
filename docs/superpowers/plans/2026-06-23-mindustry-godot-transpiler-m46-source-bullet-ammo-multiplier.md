# M46 Source Bullet Ammo Multiplier Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve source `BulletType.ammoMultiplier` values for generated turret ammo entries.

**Architecture:** `_block_ammo()` already extracts each BasicBulletType body for width, height, lifetime, and hit size. It now also reads `ammoMultiplier` from the same bullet initializer body. `PortGame.gd` exposes the selected ammo multiplier in `get_runtime_summary()` so MCP can verify loaded generated data.

**Source facts:** `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defaults `ammoMultiplier=2f`. `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo copper `ammoMultiplier=2`, graphite `ammoMultiplier=4`, and silicon `ammoMultiplier=5`.

**Tech Stack:** Python transpiler, generated JSON/GDScript registry, GDScript runtime, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M46 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M46-1 | Confirm source ammoMultiplier facts | `BulletType.java` defaults `ammoMultiplier=2f`; `Blocks.java` duo ammo sets copper `2`, graphite `4`, silicon `5`. |
| M46-2 | Add failing content extraction test | Targeted registry test failed while expected duo ammo entries included `ammoMultiplier` but extractor omitted it. |
| M46-3 | Add failing playable summary test | Targeted playable test failed while `PortGame.gd` lacked `source_bullet_ammo_multiplier()`, `selected_turret_ammo_multiplier()`, and summary key `selected_turret_ammo_multiplier`. |
| M46-4 | Extract source ammoMultiplier | `_block_ammo()` now reads `ammoMultiplier` from each BasicBulletType initializer body. |
| M46-5 | Expose selected ammo multiplier | `PortGame.gd` adds `source_bullet_ammo_multiplier()`, `selected_turret_ammo_multiplier()`, and runtime summary field `selected_turret_ammo_multiplier`. |
| M46-6 | Verify tests, generated content, and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `53` tests OK; `transpile.py content` reported `content items=22 liquids=11 blocks=417 units=56`; generated duo ammo has multipliers `2/4/5`; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_multiplier=2`, `selected_turret_ammo_count=3`, content counts `22/11/417/56`, and empty generated load/instance failures; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M46 task | Add new tracked work before next milestone. |
