# M45 Source Turret Ammo List Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract every source `BasicBulletType` ammo entry from the duo turret initializer instead of only the first entry.

**Architecture:** `content_registry.py` reads `Blocks.java` turret initializer text, gathers all `Items.x, new BasicBulletType(...)` pairs in source order, writes them into generated content data, and `PortGame.gd` exposes the generated ammo list size through `get_runtime_summary()` for MCP verification.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` defines duo ammo for `Items.copper`, `Items.graphite`, and `Items.silicon`. Copper is `BasicBulletType(2.5f, 9)` with `width=7f`, `height=9f`, `lifetime=60f`; graphite is `BasicBulletType(3.5f, 18)` with `width=9f`, `height=12f`, `lifetime=60f`; silicon is `BasicBulletType(3f, 12)` with `width=7f`, `height=9f`, `lifetime=60f`.

**Tech Stack:** Python transpiler, generated JSON/GDScript registry, GDScript runtime, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M45 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M45-1 | Confirm source duo ammo facts | `Blocks.java` duo initializer has three ammo pairs: copper, graphite, silicon, all using `new BasicBulletType(...)`. |
| M45-2 | Add failing content extraction test | Targeted registry test failed while generated fixture expected copper, graphite, and silicon but extractor returned only copper. |
| M45-3 | Add failing playable summary test | Targeted playable test failed while `PortGame.gd` lacked `selected_turret_ammo_count()` and summary key `selected_turret_ammo_count`. |
| M45-4 | Extract all source ammo entries | `_block_ammo()` now matches each `Items.x, new BasicBulletType(...)` pair inside the initializer; regenerated duo ammo contains three source entries in order. |
| M45-5 | Expose ammo count through runtime summary | `PortGame.gd` adds `selected_turret_ammo_count()` and includes it in `get_runtime_summary()`. |
| M45-6 | Verify tests, generated content, and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `52` tests OK; `transpile.py content` reported `content items=22 liquids=11 blocks=417 units=56`; generated duo ammo contains `3` entries; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_ammo_count=3` and content counts `22/11/417/56`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M45 task | Add new tracked work before next milestone. |
