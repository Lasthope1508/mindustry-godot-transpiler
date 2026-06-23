import json
from pathlib import Path
from typing import Any

from mindustry_port.java_ast import parse_source_tree


def gdscript_literal(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True)


def _script_path(java_file: dict, type_entry: dict) -> Path:
    package_path = java_file.get("package", "").replace(".", "/")
    return Path(package_path) / f"{type_entry['name']}.gd"


def _script_text(java_file: dict, type_entry: dict) -> str:
    lines = [
        "# Generated from Mindustry upstream.",
        f"# Source: {java_file['path']}",
        "# Do not edit by hand.",
        "extends RefCounted",
        "",
        f"const JAVA_PACKAGE := {gdscript_literal(java_file.get('package', ''))}",
        f"const JAVA_KIND := {gdscript_literal(type_entry.get('kind', ''))}",
        f"const JAVA_NAME := {gdscript_literal(type_entry.get('name', ''))}",
        f"const JAVA_EXTENDS := {gdscript_literal(type_entry.get('extends', ''))}",
        f"const JAVA_IMPLEMENTS := {gdscript_literal(type_entry.get('implements', []))}",
        f"const JAVA_FIELDS := {gdscript_literal(type_entry.get('fields', []))}",
        f"const JAVA_CONSTRUCTORS := {gdscript_literal(type_entry.get('constructors', []))}",
        f"const JAVA_METHODS := {gdscript_literal(type_entry.get('methods', []))}",
        f"const JAVA_ENUM_CONSTANTS := {gdscript_literal(type_entry.get('enum_constants', []))}",
        "",
    ]
    return "\n".join(lines)

def _registry_entry(java_file: dict, type_entry: dict, relative: Path) -> dict:
    return {
        "gdscript_path": f"res://src/generated/classes/{relative.as_posix()}",
        "java_kind": type_entry.get("kind", ""),
        "java_name": type_entry.get("name", ""),
        "java_package": java_file.get("package", ""),
        "java_path": java_file.get("path", ""),
    }

def _registry_text(entries: list[dict]) -> str:
    lines = [
        "# Generated from Mindustry upstream.",
        "# Source: emitted_classes.json",
        "# Do not edit by hand.",
        "extends RefCounted",
        "class_name MindustryGeneratedClassRegistry",
        "",
        f"const CLASS_COUNT := {len(entries)}",
        f"const CLASSES := {gdscript_literal(entries)}",
        "",
        "static func count() -> int:",
        "\treturn CLASS_COUNT",
        "",
        "static func all_classes() -> Array:",
        "\treturn CLASSES",
        "",
        "static func find_by_java_name(java_name: String) -> Dictionary:",
        "\tfor class_entry in CLASSES:",
        "\t\tif class_entry.get(\"java_name\", \"\") == java_name:",
        "\t\t\treturn class_entry",
        "\treturn {}",
        "",
    ]
    return "\n".join(lines)


def emit_gdscript_classes(source_root: Path, output_root: Path, limit: int | None = None) -> dict:
    output_root = Path(output_root)
    manifest = parse_source_tree(source_root, limit)
    files = []
    registry_entries = []
    for java_file in manifest["files"]:
        for type_entry in java_file.get("types", []):
            if not type_entry.get("name"):
                continue
            relative = _script_path(java_file, type_entry)
            output = output_root / relative
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(_script_text(java_file, type_entry), encoding="utf-8")
            files.append(relative.as_posix())
            registry_entries.append(_registry_entry(java_file, type_entry, relative))
    registry_path = output_root.parent / "GeneratedClassRegistry.gd"
    registry_path.parent.mkdir(parents=True, exist_ok=True)
    registry_path.write_text(_registry_text(registry_entries), encoding="utf-8")
    return {
        "source_root": Path(source_root).as_posix(),
        "output_root": output_root.as_posix(),
        "registry": registry_path.name,
        "emitted_file_count": len(files),
        "skipped_failure_count": manifest["failed_file_count"],
        "files": files,
        "failures": manifest["failures"],
    }
