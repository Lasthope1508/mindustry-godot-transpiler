# M57 Source Turret Limit Range Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply source `ItemTurret.limitRange(5f)` to duo ammo lifetimes so Godot bullet travel time matches Java source-derived turret range.

**Architecture:** `source_parity.py` reads duo `limitRange(5f)` directly from `Blocks.java`, then applies Java `Turret.limitRange(BulletType bullet, float margin)` formula to expected ammo lifetime values before comparing generated registry data. `content_registry.py` emits ammo entries, detects `limitRange(...)` calls in `ItemTurret` initializers, and rewrites emitted ammo `lifetime` from source `range`, `rangeChange`, `extraRangeMargin`, and `speed`. `PortGame.gd` continues using generated `lifetime` through `source_bullet_lifetime_seconds()` and exposes MCP runtime summary values for proof.

**Source facts:** `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets duo `range = 160`, copper bullet `speed = 2.5`, graphite bullet `speed = 3.5` and `rangeChange = 16f`, silicon bullet `speed = 3`, then calls `limitRange(5f)`. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java` defines `limitRange()` as `limitRange(9f)` and `limitRange(float margin)` loops all ammo entries. `mindustry-upstream/core/src/mindustry/world/blocks/defense/turrets/Turret.java` defines `float realRange = bullet.rangeChange + range; bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;`. `mindustry-upstream/core/src/mindustry/entities/bullet/BulletType.java` defines `rangeChange = 0f` and `extraRangeMargin = 0f` defaults.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime summary checks, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M57 tasks | 9 |
| Done | 9 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M57-1 Read exact upstream Java facts for duo `limitRange(5f)` and formula.
- [x] M57-2 Add failing source-parity test for computed duo ammo lifetimes.
- [x] M57-3 Add failing generator fixture test for `limitRange(5f)` applied lifetimes.
- [x] M57-4 Add failing playable runtime test for exposed source limit-range lifetime proof.
- [x] M57-5 Implement source-backed limitRange parsing and lifetime calculation.
- [x] M57-6 Regenerate Godot content registry.
- [x] M57-7 Verify targeted and full tests.
- [x] M57-8 Verify MCP LSP/runtime behavior.
- [x] M57-9 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M57-1 | Read exact upstream Java facts for duo `limitRange(5f)` and formula | Read `Blocks.java`, `ItemTurret.java`, `Turret.java`, and `BulletType.java`; plan records exact source formula and default fields. |
| M57-2 | Add failing source-parity test for computed duo ammo lifetimes | Targeted RED failed before implementation with `None != 5.0` for `limitRangeMargin`. |
| M57-3 | Add failing generator fixture test for `limitRange(5f)` applied lifetimes | Targeted RED failed before implementation because fixture duo ammo lifetimes remained `60.0` and omitted `limitRangeMargin`. |
| M57-4 | Add failing playable runtime test for exposed source limit-range lifetime proof | Targeted RED failed before implementation because `PortGame.gd` lacked `selected_turret_limit_range_margin()`. |
| M57-5 | Implement source-backed limitRange parsing and lifetime calculation | `source_parity.py` and `content_registry.py` parse `limitRange(...)`, store `limitRangeMargin`, parse `extraRangeMargin`, and rewrite bullet lifetime with `(range + rangeChange + margin + extraRangeMargin + 10) / speed`. |
| M57-6 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` reported `content items=22 liquids=11 blocks=417 units=56`. |
| M57-7 | Verify targeted and full tests | Targeted 3-test command passed; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `63` tests with `OK`. |
| M57-8 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics returned `[]`; MCP runtime summary returned `selected_turret_limit_range_margin=5` and `selected_turret_ammo_lifetime_seconds=1.16666666666667`; MCP debug output returned `errors: []`. |
| M57-9 | Update docs total/done/not done and commit | Spec now records N58 and status `60/60`; this plan records M57 `9/9`; explicit-file stage and commit follow fresh verification. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M57 item | Add next source-backed migration item after reading upstream Java and writing RED tests. |
