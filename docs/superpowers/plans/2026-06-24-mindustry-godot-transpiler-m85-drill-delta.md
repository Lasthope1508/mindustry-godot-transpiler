# Drill Delta Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire source `DrillBuild.updateTile()` production progress through building `delta()` time-scale math in the Godot playable runtime.

**Architecture:** Read `Drill.java` for `progress += delta() * dominantItems * speed * warmup;`. Keep the existing source-derived drill output rate, but route per-frame production through `source_building_delta(seconds * SOURCE_TICK_RATE, time_scale) / SOURCE_TICK_RATE` so overdrive time-scale metadata affects drill production progress.

**Tech Stack:** Python source parity/playable tests, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Drill Delta Wiring

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add source parity for `progress += delta() * dominantItems * speed * warmup;`. Add playable tests requiring drill output delta helpers and `simulate_factory()` to call them.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because parity/runtime helpers do not exist yet.

- [x] **Step 3: Implement helpers and wiring**

Add `verify_drill_delta_source()`. Add `source_drill_output_delta()`, `source_drill_output_delta_for_cell()`, and `step_factory_drill()`. Update `simulate_factory()` production progress to use the helper.

- [x] **Step 4: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `101` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project and call helpers proving base/boosted drill output deltas, then call `step_factory_drill()`. Debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: apply delta to drill production`.
