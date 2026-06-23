# M25 Source Block Size Rendering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make placed block sprites respect source-derived block `size` metadata instead of rendering every block as one tile.

**Architecture:** Add small helpers in `PortGame.gd` for `block_size(block)`, `block_world_size(block)`, and `configure_block_sprite(sprite, block, cell)`. Reuse the helper for placed blocks and source blocks. Record `last_placed_block_id`, `last_placed_block_size`, and `last_placed_cell` in runtime summary so MCP can prove large blocks render/place with source dimensions.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M25 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M25-1 | Add failing block-size regression test | `python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_uses_source_block_size_for_placement -v` failed because `PortGame.gd` did not yet define `last_placed_block_id` or size helpers. |
| M25-2 | Implement source block size helpers | Targeted unittest passed after `block_size`, `block_world_size`, and `configure_block_sprite` were added and reused for placement/source blocks. |
| M25-3 | Expose last placed block size in runtime summary | Targeted unittest passed after summary exposed `last_placed_block_id`, `last_placed_block_size`, and `last_placed_cell`. |
| M25-4 | Verify Python and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran 32 tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`. |
| M25-5 | Verify runtime MCP places a large source block | Restarted `scenes/Main.tscn` through MCP, selected `solar-panel-large`, placed at cell `(11, 10)`, summary returned `last_placed_block_size=3`, and debug output returned `errors: []`. |
| M25-6 | Update ledger | Design spec was updated from `27/27` to `28/28` tracked done items with N26 evidence, and this plan records all M25 tasks as done. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M25 task | N/A |
