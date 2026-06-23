import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.assets import copy_assets


class AssetBridgeTests(unittest.TestCase):
    def test_copy_assets_preserves_relative_paths_and_hashes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            upstream = root / "mindustry-upstream"
            source = upstream / "core" / "assets" / "sprites"
            raw = upstream / "core" / "assets-raw" / "sprites" / "items"
            source.mkdir(parents=True)
            raw.mkdir(parents=True)
            (source / "logo.png").write_bytes(b"png-bytes")
            (raw / "item-copper.png").write_bytes(b"copper-bytes")

            out = root / "godot" / "assets"
            manifest = copy_assets(upstream, out)

            self.assertEqual(manifest["asset_count"], 2)
            self.assertTrue((out / "core" / "assets" / "sprites" / "logo.png").exists())
            self.assertTrue((out / "core" / "assets-raw" / "sprites" / "items" / "item-copper.png").exists())
            self.assertEqual(len(manifest["assets"][0]["sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
