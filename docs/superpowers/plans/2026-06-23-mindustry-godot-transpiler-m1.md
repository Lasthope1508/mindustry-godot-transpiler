# Mindustry Godot Transpiler M1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first verified porting pipeline: Godot project, transpiler CLI, source inventory, full asset copy, generated manifest/report, and minimal Godot node/runtime wiring.

**Architecture:** Python CLI owns scanning, asset copying, and reporting. Godot project stays separate under `godot-mindustry`, with handwritten runtime stubs in `src/runtime` and generated metadata under `src/generated`. Every done state needs a test or Godot verification.

**Tech Stack:** Python 3.13 stdlib `unittest`, Godot 4.6.2, GDScript, Mindustry upstream commit `2bdedfed25932ebf11330d3584092c50e2e26d96`.

---

## File Structure

- Create: `tools/mindustry_godot_transpiler/transpile.py` - CLI entrypoint with `scan`, `assets`, `report`, `all` commands.
- Create: `tools/mindustry_godot_transpiler/mindustry_port/scanner.py` - source inventory and Java package/type extraction.
- Create: `tools/mindustry_godot_transpiler/mindustry_port/assets.py` - full asset bridge preserving relative paths and hashes.
- Create: `tools/mindustry_godot_transpiler/mindustry_port/reports.py` - unsupported feature and status report writer.
- Create: `tools/mindustry_godot_transpiler/mindustry_port/paths.py` - shared path resolution.
- Create: `tools/mindustry_godot_transpiler/mindustry_port/__init__.py` - package marker.
- Create: `tools/mindustry_godot_transpiler/tests/test_scanner.py` - scanner tests.
- Create: `tools/mindustry_godot_transpiler/tests/test_assets.py` - asset bridge tests.
- Create: `tools/mindustry_godot_transpiler/tests/test_cli.py` - CLI smoke tests.
- Create: `godot-mindustry/project.godot` - Godot project config.
- Create: `godot-mindustry/scenes/Main.tscn` - root scene with world, camera, UI, asset skin layer nodes.
- Create: `godot-mindustry/src/runtime/*.gd` - runtime stubs for generated code.
- Create: `godot-mindustry/src/generated/.gitkeep` - generated output folder marker.
- Create: `godot-mindustry/assets/.gitkeep` - copied asset root marker.
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` - update ledger after verification.

## Task 1: CLI Contract Test

**Files:**
- Create: `tools/mindustry_godot_transpiler/tests/test_cli.py`
- Create: `tools/mindustry_godot_transpiler/transpile.py`
- Create: `tools/mindustry_godot_transpiler/mindustry_port/__init__.py`

- [ ] **Step 1: Write failing CLI tests**

```python
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
CLI = ROOT / "tools" / "mindustry_godot_transpiler" / "transpile.py"


def run_cli(*args):
    return subprocess.run([sys.executable, str(CLI), *args], cwd=ROOT, text=True, capture_output=True)


def test_cli_help_lists_commands():
    result = run_cli("--help")
    assert result.returncode == 0
    assert "scan" in result.stdout
    assert "assets" in result.stdout
    assert "report" in result.stdout
    assert "all" in result.stdout
```

- [ ] **Step 2: Run test to verify RED**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p "test_cli.py" -v`
Expected: FAIL because `transpile.py` does not exist.

- [ ] **Step 3: Implement minimal CLI**

Create `transpile.py` with argparse commands returning `0` for `--help`.

- [ ] **Step 4: Run test to verify GREEN**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p "test_cli.py" -v`
Expected: PASS.

## Task 2: Source Scanner

**Files:**
- Create: `tools/mindustry_godot_transpiler/tests/test_scanner.py`
- Create: `tools/mindustry_godot_transpiler/mindustry_port/scanner.py`
- Create: `tools/mindustry_godot_transpiler/mindustry_port/paths.py`

- [ ] **Step 1: Write failing scanner tests**

```python
import json
import tempfile
import unittest
from pathlib import Path

from mindustry_port.scanner import scan_source_tree


