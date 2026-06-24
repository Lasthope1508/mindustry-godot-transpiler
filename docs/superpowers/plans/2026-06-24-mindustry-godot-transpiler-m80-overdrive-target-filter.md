# Overdrive Target Filter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose the source `OverdriveProjector` target predicate and range filter in Godot runtime without fabricating block eligibility.

**Architecture:** Read `OverdriveProjector.java` for `indexer.eachBlock(... other.block.canOverdrive ...)` and `other.applyBoost(realBoost(), reload + 1f)`. Keep this milestone as a pure helper/state slice: compute real range from generated overdrive params, read target `properties.canOverdrive`, and return whether a candidate target is eligible for later world-scan wiring.

**Tech Stack:** Python source parity tests, GDScript runtime helper in `PortGame.gd`, Godot MCP LSP/runtime proof.

---

### Task 1: Overdrive Target Predicate State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing tests**

Add tests requiring a source parity helper that proves `OverdriveProjector.java` uses `other.block.canOverdrive` and `other.applyBoost(realBoost(), reload + 1f)`, plus a runtime helper that reports `real_range`, `distance`, `can_overdrive`, `in_range`, and `eligible`.

- [x] **Step 2: Run RED tests**

Run targeted tests. Expected: FAIL because the source parity helper and runtime helper do not exist.

- [x] **Step 3: Implement minimal helpers**

Add `verify_overdrive_projector_target_filter_source()` in source parity. Add `source_overdrive_projector_target_filter_state()` and `selected_build_overdrive_target_filter_state_for_block_id()` in `PortGame.gd`.

- [x] **Step 4: Run tests**

Run targeted tests, then full Python suite. Expected: full suite reports `94` tests passing if only the two new tests are added.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `PortGame.gd`. Run project, select `overdrive-projector`, call target filter for `conveyor` at distance `80` expecting `eligible=true`, and call target filter for `overdrive-projector` at distance `80` expecting `can_overdrive=false` and `eligible=false`; debug `errors: []`, stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals/checklist, add row/changelog, run `git diff --check`, stage only related files, and commit `feat: expose overdrive target filter`.
