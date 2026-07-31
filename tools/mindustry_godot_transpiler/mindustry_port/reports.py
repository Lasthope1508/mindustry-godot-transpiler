import json
import re
from pathlib import Path


def write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def scan_unsupported_features(source_root: Path) -> list[dict]:
    source_root = Path(source_root)
    if not source_root.exists():
        return []
    patterns = [
        ("lambda", re.compile(r"->")),
        ("anonymous_double_brace_initializer", re.compile(r"new\s+[^;]+\)\s*\{\{")),
    ]
    features = []
    for java_file in sorted(source_root.rglob("*.java")):
        relative = java_file.relative_to(source_root).as_posix()
        for line_number, line in enumerate(java_file.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
            stripped = line.strip()
            for feature, pattern in patterns:
                if pattern.search(stripped):
                    features.append({"path": relative, "line": line_number, "feature": feature, "snippet": stripped})
    return features


def scan_port_game_footprint(godot_root: Path) -> dict:
    port_game = Path(godot_root) / "src" / "game" / "PortGame.gd"
    if not port_game.exists():
        return {
            "path": "src/game/PortGame.gd",
            "exists": False,
            "byte_count": 0,
            "line_count": 0,
            "preload_count": 0,
            "function_count": 0,
            "source_function_count": 0,
            "generated_bridge_function_count": 0,
            "max_function_lines": 0,
        }
    source = port_game.read_text(encoding="utf-8")
    lines = source.splitlines()
    function_starts = [
        index
        for index, line in enumerate(lines, start=1)
        if line.startswith("func ")
    ]
    max_function_lines = 0
    for offset, start in enumerate(function_starts):
        end = function_starts[offset + 1] - 1 if offset + 1 < len(function_starts) else len(lines)
        max_function_lines = max(max_function_lines, end - start + 1)
    return {
        "path": "src/game/PortGame.gd",
        "exists": True,
        "byte_count": len(source.encode("utf-8")),
        "line_count": len(lines),
        "preload_count": sum(1 for line in lines if "preload(" in line),
        "function_count": len(function_starts),
        "source_function_count": sum(1 for line in lines if line.startswith("func source_")),
        "generated_bridge_function_count": sum(1 for line in lines if line.startswith("func generated_")),
        "max_function_lines": max_function_lines,
    }

def scan_port_game_bridge_surface(godot_root: Path) -> dict:
    port_game = Path(godot_root) / "src" / "game" / "PortGame.gd"
    if not port_game.exists():
        return {
            "path": "src/game/PortGame.gd",
            "exists": False,
            "delegating_function_count": 0,
            "source_delegating_function_count": 0,
            "generated_bridge_delegating_function_count": 0,
            "delegate_module_count": 0,
            "top_delegate_modules": [],
            "largest_delegate_module": {},
        }
    godot_root = Path(godot_root)
    lines = port_game.read_text(encoding="utf-8").splitlines()
    preload_paths: dict[str, str] = {}
    preload_pattern = re.compile(r"^const\s+([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*preload\(\"([^\"]+)\"\)")
    for line in lines:
        match = preload_pattern.match(line.strip())
        if match:
            preload_paths[match.group(1)] = match.group(2)
    function_starts = [
        (index, line.strip())
        for index, line in enumerate(lines, start=1)
        if line.startswith("func ")
    ]
    delegate_modules: dict[str, dict] = {}
    delegating_function_count = 0
    source_delegating_function_count = 0
    generated_bridge_delegating_function_count = 0
    delegate_pattern = re.compile(r"^(?:return\s+)?([A-Za-z_][A-Za-z0-9_]*)\.[A-Za-z_][A-Za-z0-9_]*\(")
    for offset, (start, signature) in enumerate(function_starts):
        end = function_starts[offset + 1][0] - 1 if offset + 1 < len(function_starts) else len(lines)
        body_lines = [
            line.strip()
            for line in lines[start:end]
            if line.strip() and not line.strip().startswith("#")
        ]
        delegate_module = ""
        for body_line in body_lines:
            match = delegate_pattern.match(body_line)
            if match:
                delegate_module = match.group(1)
                break
        if not delegate_module:
            continue
        delegating_function_count += 1
        function_name = signature.split("(", 1)[0].replace("func ", "")
        if function_name.startswith("source_"):
            source_delegating_function_count += 1
        if function_name.startswith("generated_"):
            generated_bridge_delegating_function_count += 1
        entry = delegate_modules.setdefault(delegate_module, {"function_count": 0, "sample_functions": []})
        entry["function_count"] += 1
        if len(entry["sample_functions"]) < 5:
            entry["sample_functions"].append(function_name)
    largest_delegate_module = {}
    if delegate_modules:
        module_name, module_entry = sorted(
            delegate_modules.items(),
            key=lambda item: (-int(item[1]["function_count"]), item[0]),
        )[0]
        largest_delegate_module = {
            "module": module_name,
            "function_count": int(module_entry["function_count"]),
        }
    top_delegate_modules = []
    for module_name, module_entry in sorted(
        delegate_modules.items(),
        key=lambda item: (-int(item[1]["function_count"]), item[0]),
    )[:20]:
        module_path = preload_paths.get(module_name, "")
        class_name = _gdscript_class_name(godot_root, module_path)
        top_delegate_modules.append({
            "module": module_name,
            "module_path": module_path,
            "class_name": class_name,
            "canonical_owner_target": class_name if class_name else module_name,
            "compatibility_surface": "PortGame",
            "function_count": int(module_entry["function_count"]),
            "sample_functions": module_entry["sample_functions"],
        })
    return {
        "path": "src/game/PortGame.gd",
        "exists": True,
        "delegating_function_count": delegating_function_count,
        "source_delegating_function_count": source_delegating_function_count,
        "generated_bridge_delegating_function_count": generated_bridge_delegating_function_count,
        "delegate_module_count": len(delegate_modules),
        "top_delegate_modules": top_delegate_modules,
        "largest_delegate_module": largest_delegate_module,
    }

def _gdscript_class_name(godot_root: Path, resource_path: str) -> str:
    if not resource_path.startswith("res://"):
        return ""
    script_path = Path(godot_root) / resource_path.replace("res://", "")
    if not script_path.exists():
        return ""
    for line in script_path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("class_name "):
            return stripped.split(" ", 1)[1].strip()
    return ""

def write_report(generated_dir: Path, source_manifest: dict | None = None, asset_manifest: dict | None = None, source_root: Path | None = None, godot_root: Path | None = None) -> dict:
    generated_dir = Path(generated_dir)
    godot_root = Path(godot_root) if godot_root is not None else generated_dir.parents[1]
    source_manifest = source_manifest or load_json(generated_dir / "source_manifest.json")
    asset_manifest = asset_manifest or load_json(generated_dir / "asset_manifest.json")
    ast_manifest = load_json(generated_dir / "ast_manifest.json")
    unsupported = [
        "Generated gameplay classes not implemented yet",
        "mindustry.gen generated Java package not expanded yet",
        "Unsupported Java parser failures are listed in ast_manifest.json with paths and error types",
    ]
    unsupported_features = scan_unsupported_features(source_root) if source_root is not None else []
    port_game_footprint = scan_port_game_footprint(godot_root)
    port_game_bridge_surface = scan_port_game_bridge_surface(godot_root)
    report = {
        "java_file_count": source_manifest.get("java_file_count", 0),
        "asset_count": asset_manifest.get("asset_count", 0),
        "asset_total_bytes": asset_manifest.get("total_bytes", 0),
        "parsed_file_count": ast_manifest.get("parsed_file_count", 0),
        "failed_file_count": ast_manifest.get("failed_file_count", 0),
        "port_game_footprint": port_game_footprint,
        "port_game_bridge_surface": port_game_bridge_surface,
        "unsupported": unsupported,
        "unsupported_features": unsupported_features,
    }
    lines = [
        "# Mindustry Godot Port Report",
        "",
        f"Java files scanned: {report['java_file_count']}",
        f"Assets copied: {report['asset_count']}",
        f"Asset bytes copied: {report['asset_total_bytes']}",
        f"Java files parsed: {report['parsed_file_count']}",
        f"Java parse failures: {report['failed_file_count']}",
        f"PortGame lines: {port_game_footprint['line_count']}",
        f"PortGame functions: {port_game_footprint['function_count']}",
        f"PortGame preloads: {port_game_footprint['preload_count']}",
        f"PortGame generated bridge functions: {port_game_footprint['generated_bridge_function_count']}",
        f"PortGame delegating functions: {port_game_bridge_surface['delegating_function_count']}",
        f"PortGame largest delegate module: {port_game_bridge_surface['largest_delegate_module'].get('module', '')}",
        "",
        "## Unsupported Features",
    ]
    lines.extend(f"- {item}" for item in unsupported)
    lines.extend(["", "## Unsupported Source Locations"])
    if unsupported_features:
        lines.extend(f"- {item['path']}:{item['line']} `{item['feature']}` {item['snippet']}" for item in unsupported_features)
    else:
        lines.append("- none recorded")
    generated_dir.mkdir(parents=True, exist_ok=True)
    (generated_dir / "port_report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    write_json(generated_dir / "port_report.json", report)
    return report
