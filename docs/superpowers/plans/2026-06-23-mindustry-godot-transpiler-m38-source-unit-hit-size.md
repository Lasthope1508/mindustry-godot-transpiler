# M38 Source Unit Hit Size Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable enemy unit sprite size come from source `UnitType.hitSize` instead of scaling every unit to one Godot tile.

**Architecture:** Generated unit data already carries `hitSize`. `PortGame.gd` adds `source_unit_hit_size(unit_type)`, uses it in `spawn_enemy_unit()` for sprite scaling, and exposes selected enemy hit size through the MCP runtime summary.

**Source facts:** `UnitType.java` defines `hitSize` as the size of one side of the hitbox square and defaults to `6f`. `UnitTypes.java` sets dagger `hitSize = 8f`. Generated dagger has `hitSize=8.0`, so expected runtime selected enemy hit size is `8.0`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M38 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M38-1 | Confirm source unit hit size facts | `UnitType.java` defines `hitSize` and defaults it to `6f`; `UnitTypes.java` sets dagger `hitSize=8f`; generated content registry contains dagger `hitSize=8.0`. |
| M38-2 | Add failing runtime hit size test | Targeted test failed because `PortGame.gd` had no `source_unit_hit_size()`, scaled enemy sprites with tile size, and had no summary hit size field. |
| M38-3 | Apply source hit size in runtime | `PortGame.gd` adds `source_unit_hit_size(unit_type)`, scales enemy sprites with `hit_size / texture_size`, and exposes `selected_enemy_hit_size`. |
| M38-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `45` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_enemy_hit_size=8.0`; debug output returned `errors: []`. |
| M38-5 | Update ledger | Design spec now tracks `41` total / `41` done / `0` not done and adds N39/M38 evidence for source unit hit size. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M38 task | Add new tracked work before next milestone. |
