# M27 Source World Occupancy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make prebuilt source blocks in the playable world occupy their source-sized footprint so players cannot place new blocks over drills, conveyors, the core, or the starting turret.

**Architecture:** Route initial world block creation through `add_source_block()` instead of raw `add_sprite()` for block-layer objects. Track `initial_world_block_count` and `initial_occupied_cell_count` after `build_world()` so MCP can prove the map starts with occupied cells before user placement.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M27 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M27-1 | Add failing source-world occupancy regression test | `python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_records_initial_source_world_occupancy -v` failed because `PortGame.gd` lacks `initial_world_block_count` and still uses raw block-layer sprites for mechanical drill, conveyors, and core shard. |
| M27-2 | Build initial block layer from source blocks | Targeted unittest passed after mechanical drill, conveyors, core shard, and duo were routed through `add_source_block()` with source ids. |
| M27-3 | Expose initial world occupancy counters | Targeted unittest passed after `initial_world_block_count` and `initial_occupied_cell_count` were recorded after world setup and exposed in runtime summary. |
| M27-4 | Verify Python and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran 34 tests OK; MCP LSP diagnostics for `PortGame.gd` returned `diagnostics: []`. |
| M27-5 | Verify MCP runtime rejects placement on prebuilt world cells | Restarted `scenes/Main.tscn` through MCP; runtime summary reported `initial_world_block_count=12` and `initial_occupied_cell_count=22`; placement on conveyor cell `(8, 8)` and core cell `(17, 8)` both returned `false`, `last_place_blocked=true`, counts stayed unchanged, and debug output returned `errors: []`. |
| M27-6 | Update ledger | Design spec was updated from `29/29` to `30/30` tracked done items with N28 evidence, and this plan records all M27 tasks as done. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M27 task | N/A |
