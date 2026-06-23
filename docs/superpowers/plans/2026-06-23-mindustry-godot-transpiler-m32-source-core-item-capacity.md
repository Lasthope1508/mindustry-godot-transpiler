# M32 Source Core Item Capacity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enforce the source `core-shard.itemCapacity = 4000` in the playable Godot runtime.

**Architecture:** Extract block `itemCapacity` from `Blocks.java` into generated content registry data. `PortGame.gd` reads `core-shard` through `ContentCatalog`, stores the source capacity in `core_item_capacity`, and clamps core item counts through one setter path used by production, spending, and MCP runtime calls.

**Source fact:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` defines `coreShard = new CoreBlock("core-shard"){{ ... itemCapacity = 4000; ... }}`.

**Tech Stack:** Python registry extractor, GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M32 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M32-1 | Confirm source capacity | `Blocks.java` contains `coreShard = new CoreBlock("core-shard"){{ ... itemCapacity = 4000; size = 3; }}`. |
| M32-2 | Add failing capacity regression tests | Targeted registry/runtime tests failed before implementation because `itemCapacity` was not extracted and `PortGame.gd` had no `core_item_capacity` clamp path. |
| M32-3 | Extract block item capacity | `_block_properties()` now includes `itemCapacity`; regenerated `content_registry.json` has `core-shard.properties.itemCapacity=4000`. |
| M32-4 | Clamp runtime core items | `PortGame.gd` initializes `core_item_capacity = source_block_item_capacity("core-shard")`, exposes it in `get_runtime_summary()`, and routes `set_core_item_count()` through `clamp_core_item_amount()`. |
| M32-5 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `39` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `core_item_capacity=4000`; after `set_core_item_count("copper", 9999)`, summary returned `core_items.copper=4000` and `core_inventory=4000`; debug output returned `errors: []`. |
| M32-6 | Update ledger | Design spec now tracks `35` total / `35` done / `0` not done and adds N33/M32 evidence for source core item capacity. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M32 task | Add new tracked work before next milestone. |
