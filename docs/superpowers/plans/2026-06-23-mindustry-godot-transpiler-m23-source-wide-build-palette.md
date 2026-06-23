# M23 Source-Wide Build Palette Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the playable build palette include every source-derived block that has a copied texture, not only six hardcoded smoke-test blocks.

**Architecture:** Keep a small pinned block list only for initial ordering, then append all textured `block` content from `MindustryContentCatalog`. Add next/previous selection keys so the runtime can cycle beyond numeric slots, and expose the selected block id in `get_runtime_summary()` for MCP verification.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M23 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M23-1 | Add failing source-wide palette regression test | Targeted unittest failed because `PortGame.gd` still only used fixed `BUILD_BLOCK_IDS` |
| M23-2 | Implement source-wide textured build palette | `build_block_palette()` now keeps pinned blocks first, then appends every textured `content_catalog.get_many("block")` entry; targeted unittest passes |
| M23-3 | Add palette cycling and selected block summary | `select_next_build_slot()`, `select_previous_build_slot()`, `Tab` cycling, and runtime summary `selected_build_id` exist; targeted unittest passes; MCP LSP diagnostics return `diagnostics: []` |
| M23-4 | Verify Python and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 30 tests ... OK`; MCP LSP diagnostics for `PortGame.gd` return `diagnostics: []` |
| M23-5 | Verify runtime MCP sees source-wide palette | Restarted `scenes/Main.tscn` through MCP; runtime summary reports `build_palette_size=416`, `selected_build_id=conveyor`, then injected `Tab` changes selection to `router`; MCP debug output returns `errors: []` |
| M23-6 | Update ledger and commit | Design spec now includes N24 for source-wide build palette; this plan records all M23 tasks done; checkpoint is committed with message `feat: use source-wide build palette` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M23 task | N/A |
