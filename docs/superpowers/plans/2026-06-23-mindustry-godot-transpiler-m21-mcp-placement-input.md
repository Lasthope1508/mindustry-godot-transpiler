# M21 MCP Placement Input Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make block placement verifiable through the Godot runtime MCP input path, not only through manual desktop clicks.

**Architecture:** Keep the normal mouse placement path, but route `InputEventMouseButton.position` into a world-position placement helper so runtime-injected mouse events can place blocks deterministically. Extend `get_runtime_summary()` with placed block count and selected build index so MCP can verify a click changed gameplay state.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime commands.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M21 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M21-1 | Add failing placement input regression test | Targeted unittest failed because `PortGame.gd` did not route mouse event positions through a placement helper |
| M21-2 | Implement world-position placement helper | `PortGame.gd` adds `place_selected_block_at_world(world_pos)` and `_unhandled_input()` calls it with `event.position`; targeted unittest passes |
| M21-3 | Expose placement counters in runtime summary | `get_runtime_summary()` returns `placed_block_count` and `selected_build_index`; targeted unittest passes; MCP LSP diagnostics return `diagnostics: []` |
| M21-4 | Verify Python and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 28 tests ... OK`; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []` |
| M21-5 | Verify MCP runtime click placement | Runtime MCP sets `core_inventory=100`, injects key `2` and left mouse click at `(320, 320)`; `placed_block_count` increases from `1` to `2`; `BlockLayer` child count is `13`; MCP debug output returns `errors: []` |
| M21-6 | Update ledger and commit | Design spec now includes N22 for MCP-verified placement input; this plan records all M21 tasks done; checkpoint is committed with message `feat: verify placement through mcp input` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M21 task | N/A |
