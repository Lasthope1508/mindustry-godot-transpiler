import hashlib
import shutil
from pathlib import Path

ASSET_ROOTS = (Path("core") / "assets", Path("core") / "assets-raw")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def copy_assets(upstream_root: Path, output_assets_root: Path) -> dict:
    upstream_root = Path(upstream_root)
    output_assets_root = Path(output_assets_root)
    copied = []

    for asset_root in ASSET_ROOTS:
        source_root = upstream_root / asset_root
        if not source_root.exists():
            continue
        for source in sorted(path for path in source_root.rglob("*") if path.is_file()):
            relative = source.relative_to(upstream_root)
            target = output_assets_root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            copied.append({
                "source": relative.as_posix(),
                "target": target.relative_to(output_assets_root).as_posix(),
                "bytes": source.stat().st_size,
                "sha256": sha256_file(source),
            })

    return {
        "asset_count": len(copied),
        "total_bytes": sum(item["bytes"] for item in copied),
        "assets": copied,
    }
