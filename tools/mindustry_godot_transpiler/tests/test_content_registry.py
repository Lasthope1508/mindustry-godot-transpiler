import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.content_registry import build_content_registry, gdscript_literal


class ContentRegistryTests(unittest.TestCase):
    def test_build_registry_extracts_items_liquids_blocks_and_assets(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            (source / "Items.java").write_text(
                """
package mindustry.content;
import arc.graphics.*;
import mindustry.type.*;
public class Items{
    public static Item copper, lead;
    public static void load(){
        copper = new Item("copper", Color.valueOf("d99d73")){{
            hardness = 1;
            cost = 0.5f;
            alwaysUnlocked = true;
        }};
        lead = new Item("lead", Color.valueOf("8c7fa9"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
import arc.graphics.*;
import mindustry.type.*;
public class Liquids{
    public static Liquid water;
    public static void load(){
        water = new Liquid("water", Color.valueOf("596ab8")){{
            heatCapacity = 0.4f;
            gas = false;
        }};
    }
}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block air, conveyor, coreShard, router;
    public static void load(){
        air = new AirBlock("air");
        conveyor = new Conveyor("conveyor");
        coreShard = new CoreBlock("core-shard");
        router = new Router("router"){{
            requirements(Category.distribution, with(Items.copper, 3));
            size = 2;
            health = 90;
        }};
        drawer = new DrawTurret("not-a-block-field");
    }
}
""",
                encoding="utf-8",
            )
            (source / "UnitTypes.java").write_text(
                """
package mindustry.content;
import mindustry.type.*;
public class UnitTypes{
    public static UnitType dagger;
    public static void load(){
        dagger = new UnitType("dagger"){{
            speed = 0.5f;
            health = 150;
            hitSize = 8f;
        }};
    }
}
""",
                encoding="utf-8",
            )
            assets = root / "godot" / "assets"
            (assets / "core/assets-raw/sprites/items").mkdir(parents=True)
            (assets / "core/assets-raw/sprites/items/item-copper.png").write_bytes(b"png")
            (assets / "core/assets-raw/sprites/items/liquid-water.png").write_bytes(b"png")
            (assets / "core/assets-raw/sprites/blocks/distribution/conveyors").mkdir(parents=True)
            (assets / "core/assets-raw/sprites/blocks/distribution/conveyors/conveyor-0-0.png").write_bytes(b"png")
            (assets / "core/assets-raw/sprites/units").mkdir(parents=True)
            (assets / "core/assets-raw/sprites/units/dagger.png").write_bytes(b"png")

            registry = build_content_registry(root / "upstream", root / "godot")

        self.assertEqual([item["id"] for item in registry["items"]], ["copper", "lead"])
        self.assertEqual(registry["items"][0]["color"], "d99d73")
        self.assertEqual(registry["items"][0]["properties"]["hardness"], 1)
        self.assertEqual(registry["items"][0]["properties"]["alwaysUnlocked"], True)
        self.assertEqual(registry["items"][0]["texture"], "res://assets/core/assets-raw/sprites/items/item-copper.png")
        self.assertEqual(registry["liquids"][0]["id"], "water")
        self.assertEqual(registry["liquids"][0]["properties"]["heatCapacity"], 0.4)
        self.assertEqual(registry["blocks"][0], {"field": "air", "id": "air", "implementation": "AirBlock", "properties": {}, "texture": ""})
        self.assertEqual(registry["blocks"][1], {"field": "conveyor", "id": "conveyor", "implementation": "Conveyor", "properties": {}, "texture": "res://assets/core/assets-raw/sprites/blocks/distribution/conveyors/conveyor-0-0.png"})
        self.assertEqual(registry["blocks"][2], {"field": "coreShard", "id": "core-shard", "implementation": "CoreBlock", "properties": {}, "texture": ""})
        self.assertEqual(registry["blocks"][3], {"field": "router", "id": "router", "implementation": "Router", "properties": {"category": "distribution", "health": 90, "requirements": [{"amount": 3, "item": "copper"}], "size": 2}, "texture": ""})
        self.assertEqual(registry["units"], [{"field": "dagger", "id": "dagger", "implementation": "UnitType", "properties": {"health": 150, "hitSize": 8.0, "speed": 0.5}, "texture": "res://assets/core/assets-raw/sprites/units/dagger.png"}])
        self.assertEqual(registry["counts"], {"items": 2, "liquids": 1, "blocks": 4, "units": 1})

    def test_gdscript_literal_escapes_strings_and_keeps_types(self):
        self.assertEqual(gdscript_literal({"name": "core-shard", "enabled": True, "size": 3}), '{"enabled": true, "name": "core-shard", "size": 3}')


if __name__ == "__main__":
    unittest.main()
