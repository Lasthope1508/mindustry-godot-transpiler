# OverdriveProjector Update State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `OverdriveBuild.updateTile()` state progression into Godot runtime helpers.

**Architecture:** Mirror the existing `MendProjector` runtime-state pattern, but keep this milestone scoped to the `OverdriveProjector` state values and boost-event summary. Treat placed Overdrive efficiency as `1.0` like current placed MendProjector runtime until source power graph migration exists.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Update State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add one test requiring source-backed dictionaries, booster helper, accessors, and `simulate_overdrive_projectors()` formulas from `OverdriveProjector.java`:

```python
def test_port_game_advances_overdrive_projector_update_state_like_source(self):
    port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
    source = port_game.read_text(encoding="utf-8")

    self.assertIn("var overdrive_projector_charges: Dictionary = {}", source)
    self.assertIn("var overdrive_projector_smooth_efficiency: Dictionary = {}", source)
    self.assertIn("var overdrive_projector_heat: Dictionary = {}", source)
    self.assertIn("var overdrive_projector_phase_heat: Dictionary = {}", source)
    self.assertIn("var overdrive_projector_optional_efficiency: Dictionary = {}", source)
    self.assertIn("var overdrive_projector_booster_items: Dictionary = {}", source)
    self.assertIn("var overdrive_projector_use_progress: Dictionary = {}", source)
    self.assertIn("func boost_overdrive_projector_at_cell(x: int, y: int) -> bool:", source)
    self.assertIn("func simulate_overdrive_projectors(delta: float) -> void:", source)
    self.assertIn("overdrive_projector_smooth_efficiency[key] = source_lerp_delta(float(overdrive_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
    self.assertIn("overdrive_projector_heat[key] = source_lerp_delta(float(overdrive_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)", source)
    self.assertIn("if bool(block.properties.get(\"hasBoost\", false)):", source)
    self.assertIn("overdrive_projector_phase_heat[key] = source_lerp_delta(float(overdrive_projector_phase_heat.get(key, 0.0)), float(overdrive_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)", source)
    self.assertIn("overdrive_projector_charges[key] = float(overdrive_projector_charges.get(key, 0.0)) + float(overdrive_projector_heat.get(key, 0.0)) * source_delta", source)
    self.assertIn("last_overdrive_projector_boost_duration = float(block.properties.get(\"reload\", 0.0)) + 1.0", source)
    self.assertIn("overdrive_projector_use_progress[key] = fmod(float(overdrive_projector_use_progress.get(key, 0.0)), float(block.properties.get(\"useTime\", 0.0)))", source)
    self.assertIn("func step_overdrive_projectors(seconds: float) -> Dictionary:", source)
```

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_advances_overdrive_projector_update_state_like_source
```

Expected: FAIL because Overdrive update-state dictionaries and helpers do not exist.

- [x] **Step 3: Implement GDScript state helpers**

Add Overdrive state dictionaries near the MendProjector state dictionaries. Add helpers near existing Overdrive helpers and call `simulate_overdrive_projectors(delta)` from `_process()` after `simulate_mend_projectors(delta)`.

Key source formulas from `OverdriveProjector.java`:

```gdscript
overdrive_projector_smooth_efficiency[key] = source_lerp_delta(float(overdrive_projector_smooth_efficiency.get(key, 0.0)), 1.0, 0.08, source_delta)
overdrive_projector_heat[key] = source_lerp_delta(float(overdrive_projector_heat.get(key, 0.0)), 1.0, 0.08, source_delta)
overdrive_projector_charges[key] = float(overdrive_projector_charges.get(key, 0.0)) + float(overdrive_projector_heat.get(key, 0.0)) * source_delta
overdrive_projector_phase_heat[key] = source_lerp_delta(float(overdrive_projector_phase_heat.get(key, 0.0)), float(overdrive_projector_optional_efficiency.get(key, 0.0)), 0.1, source_delta)
overdrive_projector_use_progress[key] = float(overdrive_projector_use_progress.get(key, 0.0)) + source_delta
```

- [x] **Step 4: Run tests**

Run targeted test, then full suite. Expected: full suite reports `90` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Run project, select/build `overdrive-projector`, boost it with phase fabric, call `step_overdrive_projectors(1.0 / 60.0)`, and verify heat/smooth `0.08`, charge `0.08`, phase heat `0.1`, use progress `1`, debug `errors: []`, and stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals from `79/79/0` to `80/80/0`, checklist from `N49-N77` to `N49-N78`, add row `N78`, and changelog `M77 source OverdriveProjector update state`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m77-overdrive-update-state.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose overdrive update state"
```
