# M47 Source Turret Ammo Storage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve source item turret ammo storage fields needed before modeling ammo consumption.

**Architecture:** `content_registry.py` receives each block implementation type while building properties. For `ItemTurret`, it records `maxAmmo`, `ammoPerShot`, and `consumeAmmoOnce` from source assignments when they are literal values. If no assignment exists for a key, it uses the source defaults from `Turret.java`. If an assignment exists but is an unsupported expression, it leaves the field absent instead of writing a false default. `PortGame.gd` exposes selected duo storage fields through `get_runtime_summary()` for MCP verification.

**Source facts:** `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` defines `maxAmmo=30`, `ammoPerShot=1`, and `consumeAmmoOnce=true`. `mindustry-upstream/core/src/mindustry/content/Blocks.java` duo initializer does not override these fields.

**Tech Stack:** Python transpiler, generated JSON/GDScript registry, GDScript runtime, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M47 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M47-1 | Confirm source turret ammo storage facts | `Turret.java` defaults `maxAmmo=30`, `ammoPerShot=1`, `consumeAmmoOnce=true`; duo does not override them in `Blocks.java`. |
| M47-2 | Add failing content extraction test | Targeted registry test failed while expected duo properties included `maxAmmo`, `ammoPerShot`, and `consumeAmmoOnce` but extractor omitted them. |
| M47-3 | Add failing playable summary test | Targeted playable test failed while `PortGame.gd` lacked selected turret ammo storage helpers and summary keys. |
| M47-4 | Extract source storage fields safely | `_block_properties()` now receives implementation type; `_apply_item_turret_ammo_defaults()` records literal assignments or source defaults only when a key has no assignment. |
| M47-5 | Expose selected storage fields | `PortGame.gd` adds `selected_turret_max_ammo()`, `selected_turret_ammo_per_shot()`, `selected_turret_consume_ammo_once()`, and runtime summary fields. |
| M47-6 | Verify tests, generated content, and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `54` tests OK; `transpile.py content` reported `content items=22 liquids=11 blocks=417 units=56`; generated duo has `maxAmmo=30`, `ammoPerShot=1`, `consumeAmmoOnce=true`; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_max_ammo=30`, `selected_turret_ammo_per_shot=1`, `selected_turret_consume_ammo_once=true`, content counts `22/11/417/56`, and empty generated load/instance failures; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M47 task | Add new tracked work before next milestone. |
