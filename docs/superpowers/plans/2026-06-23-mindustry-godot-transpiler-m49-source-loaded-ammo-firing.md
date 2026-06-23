# M49 Source-Loaded Ammo Firing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the playable Godot turret fire only from loaded source ammo stacks, matching Mindustry source behavior enough for this slice.

**Architecture:** `simulate_turrets()` calls `use_turret_ammo(cell, duo)` before spawning a bullet. Empty ammo returns `{}` and prevents shooting. `spawn_turret_bullet()` receives the exact bullet data returned by the ammo stack, records the fired item/damage counters, then creates the projectile from that data. No fake starting ammo is injected.

**Source facts:** `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` uses `hasAmmo()`, `peekAmmo()`, and `useAmmo()` around shooting. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java` supplies item-backed ammo stacks through `handleItem()`.

**Tech Stack:** GDScript runtime, Python unittest, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M49 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M49-1 | Confirm source firing path | `Turret.java` shooting path depends on available ammo and consumes ammo through `useAmmo()` before bullet behavior continues; no source behavior supports firing unloaded item turrets. |
| M49-2 | Add failing playable test | Targeted playable test failed because `PortGame.gd` did not expose `turret_shot_count`, `last_turret_fired_ammo_item`, or `last_turret_fired_damage` counters for source-loaded ammo firing proof. |
| M49-3 | Port loaded-ammo firing path | `simulate_turrets()` now uses `var data := use_turret_ammo(cell, duo)`, checks `if not data.is_empty():`, and calls `spawn_turret_bullet(grid_to_world(cell), target, data)`; `spawn_turret_bullet()` no longer reads `duo.properties.ammo[0]`. |
| M49-4 | Add runtime firing counters | `PortGame.gd` now keeps `turret_shot_count`, `last_turret_fired_ammo_item`, and `last_turret_fired_damage`, updates them when a bullet is spawned from loaded ammo, and reports them in `get_runtime_summary()`. |
| M49-5 | Verify tests and MCP runtime | Targeted test `test_port_game_turret_fire_uses_source_loaded_ammo` passed; `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `56` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`; MCP runtime loaded three copper items into duo (`selected_turret_total_ammo=6`) and observed one shot with `last_turret_fired_ammo_item="copper"`, `last_turret_fired_damage=9`, `turret_shot_count=1`, `selected_turret_total_ammo=5`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M49 task | Add new tracked work before next milestone. |
