# M12 Unsupported Report Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make unsupported Java constructs visible with exact source locations so the port can proceed without silent omissions.

**Architecture:** `reports.py` scans upstream Java source and records constrained unsupported patterns as structured report entries. `transpile.py report` and `all` pass the upstream source root into report generation. Generated `port_report.json` carries machine-readable `path`, `line`, `feature`, and `snippet`; generated `port_report.md` gives a human-readable `path:line` checklist.

**Tech Stack:** Python 3.13, unittest, Godot MCP for project/runtime sanity after generated report changes.

---

## Status Summary

| Bucket | Count |
| --- | ---: |
| Total M12 tasks | 5 |
| Done | 5 |
| Not done | 0 |
| Blocked | 0 |

## Done

| ID | Item | Evidence |
| --- | --- | --- |
| M12-1 | Add failing report tests | `test_reports.py` requires exact path/line/feature/snippet for lambda and anonymous double-brace initializer fixtures |
| M12-2 | Implement unsupported scan | `scan_unsupported_features(source_root)` scans `.java` files and emits ordered structured entries |
| M12-3 | Wire CLI report source root | `transpile.py report` and `all` pass `upstream/core/src` into `write_report` |
| M12-4 | Generate real report | `python tools/mindustry_godot_transpiler/transpile.py report --upstream mindustry-upstream --godot godot-mindustry` writes `6986` unsupported source locations |
| M12-5 | Verify | Python suite reports `Ran 15 tests ... OK`; Godot MCP runtime output remains `errors: []` |

## Not Done

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| None | No open M12 task | N/A |

## Next Candidate Work

| ID | Item | Required verification before marking done |
| --- | --- | --- |
| M13-1 | Add regression fixtures for generated GDScript | Expected `.gd` fixture files compare exactly against generator output |
| M13-2 | Rank unsupported features | Report groups unsupported constructs by feature and file count, then marks next conversion priority |
| M13-3 | Start class emission fixture | One Java class fixture emits one checked GDScript class and passes Godot parse diagnostics |
