# M53 Source ShootAlternate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source duo `ShootAlternate` spread and use it when choosing playable turret bullet side offsets.

**Architecture:** `source_parity.py` reads duo `shoot = new ShootAlternate(3.5f)` directly from `Blocks.java` and compares generated registry data against it. `content_registry.py` extracts that shoot pattern as block property data. `PortGame.gd` keeps a per-turret barrel counter, computes the alternating side offset from the generated spread, and passes that offset into `source_turret_bullet_origin()` alongside source `shootY`.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo `shoot = new ShootAlternate(3.5f)`. `mindustry-upstream/core/src/mindustry/entities/pattern/ShootAlternate.java` defaults `barrels=2`, assigns constructor `spread`, and computes `index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f` before calling `handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, ...)`.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M53 tasks | 8 |
| Done | 8 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M53-1 | Add failing source-parity test | `test_source_parity.py` asserted duo source `shootPattern={type:ShootAlternate,spread:3.5}`; before implementation, targeted test failed because generated/source parity did not expose `shootPattern`. |
| M53-2 | Add failing generator test | `test_content_registry.py` added `shoot = new ShootAlternate(3.5f);` to the fixture duo turret and expected generated `properties.shootPattern`; before implementation, targeted test failed because the registry omitted it. |
| M53-3 | Add failing playable runtime test | `test_playable.py` required `turret_barrel_counters`, `source_turret_shoot_pattern()`, `use_turret_shoot_x_offset()`, `last_turret_fired_shoot_x_offset`, and runtime summary fields; before implementation, targeted test failed because runtime lacked those symbols. |
| M53-4 | Extract source ShootAlternate pattern | `content_registry.py` and `source_parity.py` now parse `new ShootAlternate(3.5f)` and emit/check `shootPattern={type:ShootAlternate,spread:3.5}`. |
| M53-5 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` regenerated `godot-mindustry/src/generated/content_registry.json` and `MindustryContentRegistry.gd`; duo properties include `shootPattern`. |
| M53-6 | Use ShootAlternate in playable turret fire | `PortGame.gd` initializes and clears `turret_barrel_counters` with turret cells, computes alternating `shoot_x_offset` from generated spread, records `last_turret_fired_shoot_x_offset`, and passes it into `source_turret_bullet_origin()`. |
| M53-7 | Verify tests and Godot diagnostics | Targeted source-parity/content/playable tests passed, then `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `60` tests OK; MCP LSP diagnostics for `src/game/PortGame.gd` returned `diagnostics: []`. |
| M53-8 | Verify deterministic MCP runtime behavior | MCP runtime disabled `_process`, read `selected_turret_shoot_pattern={spread:3.5,type:ShootAlternate}`, loaded two copper items, called `simulate_turrets(100.0)` twice, and read `last_turret_fired_shoot_x_offset=-1.75` after shot one, `last_turret_fired_shoot_x_offset=1.75` after shot two, `last_turret_fired_shoot_y=3`; MCP debug output returned `errors: []`. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M53 task | Add new tracked work before next milestone. |
