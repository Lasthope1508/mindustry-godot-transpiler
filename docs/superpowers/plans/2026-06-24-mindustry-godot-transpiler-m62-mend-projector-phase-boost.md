# Mindustry Godot M62 Mend Projector Phase Boost Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port source-backed `MendProjector` optional phase-fabric booster item into generated registry and Godot runtime heal/range math.

**Architecture:** Keep scope limited to the `MendProjector` source path. Extract `consumeItem(Items.phaseFabric).boost()` from `Blocks.java` into generated block properties, then let `PortGame.gd` hold per-cell phaseHeat state and use that value in existing repair amount and range helpers.

**Tech Stack:** Python `unittest`, source parser in `tools/mindustry_godot_transpiler`, Godot 4 GDScript, Godot MCP LSP/runtime.

---

### Source Facts

- `core/src/mindustry/content/Blocks.java`: `mendProjector` calls `consumeItem(Items.phaseFabric).boost();`.
- `core/src/mindustry/world/blocks/defense/MendProjector.java`: default `useTime = 400f`.
- `MendBuild.updateTile()` computes `phaseHeat = Mathf.lerpDelta(phaseHeat, optionalEfficiency, 0.1f)`.
- It consumes optional item when `optionalEfficiency > 0 && timer(timerUse, useTime / timeScale) && canHeal`.
- It computes range as `range + phaseHeat * phaseRangeBoost`.
- It heals with `other.maxHealth() * (healPercent + phaseHeat * phaseBoost) / 100f * efficiency`.

### Task 1: Registry Booster Metadata

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`

- [x] **Step 1: Write failing tests**

Add assertions that a `MendProjector` initializer with `consumeItem(Items.phaseFabric).boost();` emits:

```python
self.assertEqual(registry["blocks"][0]["properties"].get("boosterItem"), "phase-fabric")
self.assertEqual(registry["blocks"][0]["properties"].get("boosterUseTime"), 400.0)
```

Add source parity expected values:

```python
self.assertEqual(report["checked"]["boosterItem"], "phase-fabric")
self.assertEqual(report["checked"]["boosterUseTime"], 400.0)
```

- [x] **Step 2: Verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_content_registry.ContentRegistryTests.test_build_registry_extracts_mend_projector_scaled_health_and_repair_defaults tools.mindustry_godot_transpiler.tests.test_source_parity.SourceParityTests.test_generated_mend_projector_repair_params_match_upstream_source -v
```

Expected: FAIL because `boosterItem` / `boosterUseTime` are absent.

- [x] **Step 3: Implement extractor**

Add `_boost_item(initializer)` to parse `consumeItem(Items.X).boost()` and store kebab item id. For `MendProjector`, store default `boosterUseTime=400.0` unless explicit `useTime` assignment exists.

- [x] **Step 4: Verify GREEN**

Run targeted tests above. Expected: OK.

### Task 2: Godot Runtime Phase Boost

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_playable.py`
- Modify: `godot-mindustry/src/game/PortGame.gd`

- [x] **Step 1: Write failing tests**

Add assertions for:

```python
self.assertIn("var mend_projector_phase_heat: Dictionary = {}", source)
self.assertIn("func boost_mend_projector_at_cell(x: int, y: int) -> bool:", source)
self.assertIn('core_items[item_id] = int(core_items.get(item_id, 0)) - 1', source)
self.assertIn("source_mend_projector_repair_amount(block, target_block, phase_heat)", source)
self.assertIn("find_damaged_block_in_mend_range(mend_cell, block, phase_heat)", source)
self.assertIn('"selected_build_booster_item": selected_build_booster_item()', source)
```

- [x] **Step 2: Verify RED**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_playable.PlayableManifestTests.test_port_game_simulates_source_mend_projector_phase_boost -v
```

Expected: FAIL because phase-boost runtime hooks are absent.

- [x] **Step 3: Implement runtime**

Add per-cell `mend_projector_phase_heat`, selected build booster accessors, `boost_mend_projector_at_cell()`, phase-aware range lookup, and phase-aware repair call. Keep `phaseHeat=1.0` only after explicit booster helper consumes one source booster item from core inventory.

- [x] **Step 4: Verify GREEN**

Run targeted test. Expected: OK.

### Task 3: Verification, Checklist, Commit

**Files:**
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- Modify: this plan file

- [x] Run full Python suite:

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

Place `mend-projector`, set `phase-fabric=1`, damage placed block from `320` to `200`, call `boost_mend_projector_at_cell(2, 2)`, call `step_mend_projectors(4.2)`, and verify heal amount `83.2` with health `283.2` and debug `errors: []`.

- [x] Update spec totals and changelog from `64/64/0` to `65/65/0`, adding N63 for M62.

- [x] Stage explicit files only and commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m62-mend-projector-phase-boost.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/game/PortGame.gd tools/mindustry_godot_transpiler/mindustry_port/content_registry.py tools/mindustry_godot_transpiler/mindustry_port/source_parity.py tools/mindustry_godot_transpiler/tests/test_content_registry.py tools/mindustry_godot_transpiler/tests/test_playable.py tools/mindustry_godot_transpiler/tests/test_source_parity.py
git commit -m "feat: port mend projector phase boost"
```
