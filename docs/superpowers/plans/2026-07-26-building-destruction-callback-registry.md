# Building Destruction Callback Registry Implementation Plan

## Status

- Verified complete in workspace: targeted playable tests pass, runtime proof passes, and MCP runtime output is clean.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move `SourceBuildingDestructionState.after_destroyed_state` callback ownership out of `PortGame.gd` direct `Callable(self, ...)` usage and prove module registry parity at runtime.

**Architecture:** `SourceBuildingDestructionState` owns its callback registry through `default_callbacks_state(game)`. `PortGame.gd` remains a facade, but resolves callbacks through module-owned keys. A runtime proof scene checks wrapper/module parity and canonical SSOT headquarter validity.

**Tech Stack:** Godot 4.6 GDScript, Python `pytest`, existing `SourceSsotCatalog` headquarter registry.

---

### Task 1: RED Test

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`

- [x] **Step 1: Add failing test for destruction callback registry**

Add assertions requiring:

```python
self.assertIn("SourceBuildingDestructionState.default_callbacks_state", proof_source)
self.assertIn('"random_seed_float_max": Callable(game, "source_arc_random_seed_float_max")', proof_source)
self.assertIn("SourceBuildingDestructionState.after_destroyed_state(", proof_source)
self.assertIn('"one_headquarter_per_ssot"', proof_source)
self.assertIn('"registry_valid"', proof_source)
```

- [x] **Step 2: Run RED**

Run:

```powershell
python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -k "building_destruction_state_module_has_default_callbacks_proof or delegates_building_destruction_state_to_module"
```

Expected: FAIL because `default_callbacks_state` and proof file do not exist for destruction state yet.

### Task 2: GREEN Implementation

**Files:**
- Modify: `godot-mindustry/src/game/SourceBuildingDestructionState.gd`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Create: `godot-mindustry/tools/runtime_proofs/BuildingDestructionStateModuleProof.gd`
- Create: `godot-mindustry/tools/runtime_proofs/BuildingDestructionStateModuleProof.tscn`

- [x] **Step 1: Add module callback registry**

```gdscript
static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"random_seed_float_max": Callable(game, "source_arc_random_seed_float_max"),
	}
```

- [x] **Step 2: Switch PortGame facade**

```gdscript
func source_building_after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	var callbacks := SourceBuildingDestructionState.default_callbacks_state(self)
	return SourceBuildingDestructionState.after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, callbacks.get("random_seed_float_max", Callable()))
```

- [x] **Step 3: Add runtime proof**

Proof scene prints `BUILDING_DESTRUCTION_STATE_MODULE_PROOF` with `default_callbacks_match`, `after_destroyed_matches`, `one_headquarter_per_ssot`, and `registry_valid`.

### Task 3: Verification And Commit

**Files:**
- Stage exact changed files only.

- [x] **Step 1: Run GREEN tests**

```powershell
python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py -k "building_destruction_state_module_has_default_callbacks_proof or delegates_building_destruction_state_to_module"
```

- [x] **Step 2: Run runtime proof**

```powershell
& 'C:\Users\Admin\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.2-stable_win64_console.exe' --headless --path 'C:\Users\Admin\Documents\Game\mindustry-godot-transpiler-copy-20260714-073528\godot-mindustry' --scene 'res://tools/runtime_proofs/BuildingDestructionStateModuleProof.tscn'
```

- [x] **Step 3: Run full playable suite and diff check**

```powershell
python -m pytest tools/mindustry_godot_transpiler/tests/test_playable.py
git diff --cached --check
```

- [ ] **Step 4: Commit**

```powershell
git add -- godot-mindustry/src/game/PortGame.gd godot-mindustry/src/game/SourceBuildingDestructionState.gd godot-mindustry/tools/runtime_proofs/BuildingDestructionStateModuleProof.gd godot-mindustry/tools/runtime_proofs/BuildingDestructionStateModuleProof.tscn tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "Add building destruction callback registry proof"
```
