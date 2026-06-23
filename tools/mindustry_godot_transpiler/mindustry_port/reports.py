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


def write_report(generated_dir: Path, source_manifest: dict | None = None, asset_manifest: dict | None = None, source_root: Path | None = None) -> dict:
    generated_dir = Path(generated_dir)
    source_manifest = source_manifest or load_json(generated_dir / "source_manifest.json")
    asset_manifest = asset_manifest or load_json(generated_dir / "asset_manifest.json")
    ast_manifest = load_json(generated_dir / "ast_manifest.json")
    unsupported = [
        "Generated gameplay classes not implemented yet",
        "mindustry.gen generated Java package not expanded yet",
        "Unsupported Java parser failures are listed in ast_manifest.json with paths and error types",
    ]
    unsupported_features = scan_unsupported_features(source_root) if source_root is not None else []
    report = {
        "java_file_count": source_manifest.get("java_file_count", 0),
        "asset_count": asset_manifest.get("asset_count", 0),
        "asset_total_bytes": asset_manifest.get("total_bytes", 0),
        "parsed_file_count": ast_manifest.get("parsed_file_count", 0),
        "failed_file_count": ast_manifest.get("failed_file_count", 0),
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
