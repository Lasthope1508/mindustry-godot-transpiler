# M40 Source Turret Range Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable turret targeting range flow through source `BaseTurret.range` instead of reading the generated field inline without traceable helper/summary evidence.

**Architecture:** Generated block data already carries turret `range`. `PortGame.gd` adds `source_turret_range(turret)`, uses that value in `simulate_turrets()` targeting, and exposes selected turret range through the MCP runtime summary.

**Source facts:** `BaseTurret.java` defaults `range = 80f`. `Blocks.java` sets duo `range = 160`. Generated duo has `range=160`, so expected runtime selected turret range is `160.0`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M40 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M40-1 | Confirm source turret range facts | `BaseTurret.java` defaults `range=80f`; `Blocks.java` sets duo `range=160`; generated content registry contains duo `range=160`. |
| M40-2 | Add failing runtime range test | Targeted test failed because `PortGame.gd` had no `source_turret_range()`, read range inline, and had no summary range field. |
| M40-3 | Apply source turret range in runtime | `PortGame.gd` adds `source_turret_range(turret)`, uses it in `simulate_turrets()`, and exposes `selected_turret_range`. |
| M40-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `47` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_range=160.0`; debug output returned `errors: []`. |
| M40-5 | Update ledger | Design spec now tracks `43` total / `43` done / `0` not done and adds N41/M40 evidence for source turret range. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M40 task | Add new tracked work before next milestone. |
