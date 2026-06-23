# M34 Source Conveyor Speed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the playable item sprites along conveyors with source-derived conveyor speed instead of reusing drill production progress.

**Architecture:** Extract `speed` and `displayedSpeed` from `Blocks.java`. `PortGame.gd` keeps drill production progress separate from item transport progress. Conveyor world speed follows the source `ConveyorBuild` movement factor `speed * tilesize * 55`; path progress normalizes that by the current conveyor path length.

**Source facts:** `conveyor` has `speed = 0.03f` and `displayedSpeed = 4.2f`; `ConveyorBuild.unitOn()` computes `mspeed = speed * tilesize * 55f`.

**Tech Stack:** Python registry extractor, GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M34 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M34-1 | Confirm source conveyor facts | `Blocks.java` defines `conveyor.speed = 0.03f` and `displayedSpeed = 4.2f`; `Conveyor.java` computes movement with `speed * tilesize * 55f`. |
| M34-2 | Add failing conveyor-speed tests | Targeted tests failed because generated conveyor properties lacked `speed/displayedSpeed` and `PortGame.gd` had no source conveyor transport progress. |
| M34-3 | Extract conveyor speed fields | `_block_properties()` now extracts numeric `speed` and `displayedSpeed`; regenerated `conveyor.properties` includes `speed=0.03` and `displayedSpeed=4.2`. |
| M34-4 | Use source conveyor motion in runtime | `PortGame.gd` adds `SOURCE_CONVEYOR_TILE_SPEED_SCALE = 55.0`, `transport_progress`, `conveyor_world_speed`, and `conveyor_path_progress_rate`; item sprites now use transport progress while drill production keeps separate `item_progress`. |
| M34-5 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `41` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `conveyor_world_speed=52.8` and `conveyor_path_progress_rate=0.183333333333333`; debug output returned `errors: []`. |
| M34-6 | Update ledger | Design spec now tracks `37` total / `37` done / `0` not done and adds N35/M34 evidence for source conveyor speed. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M34 task | Add new tracked work before next milestone. |
