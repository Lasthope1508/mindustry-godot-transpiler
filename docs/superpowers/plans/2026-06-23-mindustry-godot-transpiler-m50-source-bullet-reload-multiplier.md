# M50 Source Bullet Reload Multiplier Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract `BulletType.reloadMultiplier` from source ammo and use it for item turret firing cadence in the Godot playable slice.

**Architecture:** `content_registry.py` reads `reloadMultiplier` assignments inside `BasicBulletType` ammo initializers. `PortGame.gd` keeps the base turret reload helper for source `reload / 60`, adds `source_bullet_reload_multiplier(data)` with source default `1.0`, and sets the post-shot cooldown through `source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)`. Runtime summary exposes fired reload multiplier and current selected turret cooldown for MCP proof.

**Source facts:** `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defines `public float reloadMultiplier = 1f`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` returns `peekAmmo().reloadMultiplier` from `ammoReloadMultiplier()` and increments reload by `delta() * ammoReloadMultiplier() * baseReloadSpeed()`. `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo graphite `reloadMultiplier = 0.8f` and silicon `reloadMultiplier = 1.5f`.

**Tech Stack:** Python content generator/tests, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M50 tasks | 6 |
| Done | 6 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M50-1 | Confirm source reload multiplier behavior | `BulletType.java` default is `reloadMultiplier=1f`; `TurretBuild.ammoReloadMultiplier()` returns `peekAmmo().reloadMultiplier`; duo source ammo sets graphite `0.8f` and silicon `1.5f`. |
| M50-2 | Add failing generator/runtime tests | Targeted content-registry test failed until `reloadMultiplier` was extracted; targeted playable test failed until runtime exposed `source_bullet_reload_multiplier()`, ammo-aware reload seconds, fired multiplier, and selected turret cooldown summary. |
| M50-3 | Extract source ammo reload multiplier | `content_registry.py` now records `reloadMultiplier` from `BasicBulletType` bodies when source assigns it, leaving default fallback to runtime/source default when source omits it. |
| M50-4 | Use reload multiplier in firing cooldown | `PortGame.gd` now sets turret cooldown with `source_turret_reload_seconds_for_ammo(duo, data)`, which computes `source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)`. |
| M50-5 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` wrote generated registry files with duo graphite `reloadMultiplier=0.8` and silicon `reloadMultiplier=1.5`. |
| M50-6 | Verify tests and MCP runtime | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `57` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; deterministic MCP runtime disabled `_process`, loaded two silicon items (`selected_turret_total_ammo=10`), called `simulate_turrets(0.0)`, and read `last_turret_fired_reload_multiplier=1.5`, `selected_turret_cooldown_seconds=0.222222222222222`, `selected_turret_total_ammo=9`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M50 task | Add new tracked work before next milestone. |
