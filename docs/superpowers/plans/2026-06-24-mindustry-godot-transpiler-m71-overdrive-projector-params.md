# OverdriveProjector Params Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate source-backed `OverdriveProjector` boost/light/booster params in Godot content registry.

**Architecture:** Extend the existing source extraction path used for `MendProjector`, but keep Overdrive-specific defaults separate. Source parity reads `OverdriveProjector.java` for defaults and `Blocks.java` for initializer overrides, then compares generated `content_registry.json`.

**Tech Stack:** Python content registry generator, Python `unittest`, generated Godot `MindustryContentRegistry.gd`, Godot MCP LSP/runtime summary proof.

---

### Task 1: Overdrive Source Params

**Files:**
- Modify: `tools/mindustry_godot_transpiler/tests/test_content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/tests/test_source_parity.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/source_parity.py`
- Regenerate: `godot-mindustry/src/generated/content_registry.json`
- Regenerate: `godot-mindustry/src/generated/MindustryContentRegistry.gd`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [x] **Step 1: Write failing content-registry test**

Add fixture coverage for `OverdriveProjector` in `test_content_registry.py`:

```python
    def test_block_registry_extracts_overdrive_projector_source_params(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            assets = root / "godot" / "assets" / "core" / "assets-raw" / "sprites" / "blocks" / "effect"
            source.mkdir(parents=True)
            assets.mkdir(parents=True)
            (assets / "overdrive-projector.png").write_bytes(b"png")
            (source / "Items.java").write_text("""
package mindustry.content;
public class Items{
    public static Item phaseFabric;
}
""", encoding="utf-8")
            (source / "Liquids.java").write_text("""
package mindustry.content;
public class Liquids{}
""", encoding="utf-8")
            (source / "Blocks.java").write_text("""
package mindustry.content;
public class Blocks{
    public static Block overdriveProjector;
    public static void load(){
        overdriveProjector = new OverdriveProjector("overdrive-projector"){{
            requirements(Category.effect, with(Items.lead, 100));
            size = 2;
            consumeItem(Items.phaseFabric).boost();
            ambientSoundVolume = 0.08f;
        }};
    }
}
""", encoding="utf-8")

            registry = build_content_registry(root / "upstream", root / "godot")

        props = registry["blocks"][0]["properties"]
        self.assertEqual(props.get("range"), 80.0)
        self.assertEqual(props.get("reload"), 60.0)
        self.assertEqual(props.get("speedBoost"), 1.5)
        self.assertEqual(props.get("speedBoostPhase"), 0.75)
        self.assertEqual(props.get("phaseRangeBoost"), 20.0)
        self.assertEqual(props.get("boosterUseTime"), 400.0)
        self.assertEqual(props.get("boosterItem"), "phase-fabric")
        self.assertEqual(props.get("baseColor"), "feb380")
        self.assertEqual(props.get("phaseColor"), "ffd59e")
        self.assertEqual(props.get("emitLight"), True)
        self.assertEqual(props.get("lightRadius"), 50.0)
        self.assertEqual(props.get("hasBoost"), True)
```

- [x] **Step 2: Write failing source-parity test**

Add a test in `test_source_parity.py`:

```python
    def test_overdrive_projector_params_match_source(self):
        report = verify_overdrive_projector_params_parity(UPSTREAM_ROOT, GODOT_ROOT)
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "overdrive-projector")
        self.assertEqual(report["checked"], {
            "range": 80.0,
            "reload": 60.0,
            "speedBoost": 1.5,
            "speedBoostPhase": 0.75,
            "phaseRangeBoost": 20.0,
            "boosterItem": "phase-fabric",
            "boosterUseTime": 400.0,
            "baseColor": "feb380",
            "phaseColor": "ffd59e",
            "emitLight": True,
            "lightRadius": 50.0,
            "hasBoost": True,
        })
```

Import `verify_overdrive_projector_params_parity` from `source_parity.py`.

