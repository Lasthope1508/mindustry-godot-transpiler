import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.content_registry import build_content_registry, gdscript_literal


class ContentRegistryTests(unittest.TestCase):
    def _write_block_base(self, root: Path) -> None:
        world_source = root / "upstream" / "core" / "src" / "mindustry" / "world"
        world_source.mkdir(parents=True, exist_ok=True)
        (world_source / "Block.java").write_text(
            """
package mindustry.world;
public class Block{
    public boolean canOverdrive = true;
    public int itemCapacity = 10;
}
""",
            encoding="utf-8",
        )
        blocks_source = root / "upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "production"
        blocks_source.mkdir(parents=True, exist_ok=True)
        (blocks_source / "Drill.java").write_text(
            """
package mindustry.world.blocks.production;
public class Drill extends Block{
    public Drill(String name){
        hasItems = true;
    }
}
""",
            encoding="utf-8",
        )

    def test_build_registry_extracts_items_liquids_blocks_and_assets(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            game_source = root / "upstream" / "core" / "src" / "mindustry" / "game"
            source.mkdir(parents=True)
            game_source.mkdir(parents=True)
            self._write_block_base(root)
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
    public static Block air, conveyor, coreShard, router, duo, mechanicalDrill;
    public static void load(){
        air = new AirBlock("air");
        conveyor = new Conveyor("conveyor"){{
            requirements(Category.distribution, with(Items.copper, 1));
            health = 45;
            speed = 0.03f;
            displayedSpeed = 4.2f;
        }};
        coreShard = new CoreBlock("core-shard"){{
            itemCapacity = 4000;
        }};
        router = new Router("router"){{
            requirements(Category.distribution, with(Items.copper, 3));
            size = 2;
            health = 90;
        }};
        duo = new ItemTurret("duo"){{
            requirements(Category.turret, with(Items.copper, 35));
            reload = 20f;
            range = 110f;
            shootY = 3f;
            inaccuracy = 2f;
            rotateSpeed = 10f;
            shootCone = 15f;
            recoils = 2;
            recoil = 0.5f;
            shoot = new ShootAlternate(3.5f);
            ammo(Items.copper, new BasicBulletType(2.5f, 9){{
                width = 7f;
                height = 9f;
                hitSize = 5f;
                lifetime = 60f;
                ammoMultiplier = 2;
            }}, Items.graphite, new BasicBulletType(3.5f, 18){{
                width = 9f;
                height = 12f;
                lifetime = 60f;
                ammoMultiplier = 4;
                rangeChange = 16f;
                reloadMultiplier = 0.8f;
            }}, Items.silicon, new BasicBulletType(3f, 12){{
                width = 7f;
                height = 9f;
                lifetime = 60f;
                ammoMultiplier = 5;
                reloadMultiplier = 1.5f;
            }});
            limitRange(5f);
        }};
        mechanicalDrill = new Drill("mechanical-drill"){{
            requirements(Category.production, with(Items.copper, 12));
            tier = 2;
            drillTime = 600;
            size = 2;
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
    public static UnitType dagger, crawler;
    public static void load(){
        dagger = new UnitType("dagger"){{
            speed = 0.5f;
            health = 150;
            hitSize = 8f;
            weapons.add(new Weapon("large-weapon"){{
                reload = 13f;
                bullet = new BasicBulletType(2.5f, 9){{
                    lifetime = 60f;
                }};
            }});
        }};
        crawler = new UnitType("crawler"){{
            speed = 0.8f;
            health = 120;
            hitSize = 8f;
        }};
    }
}
""",
                encoding="utf-8",
            )
            (game_source / "Waves.java").write_text(
                """
package mindustry.game;
import static mindustry.content.UnitTypes.*;
public class Waves{
    public static final int waveVersion = 7;
    public Seq<SpawnGroup> get(){
        return Seq.with(
            new SpawnGroup(dagger){{
                end = 10;
                unitScaling = 2f;
                max = 30;
            }},
            new SpawnGroup(crawler){{
                begin = 4;
                end = 13;
                unitAmount = 2;
                unitScaling = 1.5f;
            }}
        );
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
        self.assertEqual(registry["blocks"][0], {"field": "air", "id": "air", "implementation": "AirBlock", "properties": {"canOverdrive": True}, "texture": ""})
        self.assertEqual(registry["blocks"][1], {"field": "conveyor", "id": "conveyor", "implementation": "Conveyor", "properties": {"canOverdrive": True, "category": "distribution", "displayedSpeed": 4.2, "health": 45, "requirements": [{"amount": 1, "item": "copper"}], "speed": 0.03}, "texture": "res://assets/core/assets-raw/sprites/blocks/distribution/conveyors/conveyor-0-0.png"})
        self.assertEqual(registry["blocks"][2], {"field": "coreShard", "id": "core-shard", "implementation": "CoreBlock", "properties": {"canOverdrive": True, "itemCapacity": 4000}, "texture": ""})
        self.assertEqual(registry["blocks"][3], {"field": "router", "id": "router", "implementation": "Router", "properties": {"canOverdrive": True, "category": "distribution", "health": 90, "requirements": [{"amount": 3, "item": "copper"}], "size": 2}, "texture": ""})
        self.assertEqual(registry["blocks"][4], {"field": "duo", "id": "duo", "implementation": "ItemTurret", "properties": {"ammo": [{"ammoMultiplier": 2, "damage": 9, "height": 9, "hitSize": 5, "item": "copper", "lifetime": 50.0, "speed": 2.5, "sprite": "bullet", "width": 7}, {"ammoMultiplier": 4, "damage": 18, "height": 12, "item": "graphite", "lifetime": 40.285714285714285, "rangeChange": 16.0, "reloadMultiplier": 0.8, "speed": 3.5, "sprite": "bullet", "width": 9}, {"ammoMultiplier": 5, "damage": 12, "height": 9, "item": "silicon", "lifetime": 41.666666666666664, "reloadMultiplier": 1.5, "speed": 3, "sprite": "bullet", "width": 7}], "ammoPerShot": 1, "canOverdrive": True, "category": "turret", "consumeAmmoOnce": True, "inaccuracy": 2.0, "limitRangeMargin": 5.0, "maxAmmo": 30, "range": 110.0, "recoil": 0.5, "recoils": 2, "reload": 20.0, "requirements": [{"amount": 35, "item": "copper"}], "rotateSpeed": 10.0, "shootCone": 15.0, "shootPattern": {"spread": 3.5, "type": "ShootAlternate"}, "shootY": 3.0}, "texture": ""})
        self.assertEqual(registry["blocks"][5], {"field": "mechanicalDrill", "id": "mechanical-drill", "implementation": "Drill", "properties": {"canOverdrive": True, "category": "production", "drillTime": 600, "hasItems": True, "itemCapacity": 10, "requirements": [{"amount": 12, "item": "copper"}], "size": 2, "tier": 2}, "texture": ""})
        self.assertEqual(registry["units"][0], {"field": "dagger", "id": "dagger", "implementation": "UnitType", "properties": {"health": 150, "hitSize": 8.0, "speed": 0.5, "weapons": [{"bullet": {"damage": 9, "lifetime": 60.0, "speed": 2.5, "sprite": "bullet"}, "reload": 13.0}]}, "texture": "res://assets/core/assets-raw/sprites/units/dagger.png"})
        self.assertEqual(registry["waves"], {"version": 7, "groups": [{"unit": "dagger", "end": 10, "max": 30, "unitScaling": 2.0}, {"unit": "crawler", "begin": 4, "end": 13, "unitAmount": 2, "unitScaling": 1.5}]})
        self.assertEqual(registry["counts"], {"items": 2, "liquids": 1, "blocks": 6, "units": 2})

    def test_gdscript_literal_escapes_strings_and_keeps_types(self):
        self.assertEqual(gdscript_literal({"name": "core-shard", "enabled": True, "size": 3}), '{"enabled": true, "name": "core-shard", "size": 3}')


    def test_build_registry_computes_block_health_from_scaled_health(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            self._write_block_base(root)
            (source / "Items.java").write_text(
                """
package mindustry.content;
public class Items{
    public static Item lead;
    public static void load(){
        lead = new Item("lead", Color.valueOf("8c7fa9"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
public class Liquids{
    public static Liquid water;
    public static void load(){
        water = new Liquid("water", Color.valueOf("596ab8"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block mendProjector;
    public static void load(){
        mendProjector = new MendProjector("mend-projector"){{
            requirements(Category.effect, with(Items.lead, 100));
            size = 2;
            scaledHealth = 80;
            healPercent = 11f;
            phaseBoost = 15f;
            baseColor = Color.valueOf("84f491");
            emitLight = true;
            lightRadius = 50f;
            reload = 250f;
            range = 85f;
            consumeItem(Items.phaseFabric).boost();
        }};
    }
}
""",
                encoding="utf-8",
            )

            registry = build_content_registry(root / "upstream", root / "godot")

        self.assertEqual(registry["blocks"][0]["properties"].get("scaledHealth"), 80)
        self.assertEqual(registry["blocks"][0]["properties"].get("health"), 320)
        self.assertEqual(registry["blocks"][0]["properties"].get("healPercent"), 11.0)
        self.assertEqual(registry["blocks"][0]["properties"].get("phaseBoost"), 15.0)
        self.assertEqual(registry["blocks"][0]["properties"].get("phaseRangeBoost"), 50.0)
        self.assertEqual(registry["blocks"][0]["properties"].get("boosterItem"), "phase-fabric")
        self.assertEqual(registry["blocks"][0]["properties"].get("boosterUseTime"), 400.0)
        self.assertEqual(registry["blocks"][0]["properties"].get("baseColor"), "84f491")
        self.assertEqual(registry["blocks"][0]["properties"].get("emitLight"), True)
        self.assertEqual(registry["blocks"][0]["properties"].get("lightRadius"), 50.0)

    def test_block_registry_resolves_thorium_reactor_consumers(self):
        # N2094: the thorium reactor's cryofluid amount is the field expression
        # `heating / coolantPower` (Blocks.java:2629) — `heating` is assigned in
        # the block initializer (0.02f) and `coolantPower` is a NuclearReactor
        # field default (0.5f), so the amount is 0.04. The consumer is
        # `.update(false)` (not an update consumer). N2095: the thorium item
        # consumer `consumeItem(Items.thorium)` (Blocks.java:2628) is extracted
        # with its default amount of 1.
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            self._write_block_base(root)
            power_source = root / "upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "power"
            power_source.mkdir(parents=True, exist_ok=True)
            (power_source / "NuclearReactor.java").write_text(
                """
package mindustry.world.blocks.power;
public class NuclearReactor extends Block{
    public float coolantPower = 0.5f;
    public NuclearReactor(String name){
    }
}
""",
                encoding="utf-8",
            )
            (source / "Items.java").write_text(
                """
package mindustry.content;
public class Items{
    public static Item lead, thorium;
    public static void load(){
        lead = new Item("lead", Color.valueOf("8c7fa9"));
        thorium = new Item("thorium", Color.valueOf("f9a3ff"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
public class Liquids{
    public static Liquid cryofluid;
    public static void load(){
        cryofluid = new Liquid("cryofluid", Color.valueOf("6f7ed9"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block thoriumReactor;
    public static void load(){
        thoriumReactor = new NuclearReactor("thorium-reactor"){{
            requirements(Category.power, with(Items.lead, 300));
            size = 3;
            health = 700;
            itemDuration = 360f;
            powerProduction = 15f;
            heating = 0.02f;
            consumeItem(Items.thorium);
            consumeLiquid(Liquids.cryofluid, heating / coolantPower).update(false);
        }};
    }
}
""",
                encoding="utf-8",
            )

            registry = build_content_registry(root / "upstream", root / "godot")

        block = registry["blocks"][0]
        self.assertEqual(block["field"], "thoriumReactor")
        self.assertEqual(block["properties"].get("consumeLiquid"), [{"liquid": "cryofluid", "amount": 0.04, "update": False}])
        self.assertEqual(block["properties"].get("consumeItem"), [{"item": "thorium", "amount": 1}])

    def test_block_registry_captures_continuous_liquid_turret_ammo_types(self):
        # N2104: sublimate's ammo map (Blocks.java:4604-4631) is the `ammo(...)`
        # call on the ContinuousLiquidTurret initializer: ozone fires a
        # ContinuousFlameBulletType with ammoMultiplier = 1.2f, cyanogen fires
        # one with no ammoMultiplier set, so it takes the BulletType default
        # of 2f (BulletType.java:95). The class init consumes through a
        # ConsumeLiquidFilter over exactly the ammo liquids
        # (ContinuousLiquidTurret.java:40-51) at `liquidConsumed` (1f / 60f,
        # :15), so the registry carries one consumeLiquid descriptor per ammo
        # liquid at that amount.
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            self._write_block_base(root)
            turret_source = root / "upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "defense" / "turrets"
            turret_source.mkdir(parents=True, exist_ok=True)
            (turret_source / "ContinuousLiquidTurret.java").write_text(
                """
package mindustry.world.blocks.defense.turrets;
public class ContinuousLiquidTurret extends Block{
    public float liquidConsumed = 1f / 60f;
    public ContinuousLiquidTurret(String name){
    }
    public void init(){
        consume(new ConsumeLiquidFilter(i -> ammoTypes.containsKey(i), liquidConsumed){
        });
    }
}
""",
                encoding="utf-8",
            )
            (source / "Items.java").write_text(
                """
package mindustry.content;
public class Items{
    public static Item tungsten;
    public static void load(){
        tungsten = new Item("tungsten", Color.valueOf("a6aeb5"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
public class Liquids{
    public static Liquid ozone, cyanogen;
    public static void load(){
        ozone = new Liquid("ozone", Color.valueOf("eb7abe"));
        cyanogen = new Liquid("cyanogen", Color.valueOf("465ab8"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block sublimate;
    public static void load(){
        sublimate = new ContinuousLiquidTurret("sublimate"){{
            requirements(Category.turret, with(Items.tungsten, 400));
            size = 3;
            ammo(
                Liquids.ozone, new ContinuousFlameBulletType(){{
                    damage = 60f;
                    ammoMultiplier = 1.2f;
                }},
                Liquids.cyanogen, new ContinuousFlameBulletType(){{
                    damage = 130f;
                }}
            );
        }};
    }
}
""",
                encoding="utf-8",
            )

            registry = build_content_registry(root / "upstream", root / "godot")

        block = registry["blocks"][0]
        self.assertEqual(block["field"], "sublimate")
        self.assertEqual(block["properties"].get("ammoTypes"), {"ozone": {"ammoMultiplier": 1.2}, "cyanogen": {"ammoMultiplier": 2.0}})
        self.assertEqual(
            block["properties"].get("consumeLiquid"),
            [{"liquid": "ozone", "amount": 1 / 60}, {"liquid": "cyanogen", "amount": 1 / 60}],
        )


    def test_block_registry_captures_generic_crafter_outputs_and_liquid_capacity(self):
        # N2113: GenericCrafterBuild.shouldConsume() (GenericCrafter.java:203)
        # reads the block's outputItems/outputLiquids against itemCapacity /
        # liquidCapacity, so the registry captures them: the singular
        # outputItem/outputLiquid (written to the plural arrays by
        # GenericCrafter.init(), GenericCrafter.java:120-124), the
        # LiquidStack.with(...) plural form, and liquidCapacity -- the
        # initializer's own assignment (last wins, e.g. `80f * 5`), else
        # Block.init()'s computed default (Block.java:1407-1418:
        # round(10 * consumeAmount)). A commented-out //outputItem must
        # not resolve (slag-centrifuge's scrap line).
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            self._write_block_base(root)
            (source / "Items.java").write_text(
                """
package mindustry.content;
public class Items{
    public static Item silicon, titanium;
    public static void load(){
        silicon = new Item("silicon", Color.valueOf("a6aeb5"));
        titanium = new Item("titanium", Color.valueOf("a6aeb5"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
public class Liquids{
    public static Liquid water, cryofluid, ozone, hydrogen;
    public static void load(){
        water = new Liquid("water", Color.valueOf("596ab8"));
        cryofluid = new Liquid("cryofluid", Color.valueOf("596ab8"));
        ozone = new Liquid("ozone", Color.valueOf("eb7abe"));
        hydrogen = new Liquid("hydrogen", Color.valueOf("596ab8"));
    }
}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block smelter, mixer, electrolyzer;
    public static void load(){
        smelter = new GenericCrafter("smelter"){{
            requirements(Category.crafting, with(Items.silicon, 1));
            outputItem = new ItemStack(Items.silicon, 1);
            consumeLiquid(Liquids.water, 0.2f);
        }};
        mixer = new GenericCrafter("mixer"){{
            requirements(Category.crafting, with(Items.titanium, 1));
            outputLiquid = new LiquidStack(Liquids.cryofluid, 12f / 60f);
            liquidCapacity = 36f;
        }};
        electrolyzer = new GenericCrafter("electrolyzer"){{
            requirements(Category.crafting, with(Items.titanium, 1));
            outputLiquids = LiquidStack.with(Liquids.ozone, 4f / 60, Liquids.hydrogen, 6f / 60);
            liquidCapacity = 50f;
            //outputItem = new ItemStack(Items.silicon, 1);
        }};
    }
}
""",
                encoding="utf-8",
            )

            registry = build_content_registry(root / "upstream", root / "godot")

        by_id = {block["id"]: block for block in registry["blocks"]}
        self.assertEqual(by_id["smelter"]["properties"].get("outputItems"), [{"item": "silicon", "amount": 1}])
        self.assertEqual(by_id["smelter"]["properties"].get("liquidCapacity"), 120.0)
        self.assertEqual(by_id["mixer"]["properties"].get("outputLiquids"), [{"liquid": "cryofluid", "amount": 12 / 60}])
        self.assertEqual(by_id["mixer"]["properties"].get("liquidCapacity"), 36.0)
        self.assertEqual(
            by_id["electrolyzer"]["properties"].get("outputLiquids"),
            [{"liquid": "ozone", "amount": 4 / 60}, {"liquid": "hydrogen", "amount": 6 / 60}],
        )
        self.assertEqual(by_id["electrolyzer"]["properties"].get("liquidCapacity"), 50.0)
        self.assertNotIn("outputItems", by_id["electrolyzer"]["properties"])

    def test_block_registry_extracts_overdrive_projector_source_params(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            block_source = root / "upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "defense"
            assets = root / "godot" / "assets" / "core" / "assets-raw" / "sprites" / "blocks" / "effect"
            source.mkdir(parents=True)
            block_source.mkdir(parents=True)
            assets.mkdir(parents=True)
            self._write_block_base(root)
            (assets / "overdrive-projector.png").write_bytes(b"png")
            (source / "Items.java").write_text(
                """
package mindustry.content;
public class Items{
    public static Item phaseFabric, lead;
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
public class Liquids{}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block overdriveProjector;
    public static void load(){
        overdriveProjector = new OverdriveProjector("overdrive-projector"){{
            requirements(Category.effect, with(Items.lead, 100));
            size = 2;
            consumeItem(Items.phaseFabric).boost();
            ambientSoundVolume = 0.08f;
        }};
    }
}
""",
                encoding="utf-8",
            )
            (block_source / "OverdriveProjector.java").write_text(
                """
package mindustry.world.blocks.defense;
public class OverdriveProjector extends Block{
    public OverdriveProjector(String name){
        super(name);
        canOverdrive = false;
    }
}
""",
                encoding="utf-8",
            )

            registry = build_content_registry(root / "upstream", root / "godot")

        props = registry["blocks"][0]["properties"]
        self.assertEqual(props.get("range"), 80.0)
        self.assertEqual(props.get("reload"), 60.0)
        self.assertEqual(props.get("speedBoost"), 1.5)
        self.assertEqual(props.get("speedBoostPhase"), 0.75)
        self.assertEqual(props.get("phaseRangeBoost"), 20.0)
        self.assertEqual(props.get("boosterUseTime"), 400.0)
        self.assertEqual(props.get("boosterItem"), "phase-fabric")
        self.assertEqual(props.get("baseColor"), "feb380")
        self.assertEqual(props.get("phaseColor"), "ffd59e")
        self.assertEqual(props.get("emitLight"), True)
        self.assertEqual(props.get("lightRadius"), 50.0)
        self.assertEqual(props.get("hasBoost"), True)
        self.assertEqual(props.get("canOverdrive"), False)

    def test_block_registry_extracts_power_block_source_params(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "upstream" / "core" / "src" / "mindustry" / "content"
            power_source = root / "upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "power"
            source.mkdir(parents=True)
            power_source.mkdir(parents=True)
            self._write_block_base(root)
            (source / "Items.java").write_text(
                """
package mindustry.content;
public class Items{
    public static Item copper, lead, coal;
}
""",
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                """
package mindustry.content;
public class Liquids{}
""",
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                """
package mindustry.content;
public class Blocks{
    public static Block multiPress, siliconSmelter, powerNode, battery, combustionGenerator;
    public static void load(){
        multiPress = new GenericCrafter("multi-press"){{
            requirements(Category.crafting, with(Items.titanium, 100, Items.silicon, 25, Items.lead, 100, Items.graphite, 50));
            size = 3;
            hasPower = true;
            consumePower(1.8f);
        }};
        siliconSmelter = new GenericCrafter("silicon-smelter"){{
            requirements(Category.crafting, with(Items.copper, 30, Items.lead, 25));
            size = 2;
            hasPower = true;
            consumePower(0.50f);
        }};
        powerNode = new PowerNode("power-node"){{
            requirements(Category.power, with(Items.copper, 2, Items.lead, 6));
            maxNodes = 10;
            laserRange = 6;
        }};
        battery = new Battery("battery"){{
            requirements(Category.power, with(Items.copper, 5, Items.lead, 20));
            consumePowerBuffered(4000f);
        }};
        combustionGenerator = new ConsumeGenerator("combustion-generator"){{
            requirements(Category.power, with(Items.copper, 25, Items.lead, 15));
            powerProduction = 1f;
            itemDuration = 120f;
        }};
    }
}
""",
                encoding="utf-8",
            )
            (power_source / "PowerBlock.java").write_text(
                """
package mindustry.world.blocks.power;
public class PowerBlock extends Block{
    public PowerBlock(String name){
        hasPower = true;
    }
}
""",
                encoding="utf-8",
            )
            (power_source / "PowerDistributor.java").write_text(
                """
package mindustry.world.blocks.power;
public class PowerDistributor extends PowerBlock{
    public PowerDistributor(String name){
        consumesPower = false;
        outputsPower = true;
    }
}
""",
                encoding="utf-8",
            )
            (power_source / "PowerNode.java").write_text(
                """
package mindustry.world.blocks.power;
public class PowerNode extends PowerBlock{
    public float laserRange = 6;
    public int maxNodes = 3;
    public PowerNode(String name){
        consumesPower = false;
        outputsPower = false;
        canOverdrive = false;
    }
}
""",
                encoding="utf-8",
            )
            (power_source / "Battery.java").write_text(
                """
package mindustry.world.blocks.power;
public class Battery extends PowerDistributor{
    public Battery(String name){
        outputsPower = true;
        consumesPower = true;
        canOverdrive = false;
    }
}
""",
                encoding="utf-8",
            )
            (power_source / "PowerGenerator.java").write_text(
                """
package mindustry.world.blocks.power;
public class PowerGenerator extends PowerDistributor{
    public float powerProduction;
}
""",
                encoding="utf-8",
            )
            (power_source / "ConsumeGenerator.java").write_text(
                """
package mindustry.world.blocks.power;
public class ConsumeGenerator extends PowerGenerator{
    public float itemDuration = 120f;
}
""",
                encoding="utf-8",
            )

            registry = build_content_registry(root / "upstream", root / "godot")

        multi_press = registry["blocks"][0]["properties"]
        self.assertEqual(multi_press.get("consumePower"), 1.8)
        self.assertEqual(multi_press.get("powerUsage"), 1.8)
        self.assertEqual(multi_press.get("powerCapacity"), 0.0)
        self.assertEqual(multi_press.get("powerBuffered"), False)
        self.assertEqual(multi_press.get("hasPower"), True)
        self.assertEqual(multi_press.get("consumesPower"), True)
        silicon_smelter = registry["blocks"][1]["properties"]
        self.assertEqual(silicon_smelter.get("consumePower"), 0.5)
        self.assertEqual(silicon_smelter.get("powerUsage"), 0.5)
        self.assertEqual(silicon_smelter.get("powerCapacity"), 0.0)
        self.assertEqual(silicon_smelter.get("powerBuffered"), False)
        self.assertEqual(silicon_smelter.get("hasPower"), True)
        self.assertEqual(silicon_smelter.get("consumesPower"), True)
        power_node = registry["blocks"][2]["properties"]
        self.assertEqual(power_node.get("maxNodes"), 10)
        self.assertEqual(power_node.get("laserRange"), 6)
        self.assertEqual(power_node.get("hasPower"), True)
        self.assertEqual(power_node.get("consumesPower"), False)
        self.assertEqual(power_node.get("outputsPower"), False)
        self.assertEqual(power_node.get("canOverdrive"), False)
        battery = registry["blocks"][3]["properties"]
        self.assertEqual(battery.get("consumePowerBuffered"), 4000.0)
        self.assertEqual(battery.get("hasPower"), True)
        self.assertEqual(battery.get("consumesPower"), True)
        self.assertEqual(battery.get("outputsPower"), True)
        self.assertEqual(battery.get("canOverdrive"), False)
        generator = registry["blocks"][4]["properties"]
        self.assertEqual(generator.get("powerProduction"), 1.0)
        self.assertEqual(generator.get("itemDuration"), 120.0)
        self.assertEqual(generator.get("hasPower"), True)
        self.assertEqual(generator.get("consumesPower"), False)
        self.assertEqual(generator.get("outputsPower"), True)
if __name__ == "__main__":
    unittest.main()
