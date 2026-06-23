# M48 Source Turret Ammo Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source item turret ammo stack loading and consumption helpers without inventing initial ammo.

**Architecture:** `PortGame.gd` keeps per-turret-cell `turret_ammo_stacks` and `turret_total_ammo`. `handle_turret_item()` mirrors `ItemTurretBuild.handleItem()` by adding `BulletType.ammoMultiplier` to the item stack and moving the active stack to the right. `use_turret_ammo()` mirrors `TurretBuild.useAmmo()` by peeking the rightmost stack, subtracting `ammoPerShot`, popping empty stacks, and returning source bullet data. Public selected-duo methods exist for MCP verification only; no fake initial ammo is injected.

**Source facts:** `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java` defines `handleItem()` stack update and right-swap behavior. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` defines `useAmmo()` decrement/pop behavior and `hasAmmo()` fallback swap for stacks with enough ammo.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M48 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M48-1 | Confirm source ammo stack behavior | `ItemTurretBuild.handleItem()` adds `type.ammoMultiplier`, merges existing item stacks, and swaps the item stack to the right; `TurretBuild.useAmmo()` subtracts `ammoPerShot`, pops empty stacks, and returns the active ammo type. |
| M48-2 | Add failing playable test | Targeted playable test failed because `PortGame.gd` lacked `turret_ammo_stacks`, `turret_total_ammo`, source ammo lookup, load/use helpers, and runtime summary ammo stack fields. |
| M48-3 | Port runtime ammo stack helpers | `PortGame.gd` now initializes/cleans per-cell ammo stacks with turret registration, loads source ammo by item id, consumes one shot from the active stack, and exposes selected-duo load/use methods. |
| M48-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `55` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime loaded two copper items into duo, producing `selected_turret_total_ammo=4`, `selected_turret_ammo_stack_count=1`, `selected_turret_loaded_ammo_item="copper"`, then `use_selected_turret_ammo_once()` returned copper bullet damage `9` and summary total `3`; MCP debug output returned `errors: []`. |
| M48-5 | Update ledger | Design spec now tracks `51` total / `51` done / `0` not done and adds N49/M48 evidence for source item turret ammo stack logic. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M48 task | Add new tracked work before next milestone. |
