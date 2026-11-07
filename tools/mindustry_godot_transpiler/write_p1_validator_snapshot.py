"""Regenerate the canonical P1 validator snapshot from the live catalogs."""

from __future__ import annotations

import json
from pathlib import Path

from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
OUTPUT = ROOT / "docs" / "superpowers" / "reports" / "2026-09-24-p1-cross-catalog-validator.json"


def main() -> None:
    report = source_symbols.validate_source_catalog(GODOT)
    OUTPUT.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "errors": len(report["errors"]),
        "unknown_return_keys": len(report["return_schema_diagnostics"]["unknown_return_keys"]),
        "json_modules": report["json_module_count"],
        "json_errors": len(report["json_errors"]),
        "output": str(OUTPUT),
    }, indent=2))


if __name__ == "__main__":
    main()
