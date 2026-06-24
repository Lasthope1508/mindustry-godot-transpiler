# M61 Source Mend Projector Runtime Heal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make placed `MendProjector` blocks heal damaged placed blocks in the Godot runtime using source `reload`, `range`, and heal formula.

**Architecture:** `PortGame.gd` stores source block id/max health/current health on each placed block sprite. A `mend_projector_charges` dictionary advances by `delta * SOURCE_TICK_RATE`, mirrors Java `charge += heat * delta()`, and heals one damaged block in source range when charge reaches generated `reload`. Runtime MCP helpers damage/read block health and step mend simulation for deterministic proof.

**Source facts:** `MendProjector.java` increments `charge += heat * delta()`, checks `charge >= reload`, computes `realRange = range + phaseHeat * phaseRangeBoost`, and heals damaged blocks with `other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency`. `Blocks.java` sets `mendProjector.reload = 250f`, `range = 85f`, `healPercent = 11f`, `phaseBoost = 15f`, and generated health is `320`; non-phase heal amount is `35.2`.

**Tech Stack:** GDScript runtime helpers, Python source-text tests, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M61 tasks | 8 |
| Done | 8 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M61-1 Read exact upstream Java tick/heal behavior and source values.
- [x] M61-2 Add failing playable runtime test for placed block health state.
- [x] M61-3 Add failing playable runtime test for MendProjector charge/range/heal loop.
- [x] M61-4 Implement placed block source health metadata and MCP health helpers.
- [x] M61-5 Implement source-backed MendProjector simulation.
- [x] M61-6 Verify targeted and full tests.
- [x] M61-7 Verify MCP LSP/runtime behavior.
- [x] M61-8 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M61-1 | Read exact upstream Java tick/heal behavior and source values | Read `MendProjector.java` `updateTile()` charge/range/heal logic and `Blocks.java` `mendProjector` initializer. |
| M61-2 | Add failing playable runtime test for placed block health state | RED targeted run failed because placed sprites did not store source health metadata and health MCP helpers were missing. |
| M61-3 | Add failing playable runtime test for MendProjector charge/range/heal loop | RED targeted run failed because `simulate_mend_projectors()` and charge state were missing. |
| M61-4 | Implement placed block source health metadata and MCP health helpers | Targeted tests pass for metadata plus `damage_block_at_cell()`, `source_block_health_at_cell()`, and `place_selected_block_at_cell()`. |
| M61-5 | Implement source-backed MendProjector simulation | Targeted tests pass for charge, range scan, and heal formula. |
| M61-6 | Verify targeted and full tests | Targeted unittest command passes `2` tests; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` reports `Ran 72 tests` and `OK`. |
| M61-7 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics return `[]`; MCP runtime places `mend-projector`, damages it from `320` to `280`, steps `4.2` seconds, heals `35.2`, and reports health `315.2` with debug `errors: []`. |
| M61-8 | Update docs total/done/not done and commit | Spec updated to `64/64`; explicit staging excludes generated `.uid` files before commit. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M61 item | Add next source-backed migration item after this commit. |
