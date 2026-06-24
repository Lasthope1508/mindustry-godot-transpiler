# Overdrive Apply Boost Target Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply source `OverdriveProjector` boost state to an eligible placed block target in Godot runtime.

**Architecture:** Use the already source-proven `OverdriveProjector.java` call `indexer.eachBlock(this, realRange, other -> other.block.canOverdrive, other -> other.applyBoost(realBoost(), reload + 1f))` and the already ported `BuildingComp.applyBoost()` helper. Store per-placed-block `source_block_time_scale` and `source_block_time_scale_duration` metadata on sprites, choose the first eligible placed target in source range, and expose target id/cell/time-scale state for MCP verification.

**Tech Stack:** GDScript runtime in `PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Apply Overdrive Boost To Target

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing test**

Add a test requiring placed block metadata for source time scale/duration, helper accessors, target selection through `source_overdrive_projector_target_filter_state()`, and `apply_overdrive_boost_to_sprite()` using `source_building_apply_boost_state()`.

- [x] **Step 2: Run RED test**

Run the targeted playable test. Expected: FAIL because target boost application helpers do not exist.

- [x] **Step 3: Implement runtime helpers**

Initialize time-scale metadata in `add_source_block()`. Add `source_block_time_scale_at_cell()`, `source_block_time_scale_duration_at_cell()`, `find_overdrive_boost_target()`, and `apply_overdrive_boost_to_sprite()`. In `simulate_overdrive_projectors()`, when charge reaches reload, apply `realBoost()` for `reload + 1f` to the first eligible target.

- [x] **Step 4: Run tests**

Run targeted test, then full Python suite. Expected: full suite reports `95` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project, place/select an `overdrive-projector` near source conveyors or use existing world state, step overdrive for `1.0` second, and verify the boosted target reports `time_scale=1.5`, `time_scale_duration=61`, while `overdrive-projector` itself remains unboosted due to `canOverdrive=false`; debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: apply overdrive boost to target`.
