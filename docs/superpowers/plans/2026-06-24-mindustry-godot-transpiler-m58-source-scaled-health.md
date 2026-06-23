# M58 Source Scaled Health Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract source `Block.scaledHealth` values and compute generated block `health` for blocks that do not assign explicit `health`.

**Architecture:** `source_parity.py` reads `mendProjector = new MendProjector("mend-projector")` from `Blocks.java`, extracts `size = 2` and `scaledHealth = 80`, and compares computed `health = int(size * size * scaledHealth)` against the generated registry. `content_registry.py` extracts numeric `scaledHealth` assignments and writes both `scaledHealth` and computed `health` when the initializer does not assign explicit `health`. `PortGame.gd` exposes selected build health through runtime summary so MCP can select `mend-projector` and verify source-derived health live.

**Source facts:** `mindustry-upstream/core/src/mindustry/world/Block.java` declares `scaledHealth = -1` and `health = -1`; `Block.init()` computes default health only when `health == -1`, and if `scaledHealth >= 0`, sets `health = (int)(size * size * scaledHealth)`. `mindustry-upstream/core/src/mindustry/content/Blocks.java` sets `mendProjector` size `2` and `scaledHealth = 80`, with no explicit `health`, so generated `mend-projector.health` must be `320`.

**Tech Stack:** Python source-parity tests, Python content generator, GDScript runtime summary checks, Godot 4.6.2 MCP LSP/runtime tools.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M58 tasks | 9 |
| Done | 9 |
| Not done | 0 |
| Blocked | 0 |

## Execution Checklist

- [x] M58-1 Read exact upstream Java facts for `Block.scaledHealth` and `mend-projector` source values.
- [x] M58-2 Add failing source-parity test for `mend-projector.scaledHealth` and computed `health`.
- [x] M58-3 Add failing generator fixture test for `scaledHealth` computed health.
- [x] M58-4 Add failing playable runtime test for selected build health summary.
- [x] M58-5 Implement source-backed `scaledHealth` extraction and computed `health`.
- [x] M58-6 Regenerate Godot content registry.
- [x] M58-7 Verify targeted and full tests.
- [x] M58-8 Verify MCP LSP/runtime behavior.
- [x] M58-9 Update docs total/done/not done and commit.

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M58-1 | Read exact upstream Java facts for `Block.scaledHealth` and `mend-projector` source values | Read `Block.java` `init()` health formula and `Blocks.java` `mendProjector` initializer; plan records exact source formula and expected `320`. |
| M58-2 | Add failing source-parity test for `mend-projector.scaledHealth` and computed `health` | Targeted RED failed before implementation because `verify_mend_projector_scaled_health_parity` was missing, then parity failed against old generated registry with missing `scaledHealth` and `health`. |
| M58-3 | Add failing generator fixture test for `scaledHealth` computed health | Targeted RED failed before implementation with `None != 80` for fixture `scaledHealth`. |
| M58-4 | Add failing playable runtime test for selected build health summary | Targeted RED failed before implementation because `PortGame.gd` lacked `selected_build_health()` and `selected_build_scaled_health()`. |
| M58-5 | Implement source-backed `scaledHealth` extraction and computed `health` | `content_registry.py` extracts numeric `scaledHealth` and computes `health = int(size * size * scaledHealth)` only when source has no `health` assignment; `source_parity.py` reads and compares `mend-projector`. |
| M58-6 | Regenerate Godot content registry | `python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry` reported `content items=22 liquids=11 blocks=417 units=56`. |
| M58-7 | Verify targeted and full tests | Targeted 3-test command passed; full `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v` ran `66` tests with `OK`. |
| M58-8 | Verify MCP LSP/runtime behavior | MCP LSP diagnostics returned `[]`; MCP runtime selected `mend-projector` and returned `selected_build_health=320`, `selected_build_scaled_health=80`, empty generated load/instance failures, and debug `errors: []`. |
| M58-9 | Update docs total/done/not done and commit | Spec now records N59 and status `61/61`; this plan records M58 `9/9`; explicit-file stage and commit follow fresh verification. |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M58 item | Add next source-backed migration item after reading upstream Java and writing RED tests. |
