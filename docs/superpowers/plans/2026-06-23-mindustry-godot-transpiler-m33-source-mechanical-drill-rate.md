# M33 Source Mechanical Drill Rate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Drive the playable mechanical drill's copper output rate from Mindustry source data instead of the handwritten `0.45` progress rate.

**Architecture:** Extract `tier` and `drillTime` from `Blocks.java`. Keep item hardness from `Items.java`. `PortGame.gd` records ore item ids for the demo ore cells, counts copper ore cells under the source-sized mechanical drill footprint, then computes output rate using the source `Drill.getDrillTime(item)` formula: `(drillTime + 50 * item.hardness)` frames per item, converted to `60 * ore_count / delay` items per second.

**Source facts:** `mechanicalDrill` has `tier = 2`, `drillTime = 600`, `size = 2`; `Drill.hardnessDrillMultiplier = 50f`; `copper.hardness = 1`.

**Tech Stack:** Python registry extractor, GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M33 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M33-1 | Confirm source drill facts | `Blocks.java` defines `mechanicalDrill` with `tier = 2`, `drillTime = 600`, `size = 2`; `Drill.java` defines `hardnessDrillMultiplier = 50f` and `getDrillTime(item)` as `(drillTime + hardnessDrillMultiplier * item.hardness) / multiplier`; `Items.java` defines `copper.hardness = 1`. |
| M33-2 | Add failing drill-rate tests | Targeted tests failed because generated drill properties lacked `tier/drillTime` and `PortGame.gd` still advanced factory progress with handwritten `0.45`. |
| M33-3 | Extract drill properties | `_block_properties()` now extracts integer `tier` and numeric `drillTime`; regenerated `mechanical-drill.properties` includes `tier=2` and `drillTime=600`. |
| M33-4 | Use source drill formula in runtime | `PortGame.gd` records ore item ids per cell, counts source-sized drill footprint ore cells, computes `drill_output_rate = 60 * ore_count / (drillTime + 50 * item.hardness)`, and produces `drill_output_item_id` instead of hardcoded copper. |
| M33-5 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `40` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `drill_output_item_id="copper"`, `drill_ore_cell_count=2`, and `drill_output_rate=0.184615384615385`; debug output returned `errors: []`. |
| M33-6 | Update ledger | Design spec now tracks `36` total / `36` done / `0` not done and adds N34/M33 evidence for source mechanical drill rate. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M33 task | Add new tracked work before next milestone. |