class ScannerTests(unittest.TestCase):
    def test_scanner_extracts_package_types_and_hash(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            src = root / "core" / "src" / "mindustry" / "content"
            src.mkdir(parents=True)
            java_file = src / "Items.java"
            java_file.write_text("package mindustry.content;\npublic class Items {\n}\n", encoding="utf-8")

            manifest = scan_source_tree(root / "core" / "src")

        self.assertEqual(manifest["java_file_count"], 1)
        self.assertEqual(manifest["files"][0]["package"], "mindustry.content")
        self.assertEqual(manifest["files"][0]["types"], ["Items"])
        self.assertEqual(len(manifest["files"][0]["sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify RED**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p "test_scanner.py" -v`
Expected: FAIL because `mindustry_port.scanner` does not exist.

- [ ] **Step 3: Implement scanner**

Implement `scan_source_tree(source_root: Path) -> dict` using Python stdlib, extracting package/type declarations and SHA-256.

- [ ] **Step 4: Run test to verify GREEN**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p "test_scanner.py" -v`
Expected: PASS.

## Task 3: Full Asset Bridge

**Files:**
- Create: `tools/mindustry_godot_transpiler/tests/test_assets.py`
- Create: `tools/mindustry_godot_transpiler/mindustry_port/assets.py`

- [ ] **Step 1: Write failing asset tests**

```python
import tempfile
import unittest
from pathlib import Path

from mindustry_port.assets import copy_assets


class AssetBridgeTests(unittest.TestCase):
    def test_copy_assets_preserves_relative_paths_and_hashes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            upstream = root / "mindustry-upstream"
            source = upstream / "core" / "assets" / "sprites"
            raw = upstream / "core" / "assets-raw" / "sprites" / "items"
            source.mkdir(parents=True)
            raw.mkdir(parents=True)
            (source / "logo.png").write_bytes(b"png-bytes")
            (raw / "item-copper.png").write_bytes(b"copper-bytes")

            out = root / "godot" / "assets"
            manifest = copy_assets(upstream, out)

        self.assertEqual(manifest["asset_count"], 2)
        self.assertTrue((out / "core" / "assets" / "sprites" / "logo.png").exists())
        self.assertTrue((out / "core" / "assets-raw" / "sprites" / "items" / "item-copper.png").exists())
        self.assertEqual(len(manifest["assets"][0]["sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify RED**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p "test_assets.py" -v`
Expected: FAIL because `mindustry_port.assets` does not exist.

- [ ] **Step 3: Implement asset bridge**

Copy every file under `core/assets` and `core/assets-raw` into `godot-mindustry/assets/core/...`; write manifest entries with source, target, byte size, SHA-256.

- [ ] **Step 4: Run test to verify GREEN**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -p "test_assets.py" -v`
Expected: PASS.

## Task 4: Godot Project and Node Wiring

**Files:**
- Create: `godot-mindustry/project.godot`
- Create: `godot-mindustry/scenes/Main.tscn`
- Create: `godot-mindustry/src/runtime/PortBootstrap.gd`
- Create: `godot-mindustry/src/runtime/SkinRegistry.gd`

- [ ] **Step 1: Write project files**

Create a Godot project with main scene `res://scenes/Main.tscn`. Main scene root must include `World`, `Camera2D`, `Runtime`, `GeneratedContent`, `SkinLayer`, and `UI` nodes.

- [ ] **Step 2: Verify project loads**

Run: Godot MCP `project_info` on `godot-mindustry`.
Expected: project info returns name `Mindustry Godot Port` and main scene `res://scenes/Main.tscn`.

## Task 5: Runtime Stubs

**Files:**
- Create: `godot-mindustry/src/runtime/Seq.gd`
- Create: `godot-mindustry/src/runtime/ObjectMap.gd`
- Create: `godot-mindustry/src/runtime/Mathf.gd`
- Create: `godot-mindustry/src/runtime/Time.gd`
- Create: `godot-mindustry/src/runtime/Events.gd`
- Create: `godot-mindustry/src/runtime/Core.gd`
- Create: `godot-mindustry/src/runtime/Vars.gd`
- Create: `godot-mindustry/src/runtime/ColorCompat.gd`
- Create: `godot-mindustry/src/runtime/Vec2.gd`

- [ ] **Step 1: Add runtime stubs**

Each file must define `class_name` and minimal methods needed for generated code to instantiate later.

- [ ] **Step 2: Verify Godot parses runtime**

Run: Godot MCP `project_info`, then `lsp_diagnostics` on representative runtime scripts.
Expected: no diagnostics that prevent parse.

## Task 6: Report and Full M1 Run

**Files:**
- Create: `tools/mindustry_godot_transpiler/mindustry_port/reports.py`
- Modify: `tools/mindustry_godot_transpiler/transpile.py`
- Modify: `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`

- [ ] **Step 1: Wire `scan`, `assets`, `report`, `all`**

`all` must run scanner, asset bridge, and report writer.

- [ ] **Step 2: Run full pipeline**

Run: `python tools/mindustry_godot_transpiler/transpile.py all --upstream mindustry-upstream --godot godot-mindustry`
Expected: exit `0`, manifests written under `godot-mindustry/src/generated`, all assets copied.

- [ ] **Step 3: Verify totals**

Run: `python tools/mindustry_godot_transpiler/transpile.py report --upstream mindustry-upstream --godot godot-mindustry`
Expected: report shows Java files, asset count, copied byte count, and unsupported feature section.

- [ ] **Step 4: Update spec ledger**

Move M1-completed items from Not Done to Done only with command evidence.

- [ ] **Step 5: Run all tests**

Run: `python -m unittest discover -s tools/mindustry_godot_transpiler/tests -v`
Expected: all tests pass.

- [ ] **Step 6: Commit M1**

Run: `git add docs tools godot-mindustry && git commit -m "feat: add mindustry godot transpiler m1"`
Expected: commit succeeds.
