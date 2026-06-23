# M44 Source Unit Health Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize spawned enemy health from source `UnitType.health` instead of the handwritten runtime fallback `100.0`.

**Architecture:** Generated unit content already carries `properties.health`. `PortGame.gd` adds `source_unit_health(unit_type)`, uses it in `spawn_enemy_unit()`, and exposes `selected_enemy_health` through `get_runtime_summary()` for MCP verification.

**Source facts:** `mindustry-upstream/core/src/mindustry/type/UnitType.java` defines default `health=200f`. `mindustry-upstream/core/src/mindustry/content/UnitTypes.java` sets dagger `health=150`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M44 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M44-1 | Confirm source unit health facts | `UnitType.java` defaults `health=200f`; `UnitTypes.java` sets dagger `health=150`; generated dagger carries `health=150`. |
| M44-2 | Add failing runtime test | Targeted playable test failed because `PortGame.gd` lacked `source_unit_health()`, spawned enemies with inline `float(unit_type.properties.get("health", 100.0))`, and exposed no selected enemy health summary. |
| M44-3 | Apply source unit health in runtime | `PortGame.gd` now uses `"health": source_unit_health(unit_type)` when spawning enemy units and reports `selected_enemy_health`. |
| M44-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `51` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_enemy_health=150.0`; MCP debug output returned `errors: []`. |
| M44-5 | Update ledger | Design spec now tracks `47` total / `47` done / `0` not done and adds N45/M44 evidence for source unit health. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M44 task | Add new tracked work before next milestone. |
