from pathlib import Path


GENERATED_DIR = Path("src") / "generated"
ASSET_SOURCE_DIRS = (Path("core") / "assets", Path("core") / "assets-raw")


def ensure_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    return path
