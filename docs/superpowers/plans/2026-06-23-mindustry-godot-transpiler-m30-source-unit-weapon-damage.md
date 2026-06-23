# M30 Source Unit Weapon Damage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace handwritten enemy core damage with source-derived unit weapon bullet damage.

**Architecture:** Extend content registry extraction for `UnitType` weapon data. For each unit initializer, extract `weapons.add(new Weapon(...))`, `reload`, and first `BasicBulletType(speed, damage)` plus `lifetime`. `PortGame.gd` reads the selected enemy unit's first weapon bullet damage and uses that value when a unit reaches the core.

**Tech Stack:** Python registry extractor, GDScript runtime, Python unittest, Godot 4.6.2 MCP runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M30 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M30-1 | Confirm source weapon data | `UnitTypes.java` `dagger` has `weapons.add(new Weapon("large-weapon"))`, `reload = 13f`, and `bullet = new BasicBulletType(2.5f, 9)` with `lifetime = 60f`. |
| M30-2 | Add failing registry and runtime tests | Targeted tests failed because unit registry lacked `properties.weapons` and `PortGame.gd` still subtracted hardcoded `15.0` from `core_health`. |
| M30-3 | Extract unit weapon bullet data | `_unit_weapons()` now extracts first `BasicBulletType` speed/damage/lifetime and weapon reload into `properties.weapons`; generated `dagger` data contains damage `9`. |
| M30-4 | Use source unit weapon damage at core | `PortGame.gd` adds `source_unit_weapon_damage(unit_type)`, uses it in `simulate_enemy_units()`, and exposes `selected_enemy_weapon_damage` in runtime summary. |
| M30-5 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `37` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; restarted runtime summary returned `selected_enemy_weapon_damage=9`; debug output returned `errors: []`. |
| M30-6 | Update ledger and commit | Design spec now tracks `33` total / `33` done / `0` not done and adds N31/M30 evidence for source unit weapon damage; this checkpoint is committed as `feat: use source unit weapon damage`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M30 task | Add new tracked work before next milestone. |
