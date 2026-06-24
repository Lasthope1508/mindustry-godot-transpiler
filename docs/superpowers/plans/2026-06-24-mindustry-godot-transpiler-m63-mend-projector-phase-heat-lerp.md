# Mindustry Godot M63 Mend Projector Phase Heat Lerp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the M62 instant `phaseHeat=1` boost shortcut with source-backed `Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f)` behavior for `MendProjector`.

**Architecture:** Keep the existing MCP boost helper, but make it represent `optionalEfficiency=1` instead of writing phase heat directly. `simulate_mend_projectors(delta)` will advance per-cell phase heat with an Arc-compatible `source_lerp_delta()` helper before range/heal math reads it.

**Tech Stack:** Python `unittest`, Godot 4 GDScript, Godot MCP LSP/runtime, upstream Mindustry Java and Arc `Mathf.java` source.

---

### Source Facts

- `core/src/mindustry/world/blocks/defense/MendProjector.java`: `phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f);`.
- `core/src/mindustry/world/blocks/defense/MendProjector.java`: range uses `range + phaseHeat * phaseRangeBoost`.
- `core/src/mindustry/world/blocks/defense/MendProjector.java`: heal uses `healPercent + phaseHeat * phaseBoost`.
- `Anuken/Arc` commit `f30acd23ec` `arc-core/src/arc/math/Mathf.java`: `lerpDelta(fromValue, toValue, progress)` calls `lerp(fromValue, toValue, clamp(progress * Time.delta))`.
- In Godot runtime, `delta` is seconds, so `source_lerp_delta()` must receive source ticks as `delta * SOURCE_TICK_RATE`.

### Task 1: RED Tests

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`

- [x] **Step 1: Add failing assertions**

Add a test that requires:

```python
self.assertIn("var mend_projector_optional_efficiency: Dictionary = {}", source)
self.assertIn("func source_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:", source)
self.assertIn("return from_value + (to_value - from_value) * clamp(progress * source_delta, 0.0, 1.0)", source)
self.assertIn("mend_projector_optional_efficiency[key] = 1.0", source)
self.assertNotIn("mend_projector_phase_heat[key] = 1.0", source)
self.assertIn("func mend_projector_phase_heat_at_cell(x: int, y: int) -> float:", source)
self.assertIn("mend_projector_phase_heat[key] = source_lerp_delta(float(mend_projector_phase_heat.get(key, 0.0)), float(mend_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)", source)
```

- [x] **Step 2: Verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_lerps_mend_projector_phase_heat_like_source -v
```

Expected: FAIL because runtime still writes `mend_projector_phase_heat[key] = 1.0` directly and lacks `source_lerp_delta()`.

### Task 2: Runtime Implementation

**Files:**
- Modify: `godot-mindustry/src/game/PortGame.gd`

- [x] **Step 1: Implement minimal runtime change**

Add `mend_projector_optional_efficiency`, add `source_lerp_delta()`, change boost helper to set optional efficiency, add `mend_projector_phase_heat_at_cell()`, and update `simulate_mend_projectors()` to compute source delta once and lerp phase heat before checking reload.

- [x] **Step 2: Verify GREEN**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_lerps_mend_projector_phase_heat_like_source tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_simulates_source_mend_projector_phase_boost -v
```

Expected: OK.

### Task 3: MCP Proof And Checklist

**Files:**
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- Modify: this plan file

- [x] Run full tests:

```powershell
python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v
```

Expected: all tests pass.

- [x] Run Godot MCP LSP:

```text
mcp__godot.lsp_diagnostics(projectPath=".../godot-mindustry", scriptPath="src/game/PortGame.gd")
```

Expected: `diagnostics: []`.

- [x] Run Godot MCP runtime proof:

Place `mend-projector`, set `phase-fabric=1`, call `boost_mend_projector_at_cell(2, 2)`, call `mend_projector_phase_heat_at_cell(2, 2)` and verify `0.0`, call `step_mend_projectors(0.0166666666667)`, then verify phase heat `0.1`. Debug output must show `errors: []`.

- [x] Update spec totals and changelog from `65/65/0` to `66/66/0`, adding N64 for M63.

- [x] Stage explicit files only and commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m63-mend-projector-phase-heat-lerp.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: lerp mend projector phase heat"
```
