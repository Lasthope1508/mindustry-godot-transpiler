# M51 Source Parity And Ammo Range Change Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent fabricated duo turret values by verifying generated Godot data against upstream Java source, then port source ammo `rangeChange` into turret targeting.

**Architecture:** `source_parity.py` reads `mindustry-upstream/core/src/mindustry/content/Blocks.java`, extracts the duo `ItemTurret` initializer, and compares source-derived facts against `godot-mindustry/src/generated/content_registry.json`. `content_registry.py` extracts `rangeChange` from `BasicBulletType` bodies. `PortGame.gd` peeks the loaded ammo stack before target search, computes `source_turret_range(turret) + source_bullet_range_change(data)`, then consumes ammo only when a target exists.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo base `range = 160`, graphite ammo `damage = 18`, `ammoMultiplier = 4`, `reloadMultiplier = 0.8f`, and `rangeChange = 16f`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` computes range/fog radius with `range + peekAmmo().rangeChange`. `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defaults `rangeChange = 0f`.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M51 tasks | 7 |
| Done | 7 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M51-1 | Add source-parity anti-fabrication test | `test_source_parity.py` calls `verify_duo_source_parity()` and asserts source path `core/src/mindustry/content/Blocks.java`, block `duo`, empty mismatches, and source-derived duo values including graphite `rangeChange=16.0`. |
| M51-2 | Verify RED before implementation | Targeted source-parity/content/playable tests failed before implementation: generated registry lacked `rangeChange`, and `PortGame.gd` lacked `source_bullet_range_change()`, `source_turret_range_for_ammo()`, and fired range summary. |
| M51-3 | Extract source ammo rangeChange | `content_registry.py` now records `rangeChange` from `BasicBulletType` bodies when source assigns it, leaving the default to `source_bullet_range_change(data)` fallback `0.0` when omitted. |
| M51-4 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` wrote generated registry files; `content_registry.json` contains duo graphite `rangeChange: 16.0`. |
| M51-5 | Use loaded ammo range for turret targeting | `PortGame.gd` now peeks loaded turret ammo before target search, computes range with `source_turret_range_for_ammo(duo, data)`, records `last_turret_fired_range`, and exposes `selected_turret_ammo_range_change`. |
| M51-6 | Verify tests and Godot diagnostics | `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `58` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`. |
| M51-7 | Verify deterministic MCP runtime behavior | MCP runtime disabled `_process`, loaded one graphite item (`load_selected_turret_ammo("graphite", 1)` returned `1`, `selected_turret_total_ammo=4`), called `simulate_turrets(0.0)`, and read `last_turret_fired_ammo_item="graphite"`, `last_turret_fired_damage=18`, `last_turret_fired_reload_multiplier=0.8`, `last_turret_fired_range=176`, `selected_turret_total_ammo=3`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M51 task | Add new tracked work before next milestone. |
