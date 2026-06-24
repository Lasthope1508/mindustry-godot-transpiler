# OverdriveProjector Real Boost Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source `OverdriveBuild.realBoost()` formula into Godot runtime helpers.

**Architecture:** Use generated `OverdriveProjector` params from M71 and expose deterministic helper values before applying boost to other buildings. Keep `phase_heat` and `efficiency` explicit so later runtime state can feed the same source formula.

**Tech Stack:** GDScript runtime in `godot-mindustry/src/game/PortGame.gd`, Python `unittest`, Godot MCP LSP/runtime proof.

---

### Task 1: Real Boost Formula

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write the failing test**

Add this test to `PlayableManifestTests` near the other selected build runtime tests:

```python
    def test_port_game_exposes_overdrive_projector_real_boost_like_source(self):
        port_game = ROOT / "godot-mindustry" / "src" / "game" / "PortGame.gd"
        source = port_game.read_text(encoding="utf-8")

        self.assertIn("func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:", source)
        self.assertIn('var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))', source)
        self.assertIn('var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))', source)
        self.assertIn("return (speed_boost + phase_heat * speed_boost_phase) * efficiency", source)
        self.assertIn("func selected_build_overdrive_real_boost() -> float:", source)
        self.assertIn('if selected.implementation != "OverdriveProjector":', source)
        self.assertIn("return source_overdrive_projector_real_boost(selected)", source)
        self.assertIn("func selected_build_overdrive_phase_real_boost() -> float:", source)
        self.assertIn("return source_overdrive_projector_real_boost(selected, 1.0)", source)
        self.assertIn('"selected_build_overdrive_real_boost": selected_build_overdrive_real_boost()', source)
        self.assertIn('"selected_build_overdrive_phase_real_boost": selected_build_overdrive_phase_real_boost()', source)
```

- [x] **Step 2: Run RED test**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_overdrive_projector_real_boost_like_source
```

Expected: FAIL because `source_overdrive_projector_real_boost` does not exist.

- [x] **Step 3: Implement GDScript helpers**

Add helpers near selected build helpers in `PortGame.gd`:

```gdscript
func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	if overdrive_projector == null:
		return 0.0
	var speed_boost := float(overdrive_projector.properties.get("speedBoost", 0.0))
	var speed_boost_phase := float(overdrive_projector.properties.get("speedBoostPhase", 0.0))
	return (speed_boost + phase_heat * speed_boost_phase) * efficiency

func selected_build_overdrive_real_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_real_boost(selected)

func selected_build_overdrive_phase_real_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = build_palette[selected_build_index]
	if selected.implementation != "OverdriveProjector":
		return 0.0
	return source_overdrive_projector_real_boost(selected, 1.0)
```

Add both values to `get_runtime_summary()`.

- [x] **Step 4: Run tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_exposes_overdrive_projector_real_boost_like_source
python -m unittest discover -s tools/mindustry_godot_transpiler/tests
```

Expected: targeted PASS; full suite increments from `84` to `85` tests and reports `OK`.

- [x] **Step 5: Verify with Godot MCP**

Run MCP LSP diagnostics on `src/game/PortGame.gd`. Then run project, select `overdrive-projector`, call `get_runtime_summary()`, and verify `selected_build_overdrive_real_boost=1.5`, `selected_build_overdrive_phase_real_boost=2.25`, and debug `errors: []`.

- [x] **Step 6: Update checklist and commit**

Update spec summary totals from `74/74/0` to `75/75/0`, checklist from `N49-N72` to `N49-N73`, add row `N73`, and changelog `M72 source OverdriveProjector realBoost`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m72-overdrive-real-boost.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/tests/test_playable.py
git commit -m "feat: expose overdrive real boost"
```
