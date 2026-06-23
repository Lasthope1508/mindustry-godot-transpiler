# Mindustry Godot Transpiler M2 Parser Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a real Java AST parser and Java-to-GDScript mapping table so source conversion can start without regex-based class parsing.

**Architecture:** Use `javalang` as the Java parser and normalize parsed Java files into stable JSON-friendly dictionaries. Keep scanner as file inventory, parser as semantic extractor, mapping as explicit data checked by tests.

**Tech Stack:** Python 3.13, `javalang==0.13.0`, `unittest`, Godot MCP project verification.

---

### Task 1: Parser Dependency

**Files:**
- Create: `tools/mindustry_godot_transpiler/requirements.txt`

- [ ] Add `javalang==0.13.0`.
- [ ] Run `python -m pip install -r tools/mindustry_godot_transpiler/requirements.txt`.
- [ ] Verify `python -c "import javalang; print(javalang.__version__)"` exits `0`.

### Task 2: Java AST Parser

**Files:**
- Create: `tools/mindustry_godot_transpiler/tests/test_java_ast.py`
- Create: `tools/mindustry_godot_transpiler/mindustry_port/java_ast.py`

- [ ] Write failing tests for class fields, methods, constructor, enum constants, extends, implements.
- [ ] Run parser tests and confirm RED.
- [ ] Implement parser using `javalang.parse.parse`.
- [ ] Run parser tests and confirm GREEN.

### Task 3: Mapping Table

**Files:**
- Create: `tools/mindustry_godot_transpiler/mapping/java_to_gdscript.json`
- Create: `tools/mindustry_godot_transpiler/tests/test_mapping.py`

- [ ] Write failing test that required mapping keys exist.
- [ ] Add mapping keys for class, enum, method, field, constructor, static initializer, overload, package path, imports.
- [ ] Run mapping tests and confirm GREEN.

### Task 4: Parser CLI Report

**Files:**
- Modify: `tools/mindustry_godot_transpiler/transpile.py`
- Modify: `tools/mindustry_godot_transpiler/mindustry_port/reports.py`

- [ ] Add `parse` command that parses selected Java files and writes `ast_manifest.json`.
- [ ] Add report totals for parsed files and parse failures.
- [ ] Run `python tools/mindustry_godot_transpiler/transpile.py parse --upstream mindustry-upstream --godot godot-mindustry --limit 20`.
- [ ] Run all tests.
- [ ] Update spec ledger only for verified N4/N5 if tests pass.
- [ ] Commit M2.
