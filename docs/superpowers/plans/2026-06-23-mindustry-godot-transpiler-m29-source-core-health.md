# M29 Source Core Health Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize playable core health from source-derived `core-shard.health` instead of a handwritten constant.

**Architecture:** Keep block data in the generated content registry. `PortGame.gd` reads the existing `core-shard` content object from `MindustryContentCatalog`, pulls `properties["health"]`, and exposes the value through the existing runtime summary/HUD.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M29 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M29-1 | Confirm source data exists | `content_registry.json` entry for `core-shard` has `properties.health=1100`, matching `Blocks.java` `coreShard` initializer. |
| M29-2 | Add failing source core health regression test | `python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_initializes_core_health_from_source_block -v` failed because `PortGame.gd` still declared `var core_health := 500.0`. |
| M29-3 | Read core health from source catalog in runtime | Targeted unittest passed after `PortGame.gd` added `source_block_health("core-shard")`, `core_max_health`, and initialized `core_health = core_max_health`. |
| M29-4 | Verify Python, Godot diagnostics, and MCP runtime behavior | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `36` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; restarted runtime summary returned `core_max_health=1100`; debug output returned `errors: []`. |
| M29-5 | Update ledger and commit | Design spec now tracks `32` total / `32` done / `0` not done and adds N30/M29 evidence for source core health; this checkpoint is committed as `feat: use source core health`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M29 task | Add new tracked work before next milestone. |
