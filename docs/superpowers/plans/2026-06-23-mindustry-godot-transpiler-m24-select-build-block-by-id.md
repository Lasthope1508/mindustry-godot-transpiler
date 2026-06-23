# M24 Select Build Block By ID Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow the running Godot port to select any source-derived build block by content id through MCP runtime, then place it in the world.

**Architecture:** Keep the source-wide palette from M23. Add a small `select_build_block_by_id(block_id)` method on `PortGame.gd` that searches `build_palette`, updates `selected_build_index`, and returns a boolean. MCP can call this method directly, then call placement/input commands to verify non-pinned blocks from the source catalog are usable.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M24 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M24-1 | Add failing selector regression test | Targeted unittest failed because `PortGame.gd` did not define `select_build_block_by_id(block_id: String) -> bool` yet |
| M24-2 | Implement build block selector by id | `PortGame.gd` now has `select_build_block_by_id(block_id: String) -> bool`, searches `build_palette`, updates `selected_build_index`, and returns success/failure; targeted unittest passes; MCP LSP diagnostics return `diagnostics: []` |
| M24-3 | Verify Python and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 31 tests ... OK`; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []` |
| M24-4 | Verify runtime MCP selects non-pinned source block | Restarted `scenes/Main.tscn` through MCP; runtime call `select_build_block_by_id("titanium-conveyor")` returns `true`; summary reports `selected_build_id=titanium-conveyor` and `selected_build_index=237`; MCP debug output returns `errors: []` |
| M24-5 | Verify runtime MCP places selected non-pinned block | Runtime MCP sets `core_inventory=1000`, calls `place_selected_block_at_world(Vector2(384, 320))`, and summary `placed_block_count` increases from `1` to `2` with `errors: []` |
| M24-6 | Update ledger and commit | Design spec now includes N25 for build-block selection by id; this plan records all M24 tasks done; checkpoint is committed with message `feat: select build block by id` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M24 task | N/A |