- [x] **Step 3: Run RED tests**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_content_registry.ContentRegistryTests.test_block_registry_extracts_overdrive_projector_source_params
python -m unittest tools.mindustry_godot_transpiler.tests.test_source_parity.SourceParityTests.test_overdrive_projector_params_match_source
```

Expected: content-registry FAIL because defaults missing; source-parity ERROR because function missing or FAIL because generated params missing.

- [x] **Step 4: Implement generator/parity extraction**

In `content_registry.py`, include numeric keys `speedBoost`, `speedBoostPhase`, and boolean `hasBoost`, plus color key `phaseColor`. Add `_apply_overdrive_projector_defaults(properties, initializer)`:

```python
def _apply_overdrive_projector_defaults(properties: dict[str, Any], initializer: str) -> None:
    for key, default in {"reload": 60.0, "range": 80.0, "speedBoost": 1.5, "speedBoostPhase": 0.75, "useTime": 400.0, "phaseRangeBoost": 20.0}.items():
        if key not in properties and not _has_assignment(initializer, key):
            properties[key] = default
    has_boost = _boolean_assignment(initializer, "hasBoost")
    properties["hasBoost"] = True if has_boost is None and not _has_assignment(initializer, "hasBoost") else bool(has_boost)
    if "baseColor" not in properties and not _has_assignment(initializer, "baseColor"):
        properties["baseColor"] = "feb380"
    if "phaseColor" not in properties and not _has_assignment(initializer, "phaseColor"):
        properties["phaseColor"] = "ffd59e"
    if "emitLight" not in properties and not _has_assignment(initializer, "emitLight"):
        properties["emitLight"] = True
    if "lightRadius" not in properties and not _has_assignment(initializer, "lightRadius"):
        properties["lightRadius"] = 50.0
```

Set `boosterUseTime` for `OverdriveProjector` from `useTime` like `MendProjector`.

In `source_parity.py`, add `OVERDRIVE_PROJECTOR_SOURCE`, `verify_overdrive_projector_params_parity()`, and `_extract_overdrive_projector_params()` using `OverdriveProjector.java` defaults plus `Blocks.java` overrides for `overdriveProjector`.

- [x] **Step 5: Regenerate content**

Run the existing content generation command:

```powershell
python tools/mindustry_godot_transpiler/transpile.py content --upstream mindustry-upstream --godot godot-mindustry
```

If the command differs, inspect `transpile.py` and run the project-local content generation command that updates `content_registry.json` and `MindustryContentRegistry.gd`.

- [x] **Step 6: Run tests and MCP verification**

Run:

```powershell
python -m unittest tools.mindustry_godot_transpiler.tests.test_content_registry.ContentRegistryTests.test_block_registry_extracts_overdrive_projector_source_params
python -m unittest tools.mindustry_godot_transpiler.tests.test_source_parity.SourceParityTests.test_overdrive_projector_params_match_source
python -m unittest discover -s tools/mindustry_godot_transpiler/tests
```

Run MCP LSP diagnostics on `src/generated/MindustryContentRegistry.gd`. Then run Godot project with MCP and call runtime summary after selecting `overdrive-projector`; expected generated registry has `range=80`, `speedBoost=1.5`, `speedBoostPhase=0.75`, `phaseRangeBoost=20`, `boosterItem="phase-fabric"`, colors `feb380/ffd59e`, and debug output `errors: []`.

- [ ] **Step 7: Update checklist and commit**

Update spec summary totals from `73/73/0` to `74/74/0`, checklist from `N49-N71` to `N49-N72`, add row `N72`, and changelog `M71 source OverdriveProjector params`. Run `git diff --check`, stage only related files, then commit:

```powershell
git add docs/superpowers/plans/2026-06-24-mindustry-godot-transpiler-m71-overdrive-projector-params.md docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md godot-mindustry/src/generated/content_registry.json godot-mindustry/src/generated/MindustryContentRegistry.gd tools/mindustry_godot_transpiler/mindustry_port/content_registry.py tools/mindustry_godot_transpiler/mindustry_port/source_parity.py tools/mindustry_godot_transpiler/tests/test_content_registry.py tools/mindustry_godot_transpiler/tests/test_source_parity.py

git commit -m "feat: extract overdrive projector params"
```
