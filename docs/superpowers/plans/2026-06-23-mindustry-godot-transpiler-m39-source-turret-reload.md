# M39 Source Turret Reload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make playable turret cooldown use source `ReloadTurret.reload` instead of a handwritten minimum reload guard.

**Architecture:** Generated block data already carries turret `reload`. `PortGame.gd` adds `source_turret_reload_seconds(turret)`, converts source frames to seconds with `reload / 60.0`, uses that value in `simulate_turrets()`, and exposes selected turret reload through the MCP runtime summary.

**Source facts:** `ReloadTurret.java` defaults `reload = 10f`. `Blocks.java` sets duo `reload = 20f`. Generated duo has `reload=20.0`, so expected runtime selected turret reload is `20 / 60 = 0.333333333333333` seconds.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M39 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M39-1 | Confirm source turret reload facts | `ReloadTurret.java` defaults `reload=10f`; `Blocks.java` sets duo `reload=20f`; generated content registry contains duo `reload=20.0`. |
| M39-2 | Add failing runtime reload test | Targeted test failed because `PortGame.gd` had no `source_turret_reload_seconds()`, still used `max(0.1, reload / 60.0)`, and had no summary reload field. |
| M39-3 | Apply source turret reload in runtime | `PortGame.gd` adds `source_turret_reload_seconds(turret)`, uses it in `simulate_turrets()`, and exposes `selected_turret_reload_seconds`. |
| M39-4 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `46` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime summary returned `selected_turret_reload_seconds=0.333333333333333`; debug output returned `errors: []`. |
| M39-5 | Update ledger | Design spec now tracks `42` total / `42` done / `0` not done and adds N40/M39 evidence for source turret reload. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M39 task | Add new tracked work before next milestone. |
