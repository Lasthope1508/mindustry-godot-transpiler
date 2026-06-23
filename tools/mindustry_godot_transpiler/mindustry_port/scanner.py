import hashlib
import re
from pathlib import Path


PACKAGE_RE = re.compile(r"^\s*package\s+([a-zA-Z0-9_.]+)\s*;", re.MULTILINE)
TYPE_RE = re.compile(r"\b(?:public\s+|private\s+|protected\s+|abstract\s+|final\s+|static\s+)*(?:class|enum|interface)\s+([A-Za-z_][A-Za-z0-9_]*)")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def extract_package(source: str) -> str:
    match = PACKAGE_RE.search(source)
    return match.group(1) if match else ""


def extract_types(source: str) -> list[str]:
    return TYPE_RE.findall(source)


def scan_source_tree(source_root: Path) -> dict:
    source_root = Path(source_root)
    files = []
    for java_file in sorted(source_root.rglob("*.java")):
        source = java_file.read_text(encoding="utf-8", errors="replace")
        files.append({
            "path": java_file.relative_to(source_root).as_posix(),
            "package": extract_package(source),
            "types": extract_types(source),
            "sha256": sha256_file(java_file),
            "bytes": java_file.stat().st_size,
        })

    return {
        "source_root": source_root.as_posix(),
        "java_file_count": len(files),
        "files": files,
    }
