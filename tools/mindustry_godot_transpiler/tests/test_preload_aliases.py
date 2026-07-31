import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GD_ROOTS = [
    ROOT / "godot-mindustry" / "src" / "game",
    ROOT / "godot-mindustry" / "src" / "generated" / "classes",
    ROOT / "godot-mindustry" / "tools" / "runtime_proofs",
]
PRELOAD_RE = re.compile(r'^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?::=|=)\s*preload\("([^"]+)"\)', re.MULTILINE)


class PreloadAliasTests(unittest.TestCase):
    def test_preload_aliases_do_not_reuse_global_class_names(self) -> None:
        offenders: list[str] = []
        for root in GD_ROOTS:
            for path in root.rglob("*.gd"):
                text = path.read_text(encoding="utf-8")
                for match in PRELOAD_RE.finditer(text):
                    alias = match.group(1)
                    preload_path = match.group(2)
                    stem = Path(preload_path).stem
                    if alias == stem:
                        line = text[: match.start()].count("\n") + 1
                        offenders.append(f"{path.relative_to(ROOT)}:{line}: {alias} -> {preload_path}")
        self.assertEqual([], offenders, "preload alias collisions:\n" + "\n".join(offenders[:50]))
