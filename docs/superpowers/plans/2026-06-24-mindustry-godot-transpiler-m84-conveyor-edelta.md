# Conveyor Edelta Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire source `ConveyorBuild.updateTile()` movement through building `edelta()` time-scale math in the Godot playable runtime.

**Architecture:** Read `Conveyor.java` for `float moved = speed * edelta();`. Keep the existing source-derived conveyor path rate, but route per-frame progress through `source_building_edelta(seconds * SOURCE_TICK_RATE, time_scale, efficiency)` so overdrive time-scale metadata affects conveyor item motion.

**Tech Stack:** Python source parity/playable tests, GDScript runtime in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Conveyor Edelta Wiring

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add source parity for `float moved = speed * edelta();`. Add playable tests requiring conveyor progress delta helpers and `simulate_factory()` to call them.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because parity/runtime helpers do not exist yet.

- [x] **Step 3: Implement helpers and wiring**

Add `verify_conveyor_edelta_source()`. Add `source_conveyor_path_progress_delta()`, `source_conveyor_path_progress_delta_for_cell()`, and `step_factory_transport()`. Update `simulate_factory()` transport progress to use the helper.

- [x] **Step 4: Run tests**

Run targeted tests, then full suite. Expected: full suite reports `100` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project and call helpers proving base/boosted conveyor progress deltas, then call `step_factory_transport()` after applying overdrive metadata. Debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: apply edelta to conveyor transport`.
