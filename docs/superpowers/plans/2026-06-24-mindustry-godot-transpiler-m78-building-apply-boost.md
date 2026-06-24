# Building ApplyBoost Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `BuildingComp.applyBoost()` state math into Godot runtime helpers.

**Architecture:** Add a pure helper in `PortGame.gd` before wiring Overdrive target scans, so the boost semantics are source-backed and MCP-verifiable. Keep inputs explicit: current time scale, current duration, intensity, duration, and `can_overdrive`.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Source ApplyBoost State

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add a test requiring `source_building_apply_boost_state()` to preserve the Java guard and threshold:

```python
def test_port_game_exposes_building_apply_boost_state_like_source(self):
    port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
    source = port_game.read_text(encoding="utf-8")

    self.assertIn("func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:", source)
    self.assertIn("if not can_overdrive:", source)
    self.assertIn("if intensity >= current_time_scale - 0.001:", source)
    self.assertIn('result["time_scale_duration"] = max(current_duration, duration)', source)
    self.assertIn('result["time_scale"] = max(current_time_scale, intensity)', source)
```

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_building_apply_boost_state_like_source
```

Expected: FAIL because helper does not exist.

- [x] **Step 3: Implement helper**

Add helper near source math helpers:

```gdscript
func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:
	var result := {"time_scale": current_time_scale, "time_scale_duration": current_duration}
	if not can_overdrive:
		return result
	if intensity >= current_time_scale - 0.001:
		result["time_scale_duration"] = max(current_duration, duration)
	result["time_scale"] = max(current_time_scale, intensity)
	return result
```

- [x] **Step 4: Run tests**

Run targeted test, then full suite. Expected: full suite reports `91` tests passing.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Run project and call `source_building_apply_boost_state(1.0, 0.0, 1.5, 61.0, true)`, expecting `time_scale=1.5`, `time_scale_duration=61`; call `source_building_apply_boost_state(2.0, 10.0, 1.5, 61.0, true)`, expecting `time_scale=2`, `time_scale_duration=10`; call with `can_overdrive=false`, expecting unchanged values. Check debug `errors: []` and stop `finalErrors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec totals from `80/80/0` to `81/81/0`, checklist from `N49-N78` to `N49-N79`, add row `N79`, and changelog `M78 source BuildingComp applyBoost state`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m78-building-apply-boost.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose building apply boost state"
```
