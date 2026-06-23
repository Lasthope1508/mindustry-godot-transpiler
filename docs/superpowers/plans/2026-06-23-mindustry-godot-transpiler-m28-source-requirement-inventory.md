# M28 Source Requirement Inventory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make placement affordability spend every source-derived requirement item, not only copper.

**Architecture:** Keep `core_inventory` as the copper compatibility alias and add `core_items` keyed by source item id. Add helpers to set/add/count items for MCP tests and use them from `can_afford()` and `spend_requirements()` over every entry in `block.properties["requirements"]`.

**Tech Stack:** GDScript, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M28 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M28-1 | Add failing source requirement inventory regression test | `python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_uses_all_source_requirement_items -v` failed because `PortGame.gd` lacks `core_items` and still checks/spends only copper requirements. |
| M28-2 | Add source item inventory helpers | Targeted unittest passed after `core_items`, `set_core_item_count`, `add_core_item`, `core_item_count`, and copper alias sync were added. |
| M28-3 | Use all source requirements for affordability/spending | Targeted unittest passed after `can_afford()` and `spend_requirements()` iterated every source requirement item id and amount instead of hardcoding copper. |
| M28-4 | Expose source item inventory in runtime summary | Targeted unittest passed after runtime summary exposed `core_items.duplicate()`. |
| M28-5 | Verify Python, Godot diagnostics, and MCP runtime behavior | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `35` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; runtime MCP selected `titanium-conveyor`, rejected placement with `lead=0` and `titanium=0`, accepted after setting `copper/lead/titanium=100`, and debug output returned `errors: []`. |
| M28-6 | Update ledger and commit | Design spec now tracks `31` total / `31` done / `0` not done and adds N29/M28 evidence for source requirement inventory; this checkpoint is committed as `feat: use source item requirements`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M28 task | Add new tracked work before next milestone |
