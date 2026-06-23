# M37 Source Unit Speed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable enemy units move from source `UnitType.speed` instead of the handwritten Godot multiplier `max(20.0, speed * tile_size * 5.0)`.

**Architecture:** Generated unit data already carries `speed`. `PortGame.gd` converts Mindustry unit units/tick into Godot world pixels/second with `speed * 60.0`, uses that value in `simulate_enemy_units()`, and exposes selected enemy speed through the MCP runtime summary.

**Source facts:** `UnitComp.java` returns base movement speed from `type.speed` before multipliers. `UnitType.java` reports unit speed stats as `speed * 60f / tilesize`, so world pixels/second are `speed * 60f`. Generated dagger has `speed=0.5`, so expected runtime world speed is `30.0`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M37 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M37-1 | Confirm source unit speed facts | `UnitComp.java` returns `type.speed`; `UnitType.java` exposes speed stats as `speed * 60f / tilesize`; generated dagger has `speed=0.5`. |
| M37-2 | Add failing runtime speed test | Targeted test failed because `PortGame.gd` had no `source_unit_world_speed()`, still used `max(20.0, speed * tile_size * 5.0)`, and had no summary speed field. |
| M37-3 | Apply source unit speed in runtime | `PortGame.gd` adds `source_unit_world_speed(unit_type)`, uses it in `simulate_enemy_units()`, and exposes `selected_enemy_world_speed`. |
| M37-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `44` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_enemy_world_speed=30.0`; debug output returned `errors: []`. |
| M37-5 | Update ledger | Design spec now tracks `40` total / `40` done / `0` not done and adds N38/M37 evidence for source unit speed. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M37 task | Add new tracked work before next milestone. |
