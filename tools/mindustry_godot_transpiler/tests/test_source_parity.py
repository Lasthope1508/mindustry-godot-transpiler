import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.source_parity import verify_duo_source_parity
from mindustry_port import source_parity


class SourceParityTests(unittest.TestCase):
    def test_generated_duo_values_match_upstream_blocks_source(self):
        report = verify_duo_source_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "duo")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"]["properties"]["reload"], 20.0)
        self.assertEqual(report["checked"]["properties"]["range"], 160)
        self.assertEqual(report["checked"]["properties"]["health"], 250)
        self.assertEqual(report["checked"]["properties"].get("shootY"), 3.0)
        self.assertEqual(report["checked"]["properties"].get("inaccuracy"), 2.0)
        self.assertEqual(report["checked"]["properties"].get("rotateSpeed"), 10.0)
        self.assertEqual(report["checked"]["properties"].get("shootCone"), 15.0)
        self.assertEqual(report["checked"]["properties"].get("recoil"), 0.5)
        self.assertEqual(report["checked"]["properties"].get("recoils"), 2)
        self.assertEqual(report["checked"]["properties"].get("limitRangeMargin"), 5.0)
        self.assertEqual(report["checked"]["properties"].get("shootPattern"), {"type": "ShootAlternate", "spread": 3.5})
        self.assertAlmostEqual(report["checked"]["ammo"]["copper"]["lifetime"], 70.0)
        self.assertAlmostEqual(report["checked"]["ammo"]["graphite"]["lifetime"], 54.57142857142857)
        self.assertAlmostEqual(report["checked"]["ammo"]["silicon"]["lifetime"], 58.333333333333336)
        self.assertEqual(report["checked"]["ammo"]["copper"]["ammoMultiplier"], 2)
        self.assertEqual(report["checked"]["ammo"]["graphite"]["rangeChange"], 16.0)
        self.assertEqual(report["checked"]["ammo"]["graphite"]["reloadMultiplier"], 0.8)
        self.assertEqual(report["checked"]["ammo"]["silicon"]["reloadMultiplier"], 1.5)


    def test_generated_mend_projector_scaled_health_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_scaled_health_parity"))
        report = source_parity.verify_mend_projector_scaled_health_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"], {"size": 2, "scaledHealth": 80, "health": 320})

    def test_generated_mend_projector_repair_params_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_repair_parity"))
        report = source_parity.verify_mend_projector_repair_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"], {"healPercent": 11.0, "phaseBoost": 15.0, "phaseRangeBoost": 50.0, "boosterItem": "phase-fabric", "boosterUseTime": 400.0})

    def test_generated_mend_projector_repair_amount_matches_source_formula(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_repair_amount_parity"))
        report = source_parity.verify_mend_projector_repair_amount_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"]["health"], 320)
        self.assertEqual(report["checked"]["healPercent"], 11.0)
        self.assertEqual(report["checked"]["phaseHeat"], 0.0)
        self.assertEqual(report["checked"]["efficiency"], 1.0)
        self.assertAlmostEqual(report["checked"]["repairAmount"], 35.2)

    def test_generated_mend_projector_light_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_light_parity"))
        report = source_parity.verify_mend_projector_light_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/MendProjector.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"], {"baseColor": "84f491", "emitLight": True, "lightRadius": 50.0})

    def test_generated_overdrive_projector_params_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_overdrive_projector_params_parity"))
        report = source_parity.verify_overdrive_projector_params_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "overdrive-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"], {
            "range": 80.0,
            "reload": 60.0,
            "speedBoost": 1.5,
            "speedBoostPhase": 0.75,
            "phaseRangeBoost": 20.0,
            "boosterItem": "phase-fabric",
            "boosterUseTime": 400.0,
            "baseColor": "feb380",
            "phaseColor": "ffd59e",
            "emitLight": True,
            "lightRadius": 50.0,
            "hasBoost": True,
            "canOverdrive": False,
        })

    def test_generated_power_block_params_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_block_params_parity"))
        report = source_parity.verify_power_block_params_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"]["power-node"], {
            "maxNodes": 10,
            "laserRange": 6,
            "hasPower": True,
            "consumesPower": False,
            "outputsPower": False,
            "canOverdrive": False,
        })
        self.assertEqual(report["checked"]["battery"], {
            "consumePowerBuffered": 4000.0,
            "hasPower": True,
            "consumesPower": True,
            "outputsPower": True,
            "canOverdrive": False,
        })
        self.assertEqual(report["checked"]["combustion-generator"], {
            "powerProduction": 1.0,
            "itemDuration": 120.0,
            "hasPower": True,
            "consumesPower": False,
            "outputsPower": True,
        })

    def test_generated_consume_power_usage_params_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_consume_power_usage_params_parity"))
        report = source_parity.verify_consume_power_usage_params_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertIn("core/src/mindustry/world/Block.java", report["sources"])
        self.assertIn("core/src/mindustry/world/consumers/ConsumePower.java", report["sources"])
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"]["multi-press"], {
            "consumePower": 1.8,
            "powerUsage": 1.8,
            "powerCapacity": 0.0,
            "powerBuffered": False,
            "hasPower": True,
            "consumesPower": True,
        })
        self.assertEqual(report["checked"]["silicon-smelter"], {
            "consumePower": 0.5,
            "powerUsage": 0.5,
            "powerCapacity": 0.0,
            "powerBuffered": False,
            "hasPower": True,
            "consumesPower": True,
        })

    def test_power_generator_get_power_production_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_get_power_production_source"))
        report = source_parity.verify_power_generator_get_power_production_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertEqual(report["checked"], {
            "field": "public float powerProduction;",
            "build_class": "public class GeneratorBuild extends Building{",
            "production_efficiency": "public float productionEfficiency = 0.0f;",
            "enabled": "transient boolean enabled = true;",
            "method": "public float getPowerProduction(){",
            "return_power_production": "return enabled ? powerProduction * productionEfficiency : 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_displayed_power_production_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_displayed_power_production_source"))
        report = source_parity.verify_power_generator_displayed_power_production_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertIn("core/src/mindustry/game/Schematic.java", report["sources"])
        self.assertEqual(report["checked"], {
            "field": "public float powerProduction;",
            "method": "public float getDisplayedPowerProduction(){",
            "return_power_production": "return powerProduction;",
            "schematic_method": "public float powerProduction(){",
            "schematic_sum": "return tiles.sumf(s -> s.block instanceof PowerGenerator p ? p.getDisplayedPowerProduction() : 0f);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_build_serialization_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_build_serialization_source"))
        report = source_parity.verify_power_generator_build_serialization_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["checked"], {
            "generate_time": "public float generateTime;",
            "production_efficiency": "public float productionEfficiency = 0.0f;",
            "version_override": "@Override",
            "version_method": "public byte version(){",
            "version_return": "return 1;",
            "write_method": "public void write(Writes write){",
            "write_super": "super.write(write);",
            "write_production_efficiency": "write.f(productionEfficiency);",
            "write_generate_time": "write.f(generateTime);",
            "read_method": "public void read(Reads read, byte revision){",
            "read_super": "super.read(read, revision);",
            "read_production_efficiency": "productionEfficiency = read.f();",
            "read_revision_guard": "if(revision >= 1){",
            "read_generate_time": "generateTime = read.f();",
        })
        self.assertEqual(report["missing"], [])

    def test_solar_generator_update_tile_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_solar_generator_update_tile_source"))
        report = source_parity.verify_solar_generator_update_tile_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/SolarGenerator.java")
        self.assertIn("core/src/mindustry/game/Rules.java", report["sources"])
        self.assertIn("core/src/mindustry/world/meta/Attribute.java", report["sources"])
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "build_class": "public class SolarGeneratorBuild extends GeneratorBuild{",
            "override": "@Override",
            "method": "public void updateTile(){",
            "assignment": "productionEfficiency = enabled ?",
            "solar_multiplier": "state.rules.solarMultiplier * Mathf.maxZero(Attribute.light.env() +",
            "lighting_branch": "(state.rules.lighting ?",
            "ambient_alpha": "1f - state.rules.ambientLight.a :",
            "unlit_bonus": "1f",
            "disabled_return": ")) : 0f;",
            "rules_solar_multiplier": "public float solarMultiplier = 1f;",
            "rules_lighting": "public boolean lighting = false;",
            "rules_ambient_light": "public Color ambientLight = new Color(0.01f, 0.01f, 0.04f, 0.99f);",
            "attribute_light": "light = add(\"light\"),",
            "attribute_env_method": "public float env(){",
            "attribute_env_return": "return Vars.state.envAttrs.get(this);",
            "mathf_max_zero": "public static float maxZero(float val){",
            "mathf_max_zero_return": "return Math.max(val, 0);",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_update_tile_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_update_tile_source"))
        report = source_parity.verify_thermal_generator_update_tile_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/world/meta/Attribute.java", report["sources"])
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "attribute_field": "public Attribute attribute = Attribute.heat;",
            "no_update_disabled": "noUpdateDisabled = true;",
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "sum_field": "public float sum;",
            "override": "@Override",
            "method": "public void updateTile(){",
            "assignment": "productionEfficiency = sum + attribute.env();",
            "attribute_heat_comment": "/** Heat content. Used for thermal generator yield. */",
            "attribute_heat": "heat = add(\"heat\"),",
            "attribute_env_method": "public float env(){",
            "attribute_env_null_guard": "if(Vars.state == null) return 0;",
            "attribute_env_return": "return Vars.state.envAttrs.get(this);",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_update_tile_effect_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_update_tile_effect_source"))
        report = source_parity.verify_thermal_generator_update_tile_effect_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "generate_effect_field": "public Effect generateEffect = Fx.none;",
            "effect_chance_field": "public float effectChance = 0.05f;",
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "method": "public void updateTile(){",
            "production_assignment": "productionEfficiency = sum + attribute.env();",
            "effect_gate": "if(productionEfficiency > 0.1f && Mathf.chanceDelta(effectChance)){",
            "generate_effect_call": "generateEffect.at(x + Mathf.range(3f), y + Mathf.range(3f));",
            "mathf_chance_delta": "public static boolean chanceDelta(double d){",
            "mathf_chance_delta_body": "return rand.nextFloat() < d * Time.delta;",
            "mathf_range_float": "public static float range(float range){",
            "mathf_range_float_body": "return random(-range, range);",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_update_tile_output_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_update_tile_output_liquid_source"))
        report = source_parity.verify_thermal_generator_update_tile_output_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "output_liquid_field": "public @Nullable LiquidStack outputLiquid;",
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "method": "public void updateTile(){",
            "output_liquid_guard": "if(outputLiquid != null){",
            "added_assignment": "float added = Math.min(productionEfficiency * delta() * outputLiquid.amount, liquidCapacity - liquids.get(outputLiquid.liquid));",
            "liquids_add_call": "liquids.add(outputLiquid.liquid, added);",
            "dump_liquid_call": "dumpLiquid(outputLiquid.liquid);",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_displayed_power_production_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_displayed_power_production_source"))
        report = source_parity.verify_thermal_generator_displayed_power_production_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "power_production": "public float powerProduction;",
            "display_efficiency_scale": "public float displayEfficiencyScale = 1f;",
            "override": "@Override",
            "method": "public float getDisplayedPowerProduction(){",
            "return_displayed_power": "return powerProduction / displayEfficiencyScale;",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_init_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_init_source"))
        report = source_parity.verify_thermal_generator_init_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "output_liquid_field": "public @Nullable LiquidStack outputLiquid;",
            "override": "@Override",
            "method": "public void init(){",
            "output_liquid_guard": "if(outputLiquid != null){",
            "outputs_liquid": "outputsLiquid = true;",
            "has_liquids": "hasLiquids = true;",
            "emit_light": "emitLight = true;",
            "super_init": "super.init();",
            "light_clip_comment": "//proper light clipping",
            "light_clip_assignment": "lightClipSize = Math.max(lightClipSize, 45f * size * 2f * 2f);",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_total_progress_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_total_progress_source"))
        report = source_parity.verify_thermal_generator_total_progress_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertEqual(report["checked"], {
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "sum_field": "public float sum;",
            "override": "@Override",
            "method": "public float totalProgress(){",
            "return_total_progress": "return enabled && sum > 0 ? super.totalProgress() : 0f;",
            "parent_comment": "/** @return total time this block has been producing something; non-crafter blocks usually return Time.time. */",
            "parent_method": "public float totalProgress(){",
            "parent_return": "return Time.time;",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_after_picked_up_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_after_picked_up_source"))
        report = source_parity.verify_thermal_generator_after_picked_up_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertEqual(report["checked"], {
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "sum_field": "public float sum;",
            "override": "@Override",
            "method": "public void afterPickedUp(){",
            "super_call": "super.afterPickedUp();",
            "sum_reset": "sum = 0f;",
            "parent_comment": "Called right after this building is picked up.",
            "parent_method": "public void afterPickedUp(){",
            "parent_power_guard": "if(power != null){",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_on_proximity_added_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_on_proximity_added_source"))
        report = source_parity.verify_thermal_generator_on_proximity_added_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertIn("core/src/mindustry/world/Block.java", report["sources"])
        self.assertEqual(report["checked"], {
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "sum_field": "public float sum;",
            "override": "@Override",
            "method": "public void onProximityAdded(){",
            "super_call": "super.onProximityAdded();",
            "sum_assignment": "sum = sumAttribute(attribute, tile.x, tile.y);",
            "parent_comment": "Called after this building is created in the world. May be called multiple times, or when adjacent buildings change.",
            "parent_method": "public void onProximityAdded(){",
            "parent_power_guard": "if(power != null){",
            "parent_update_power_graph": "updatePowerGraph();",
            "sum_attribute_method": "public float sumAttribute(@Nullable Attribute attr, int x, int y){",
            "sum_attribute_null_attr": "if(attr == null) return 0;",
            "sum_attribute_null_tile": "if(tile == null) return 0;",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_can_place_on_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_can_place_on_source"))
        report = source_parity.verify_thermal_generator_can_place_on_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/world/Block.java", report["sources"])
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "attribute_field": "public Attribute attribute = Attribute.heat;",
            "min_efficiency_field": "public float minEfficiency = 0f;",
            "override": "@Override",
            "method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){",
            "heat_comment": "//make sure there's heat at this location",
            "return_can_place_on": "return tile.getLinkedTilesAs(this, tempTiles).sumf(other -> other.floor().attributes.get(attribute)) > minEfficiency;",
            "parent_method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){",
            "parent_return": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_draw_light_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_draw_light_source"))
        report = source_parity.verify_thermal_generator_draw_light_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/graphics/Drawf.java", report["sources"])
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertIn("arc-core/src/arc/graphics/Color.java", report["sources"])
        self.assertEqual(report["checked"], {
            "build_class": "public class ThermalGeneratorBuild extends GeneratorBuild{",
            "override": "@Override",
            "method": "public void drawLight(){",
            "drawf_light_call": "Drawf.light(x, y, (40f + Mathf.absin(10f, 5f)) * Math.min(productionEfficiency, 2f) * size, Color.scarlet, 0.4f);",
            "drawf_light_method": "public static void light(float x, float y, float radius, Color color, float opacity){",
            "drawf_renderer_guard": "if(renderer == null) return;",
            "drawf_lights_add": "renderer.lights.add(x, y, radius, color, opacity);",
            "absin_time_overload": "public static float absin(float scl, float mag){",
            "absin_time_return": "return absin(Time.time, scl, mag);",
            "absin_formula": "return (sin(in, scl * 2f, mag) + mag) / 2f;",
            "scarlet": "public static final Color scarlet = new Color(0xff341cff);",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_set_stats_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_set_stats_source"))
        report = source_parity.verify_thermal_generator_set_stats_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/world/blocks/power/PowerGenerator.java", report["sources"])
        self.assertIn("core/src/mindustry/world/Block.java", report["sources"])
        self.assertIn("core/src/mindustry/world/meta/Stats.java", report["sources"])
        self.assertIn("core/src/mindustry/world/meta/Stat.java", report["sources"])
        self.assertIn("core/src/mindustry/world/meta/StatUnit.java", report["sources"])
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "attribute_field": "public Attribute attribute = Attribute.heat;",
            "display_efficiency_scale": "public float displayEfficiencyScale = 1f;",
            "display_efficiency": "public boolean displayEfficiency = true;",
            "override": "@Override",
            "method": "public void setStats(){",
            "super_call": "super.setStats();",
            "tiles_stat_add": "stats.add(Stat.tiles, attribute, floating, size * size * displayEfficiencyScale, !displayEfficiency);",
            "generation_type_remove": "stats.remove(generationType);",
            "generation_type_add": "stats.add(generationType, powerProduction * 60.0f / displayEfficiencyScale, StatUnit.powerSecond);",
            "power_production_field": "public float powerProduction;",
            "generation_type_field": "public Stat generationType = Stat.basePowerGeneration;",
            "floating_field": "public boolean floating = false;",
            "stats_add_attribute": "public void add(Stat stat, Attribute attr, boolean floating, float scale, boolean startZero){",
            "stats_remove": "public void remove(Stat stat){",
            "stat_base_power_generation": "basePowerGeneration = new Stat(\"basePowerGeneration\", StatCat.power),",
            "stat_tiles": "tiles = new Stat(\"tiles\", StatCat.crafting),",
            "stat_unit_power_second": "powerSecond = new StatUnit(\"powerSecond\", \"[accent]\" + Iconc.power + \"[]\"),",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_set_stats_output_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_set_stats_output_liquid_source"))
        report = source_parity.verify_thermal_generator_set_stats_output_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/type/LiquidStack.java", report["sources"])
        self.assertIn("core/src/mindustry/world/meta/Stat.java", report["sources"])
        self.assertIn("core/src/mindustry/world/meta/StatValues.java", report["sources"])
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "output_liquid_field": "public @Nullable LiquidStack outputLiquid;",
            "method": "public void setStats(){",
            "output_liquid_guard": "if(outputLiquid != null){",
            "output_liquid_stat_add": "stats.add(Stat.output, StatValues.liquid(outputLiquid.liquid, outputLiquid.amount * size * size * 60f, true));",
            "liquid_stack_class": "public class LiquidStack implements Comparable<LiquidStack>{",
            "liquid_stack_liquid": "public Liquid liquid;",
            "liquid_stack_amount": "public float amount;",
            "stat_output": "output = new Stat(\"output\", StatCat.crafting),",
            "stat_values_liquid": "public static StatValue liquid(Liquid liquid, float amount, boolean perSecond){",
            "stat_values_liquid_return": "return table -> table.add(displayLiquid(liquid, amount, perSecond)).left();",
        })
        self.assertEqual(report["missing"], [])

    def test_thermal_generator_draw_place_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_thermal_generator_draw_place_source"))
        report = source_parity.verify_thermal_generator_draw_place_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/ThermalGenerator.java")
        self.assertIn("core/src/mindustry/world/Block.java", report["sources"])
        self.assertIn("core/assets/bundles/bundle.properties", report["sources"])
        self.assertEqual(report["checked"], {
            "class": "public class ThermalGenerator extends PowerGenerator{",
            "display_efficiency_scale": "public float displayEfficiencyScale = 1f;",
            "display_efficiency": "public boolean displayEfficiency = true;",
            "attribute_field": "public Attribute attribute = Attribute.heat;",
            "method": "public void drawPlace(int x, int y, int rotation, boolean valid){",
            "super_call": "super.drawPlace(x, y, rotation, valid);",
            "display_efficiency_guard": "if(displayEfficiency){",
            "draw_place_text_call": "drawPlaceText(Core.bundle.formatFloat(\"bar.efficiency\", sumAttribute(attribute, x, y) * 100 * displayEfficiencyScale, 1), x, y, valid);",
            "block_draw_place": "public void drawPlace(int x, int y, int rotation, boolean valid){",
            "block_draw_place_text": "public float drawPlaceText(String text, int x, int y, boolean valid){",
            "bundle_efficiency": "bar.efficiency = Efficiency: {0}%",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_warmup_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_warmup_source"))
        report = source_parity.verify_power_generator_warmup_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertEqual(report["checked"], {
            "build_class": "public class GeneratorBuild extends Building{",
            "production_efficiency": "public float productionEfficiency = 0.0f;",
            "enabled": "transient boolean enabled = true;",
            "override": "@Override",
            "method": "public float warmup(){",
            "return_warmup": "return enabled ? productionEfficiency : 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_should_explode_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_should_explode_source"))
        report = source_parity.verify_power_generator_should_explode_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["checked"], {
            "field": "public float explosionMinWarmup = 0f;",
            "method": "public boolean shouldExplode(){",
            "warmup_call": "warmup()",
            "return_should_explode": "return warmup() >= explosionMinWarmup;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_ambient_volume_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_ambient_volume_source"))
        report = source_parity.verify_power_generator_ambient_volume_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "production_efficiency": "public float productionEfficiency = 0.0f;",
            "method": "public float ambientVolume(){",
            "return_clamp": "return Mathf.clamp(productionEfficiency);",
            "mathf_clamp_method": "public static float clamp(float value){",
            "mathf_clamp_return": "return Math.max(Math.min(value, 1f), 0f);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_gate_source"))
        report = source_parity.verify_power_generator_create_explosion_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["checked"], {
            "method": "public void createExplosion(){",
            "gate": "if(shouldExplode()){",
            "damage_guard": "if(explosionDamage > 0){",
            "damage_dispatch": "Damage.damage(x, y, explosionRadius * tilesize, explosionDamage);",
            "effect": "explodeEffect.at(this);",
            "sound": "explodeSound.at(this);",
            "puddle_guard": "if(explosionPuddleLiquid != null){",
            "shake_guard": "if(explosionShake > 0){",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_damage_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_damage_source"))
        report = source_parity.verify_power_generator_create_explosion_damage_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertIn("core/src/mindustry/entities/Damage.java", report["sources"])
        self.assertIn("core/src/mindustry/Vars.java", report["sources"])
        self.assertEqual(report["checked"], {
            "method": "public void createExplosion(){",
            "gate": "if(shouldExplode()){",
            "damage_guard": "if(explosionDamage > 0){",
            "damage_dispatch": "Damage.damage(x, y, explosionRadius * tilesize, explosionDamage);",
            "damage_overload_method": "public static void damage(float x, float y, float radius, float damage){",
            "damage_overload_dispatch": "damage(null, x, y, radius, damage, false);",
            "tilesize_field": "public static final int tilesize = 8;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_effect_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_effect_sound_source"))
        report = source_parity.verify_power_generator_create_explosion_effect_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertIn("core/src/mindustry/entities/Effect.java", report["sources"])
        self.assertIn("arc-core/src/arc/audio/Sound.java", report["sources"])
        self.assertEqual(report["checked"], {
            "effect_field": "public Effect explodeEffect = Fx.none;",
            "sound_field": "public Sound explodeSound = Sounds.none;",
            "method": "public void createExplosion(){",
            "gate": "if(shouldExplode()){",
            "effect_dispatch": "explodeEffect.at(this);",
            "sound_dispatch": "explodeSound.at(this);",
            "effect_position_overload": "public void at(Position pos){",
            "effect_position_dispatch": "create(pos.getX(), pos.getY(), 0, Color.white, null);",
            "sound_position_overload": "public int at(Position pos){",
            "sound_position_dispatch": "return at(pos.getX(), pos.getY());",
            "sound_xy_dispatch": "return at(x, y, 1f);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_puddle_loop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_puddle_loop_source"))
        report = source_parity.verify_power_generator_create_explosion_puddle_loop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["checked"], {
            "puddles_field": "public int explosionPuddles = 10;",
            "puddle_liquid_field": "public @Nullable Liquid explosionPuddleLiquid;",
            "method": "public void createExplosion(){",
            "gate": "if(shouldExplode()){",
            "puddle_guard": "if(explosionPuddleLiquid != null){",
            "puddle_loop": "for(int i = 0; i < explosionPuddles; i++){",
            "random_vector": "Tmp.v1.trns(Mathf.random(360f), Mathf.random(explosionPuddleRange));",
            "tile_world": "Tile tile = world.tileWorld(x + Tmp.v1.x, y + Tmp.v1.y);",
            "deposit": "Puddles.deposit(tile, explosionPuddleLiquid, explosionPuddleAmount);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_puddle_vector_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_puddle_vector_source"))
        report = source_parity.verify_power_generator_create_explosion_puddle_vector_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["sources"], [
            "arc-core/src/arc/math/Mathf.java",
            "arc-core/src/arc/math/geom/Vec2.java",
        ])
        self.assertEqual(report["checked"], {
            "puddle_range_field": "public float explosionPuddleRange = tilesize * 2f;",
            "puddle_loop": "for(int i = 0; i < explosionPuddles; i++){",
            "random_vector": "Tmp.v1.trns(Mathf.random(360f), Mathf.random(explosionPuddleRange));",
            "mathf_random_float_method": "public static float random(float range){",
            "mathf_random_float_return": "return rand.nextFloat() * range;",
            "vec2_trns_method": "public Vec2 trns(float angle, float amount){",
            "vec2_trns_return": "return set(amount, 0).rotate(angle);",
            "vec2_rotate_method": "public Vec2 rotate(float degrees){",
            "vec2_rotate_return": "return rotateRad(degrees * Mathf.degreesToRadians);",
            "vec2_rotate_rad_method": "public Vec2 rotateRad(float radians){",
            "vec2_rotate_rad_new_x": "float newX = this.x * cos - this.y * sin;",
            "vec2_rotate_rad_new_y": "float newY = this.x * sin + this.y * cos;",
            "tile_world": "Tile tile = world.tileWorld(x + Tmp.v1.x, y + Tmp.v1.y);",
            "deposit": "Puddles.deposit(tile, explosionPuddleLiquid, explosionPuddleAmount);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_puddle_tile_world_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_puddle_tile_world_source"))
        report = source_parity.verify_power_generator_create_explosion_puddle_tile_world_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["sources"], [
            "core/src/mindustry/core/World.java",
            "core/src/mindustry/Vars.java",
        ])
        self.assertEqual(report["checked"], {
            "tile_assignment": "Tile tile = world.tileWorld(x + Tmp.v1.x, y + Tmp.v1.y);",
            "deposit": "Puddles.deposit(tile, explosionPuddleLiquid, explosionPuddleAmount);",
            "world_tile_world_method": "public @Nullable Tile tileWorld(float x, float y){",
            "world_tile_world_return": "return tile(Math.round(x / tilesize), Math.round(y / tilesize));",
            "world_tile_method": "public Tile tile(int x, int y){",
            "world_tile_return": "return tiles.get(x, y);",
            "world_to_tile_method": "public static int toTile(float coord){",
            "world_to_tile_return": "return Math.round(coord / tilesize);",
            "tilesize_field": "public static final int tilesize = 8;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_puddle_deposit_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_puddle_deposit_source"))
        report = source_parity.verify_power_generator_create_explosion_puddle_deposit_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["sources"], [
            "core/src/mindustry/entities/Puddles.java",
        ])
        self.assertEqual(report["checked"], {
            "puddle_amount_field": "public float explosionPuddleAmount = 100f;",
            "deposit_call": "Puddles.deposit(tile, explosionPuddleLiquid, explosionPuddleAmount);",
            "puddles_deposit_tile_method": "public static void deposit(Tile tile, Liquid liquid, float amount){",
            "puddles_deposit_tile_dispatch": "deposit(tile, tile, liquid, amount, true);",
            "puddles_deposit_initial_method": "public static void deposit(Tile tile, Tile source, Liquid liquid, float amount, boolean initial){",
            "puddles_deposit_initial_dispatch": "deposit(tile, source, liquid, amount, initial, false);",
            "puddles_deposit_full_method": "public static void deposit(Tile tile, Tile source, Liquid liquid, float amount, boolean initial, boolean cap){",
            "puddles_null_guard": "if(tile == null) return;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_create_explosion_shake_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_create_explosion_shake_source"))
        report = source_parity.verify_power_generator_create_explosion_shake_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["sources"], [
            "core/src/mindustry/entities/Effect.java",
            "arc-core/src/arc/math/geom/Position.java",
        ])
        self.assertEqual(report["checked"], {
            "shake_fields": "public float explosionShake = 0f, explosionShakeDuration = 6f;",
            "method": "public void createExplosion(){",
            "gate": "if(shouldExplode()){",
            "shake_guard": "if(explosionShake > 0){",
            "shake_call": "Effect.shake(explosionShake, explosionShakeDuration, this);",
            "effect_shake_position_method": "public static void shake(float intensity, float duration, Position loc){",
            "effect_shake_position_dispatch": "shake(intensity, duration, loc.getX(), loc.getY());",
            "position_get_x": "float getX();",
            "position_get_y": "float getY();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_generator_on_destroyed_reactor_explosion_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_generator_on_destroyed_reactor_explosion_source"))
        report = source_parity.verify_power_generator_on_destroyed_reactor_explosion_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGenerator.java")
        self.assertEqual(report["sources"], [
            "core/src/mindustry/game/Rules.java",
        ])
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void onDestroyed(){",
            "super_call": "super.onDestroyed();",
            "reactor_explosions_field": "public boolean reactorExplosions = true;",
            "reactor_explosions_guard": "if(state.rules.reactorExplosions){",
            "create_explosion_call": "createExplosion();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_add_roles_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_add_roles_source"))
        report = source_parity.verify_power_graph_add_roles_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["missing"], [])
        self.assertEqual(report["checked"], {
            "role_lists": [
                "public final Seq<Building> producers = new Seq<>(false, 16, Building.class);",
                "public final Seq<Building> consumers = new Seq<>(false, 16, Building.class);",
                "public final Seq<Building> batteries = new Seq<>(false, 16, Building.class);",
                "public final Seq<Building> all = new Seq<>(false, 16, Building.class);",
            ],
            "power_guard": "if(build == null || build.power == null) return;",
            "add_gate": "if(build.power.graph != this || !build.power.init){",
            "all_add": "all.add(build);",
            "producer_consumer_branch": "if(build.block.outputsPower && build.block.consumesPower && !build.block.consPower.buffered){",
            "battery_branch": "}else if(build.block.outputsPower && build.block.consumesPower){",
            "producer_branch": "}else if(build.block.outputsPower){",
            "consumer_branch": "}else if(build.block.consumesPower && build.block.consPower != null){",
        })

    def test_power_graph_power_needed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_power_needed_source"))
        report = source_parity.verify_power_graph_power_needed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertIn("core/src/mindustry/world/consumers/ConsumePower.java", report["sources"])
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertEqual(report["checked"], {
            "power_needed_method": "public float getPowerNeeded(){",
            "power_needed_initial": "float powerNeeded = 0f;",
            "power_needed_items": "var items = consumers.items;",
            "power_needed_loop": "for(int i = 0; i < consumers.size; i++){",
            "power_needed_consumer": "var consumer = items[i];",
            "power_needed_consume_power": "var consumePower = consumer.block.consPower;",
            "power_needed_guard": "if(consumer.shouldConsumePower){",
            "power_needed_add": "powerNeeded += consumePower.requestedPower(consumer) * consumer.delta();",
            "power_needed_return": "return powerNeeded;",
            "requested_power_method": "public float requestedPower(Building entity){",
            "requested_power_buffered": "(1f - entity.power.status) * capacity",
            "requested_power_unbuffered": "usage * (entity.shouldConsume() ? 1f : 0f)",
            "should_consume_default": "return enabled;",
            "delta_return": "return Time.delta * timeScale;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_power_produced_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_power_produced_source"))
        report = source_parity.verify_power_graph_power_produced_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertIn("core/src/mindustry/entities/comp/BuildingComp.java", report["sources"])
        self.assertEqual(report["checked"], {
            "power_produced_method": "public float getPowerProduced(){",
            "power_produced_initial": "float powerProduced = 0f;",
            "power_produced_items": "var items = producers.items;",
            "power_produced_loop": "for(int i = 0; i < producers.size; i++){",
            "power_produced_producer": "var producer = items[i];",
            "power_produced_add": "powerProduced += producer.getPowerProduction() * producer.delta();",
            "power_produced_return": "return powerProduced;",
            "building_power_production_method": "public float getPowerProduction(){",
            "building_power_production_default": "return 0f;",
            "delta_return": "return Time.delta * timeScale;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_battery_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_battery_state_source"))
        report = source_parity.verify_power_graph_battery_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "battery_stored_method": "public float getBatteryStored(){",
            "battery_stored_initial": "float totalAccumulator = 0f;",
            "battery_capacity_method": "public float getBatteryCapacity(){",
            "battery_capacity_initial": "float totalCapacity = 0f;",
            "battery_total_capacity_method": "public float getTotalBatteryCapacity(){",
            "battery_items": "var items = batteries.items;",
            "battery_loop": "for(int i = 0; i < batteries.size; i++){",
            "battery_building": "var battery = items[i];",
            "battery_enabled_guard": "if(battery.enabled){",
            "battery_stored_add": "totalAccumulator += battery.power.status * battery.block.consPower.capacity;",
            "battery_capacity_add": "totalCapacity += (1f - battery.power.status) * battery.block.consPower.capacity;",
            "battery_total_capacity_add": "totalCapacity += battery.block.consPower.capacity;",
            "battery_stored_return": "return totalAccumulator;",
            "battery_capacity_return": "return totalCapacity;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_use_batteries_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_use_batteries_source"))
        report = source_parity.verify_power_graph_use_batteries_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "use_batteries_method": "public float useBatteries(float needed){",
            "stored": "float stored = getBatteryStored();",
            "stored_zero_guard": "if(Mathf.equal(stored, 0f)) return 0f;",
            "used": "float used = Math.min(stored, needed);",
            "consumed_percent": "float consumedPowerPercentage = Math.min(1.0f, needed / stored);",
            "items": "var items = batteries.items;",
            "loop": "for(int i = 0; i < batteries.size; i++){",
            "battery": "var battery = items[i];",
            "enabled_guard": "if(battery.enabled){",
            "status_mul": "battery.power.status *= (1f-consumedPowerPercentage);",
            "return_used": "return used;",
            "mathf_equal": "public static boolean equal(float a, float b){",
            "mathf_equal_body": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_charge_batteries_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_charge_batteries_source"))
        report = source_parity.verify_power_graph_charge_batteries_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "charge_batteries_method": "public float chargeBatteries(float excess){",
            "capacity": "float capacity = getBatteryCapacity();",
            "charged_percent_comment": "//how much of the missing in each battery % is charged",
            "charged_percent": "float chargedPercent = Math.min(excess/capacity, 1f);",
            "capacity_zero_guard": "if(Mathf.equal(capacity, 0f)) return 0f;",
            "items": "var items = batteries.items;",
            "loop": "for(int i = 0; i < batteries.size; i++){",
            "battery": "var battery = items[i];",
            "todo": "//TODO why would it be 0",
            "enabled_capacity_guard": "if(battery.enabled && battery.block.consPower.capacity > 0f){",
            "status_add": "battery.power.status += (1f - battery.power.status) * chargedPercent;",
            "return_min": "return Math.min(excess, capacity);",
            "mathf_equal": "public static boolean equal(float a, float b){",
            "mathf_equal_body": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_distribute_power_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_distribute_power_source"))
        report = source_parity.verify_power_graph_distribute_power_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "distribute_power_method": "public void distributePower(float needed, float produced, boolean charged){",
            "coverage": "float coverage = Mathf.zero(needed) && Mathf.zero(produced) && !charged && Mathf.zero(lastPowerStored) ? 0f : Mathf.zero(needed) ? 1f : Math.min(1, produced / needed);",
            "items": "var items = consumers.items;",
            "loop": "for(int i = 0; i < consumers.size; i++){",
            "consumer": "var consumer = items[i];",
            "cons": "var cons = consumer.block.consPower;",
            "buffered_gate": "if(cons.buffered){",
            "capacity_zero_guard": "if(!Mathf.zero(cons.capacity)){",
            "maximum_rate": "float maximumRate = cons.requestedPower(consumer) * coverage * consumer.delta();",
            "buffered_status_clamp": "consumer.power.status = Mathf.clamp(consumer.power.status + maximumRate / cons.capacity);",
            "unbuffered_gate": "if(consumer.shouldConsumePower){",
            "unbuffered_coverage_status": "consumer.power.status = coverage;",
            "unbuffered_estimate_status": "consumer.power.status = Math.min(1, produced / (needed + cons.usage * consumer.delta()));",
            "nan_guard": "if(Float.isNaN(consumer.power.status)){",
            "nan_status_zero": "consumer.power.status = 0f;",
            "mathf_zero": "public static boolean zero(float value){",
            "mathf_zero_body": "return Math.abs(value) <= FLOAT_ROUNDING_ERROR;",
            "mathf_clamp": "public static float clamp(float value){",
            "mathf_clamp_body": "return Math.max(Math.min(value, 1f), 0f);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_update_cheat_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_update_cheat_source"))
        report = source_parity.verify_power_graph_update_cheat_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "update_method": "public void update(){",
            "cheat_gate": "if(!consumers.isEmpty() && consumers.first().cheating()){",
            "cheat_comment": "//when cheating, just set status to 1",
            "loop": "for(Building tile : consumers){",
            "status_one": "tile.power.status = 1f;",
            "last_power_assign": "lastPowerNeeded = lastPowerProduced = 1f;",
            "return": "return;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_update_balance_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_update_balance_source"))
        report = source_parity.verify_power_graph_update_balance_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "update_method": "public void update(){",
            "power_needed": "float powerNeeded = getPowerNeeded();",
            "power_produced": "float powerProduced = getPowerProduced();",
            "last_power_needed": "lastPowerNeeded = powerNeeded;",
            "last_power_produced": "lastPowerProduced = powerProduced;",
            "last_scaled_power_in": "lastScaledPowerIn = (powerProduced + energyDelta) / Time.delta;",
            "last_scaled_power_out": "lastScaledPowerOut = powerNeeded / Time.delta;",
            "last_capacity": "lastCapacity = getTotalBatteryCapacity();",
            "last_power_stored": "lastPowerStored = getBatteryStored();",
            "power_balance": "powerBalance.add((lastPowerProduced - lastPowerNeeded + energyDelta) / Time.delta);",
            "energy_delta_zero": "energyDelta = 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_update_battery_distribute_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_update_battery_distribute_source"))
        report = source_parity.verify_power_graph_update_battery_distribute_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertIn("arc-core/src/arc/math/Mathf.java", report["sources"])
        self.assertEqual(report["checked"], {
            "nonempty_guard": "if(!(consumers.size == 0 && producers.size == 0 && batteries.size == 0)){",
            "charged_init": "boolean charged = false;",
            "unequal_guard": "if(!Mathf.equal(powerNeeded, powerProduced)){",
            "deficit_gate": "if(powerNeeded > powerProduced){",
            "power_battery_used": "float powerBatteryUsed = useBatteries(powerNeeded - powerProduced);",
            "power_produced_battery_add": "powerProduced += powerBatteryUsed;",
            "last_power_produced_battery_add": "lastPowerProduced += powerBatteryUsed;",
            "surplus_gate": "}else if(powerProduced > powerNeeded){",
            "charged_true": "charged = true;",
            "power_produced_charge_sub": "powerProduced -= chargeBatteries(powerProduced - powerNeeded);",
            "distribute_power": "distributePower(powerNeeded, powerProduced, charged);",
            "mathf_equal": "public static boolean equal(float a, float b){",
            "mathf_equal_body": "return Math.abs(a - b) <= FLOAT_ROUNDING_ERROR;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_add_graph_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_add_graph_source"))
        report = source_parity.verify_power_graph_add_graph_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "method": "public void addGraph(PowerGraph graph){",
            "self_guard": "if(graph == this) return;",
            "merge_comment": "//merge into other graph instead.",
            "larger_graph_guard": "if(graph.all.size > all.size){",
            "delegate_add_graph": "graph.addGraph(this);",
            "delegate_return": "return;",
            "remove_comment": "//other entity should be removed as the graph was merged",
            "remove_entity_guard": "if(graph.entity != null) graph.entity.remove();",
            "loop": "for(Building tile : graph.all){",
            "add_tile": "add(tile);",
            "check_add": "checkAdd();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_check_add_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_check_add_source"))
        report = source_parity.verify_power_graph_check_add_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "method": "public void checkAdd(){",
            "entity_add_guard": "if(entity != null) entity.add();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_clear_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_clear_source"))
        report = source_parity.verify_power_graph_clear_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "method": "public void clear(){",
            "all_clear": "all.clear();",
            "producers_clear": "producers.clear();",
            "consumers_clear": "consumers.clear();",
            "batteries_clear": "batteries.clear();",
            "nothing_left_comment": "//nothing left",
            "entity_remove_guard": "if(entity != null) entity.remove();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_reflow_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_reflow_source"))
        report = source_parity.verify_power_graph_reflow_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "method": "public void reflow(Building tile){",
            "queue_clear": "queue.clear();",
            "queue_add_tile": "queue.addLast(tile);",
            "closed_set_clear": "closedSet.clear();",
            "while_queue": "while(queue.size > 0){",
            "remove_first": "Building child = queue.removeFirst();",
            "add_child": "add(child);",
            "check_add": "checkAdd();",
            "connections_loop": "for(Building next : child.getPowerConnections(outArray2)){",
            "closed_set_add": "if(closedSet.add(next.pos())){",
            "queue_add_next": "queue.addLast(next);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_remove_list_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_remove_list_source"))
        report = source_parity.verify_power_graph_remove_list_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "comment": "Used for unit tests only.",
            "method": "public void removeList(Building build){",
            "all_remove": "all.remove(build);",
            "producers_remove": "producers.remove(build);",
            "consumers_remove": "consumers.remove(build);",
            "batteries_remove": "batteries.remove(build);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_remove_branch_seed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_remove_branch_seed_source"))
        report = source_parity.verify_power_graph_remove_branch_seed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "comment": "Note that this does not actually remove the building from the graph;",
            "method": "public void remove(Building tile){",
            "connections_comment": "//go through all the connections of this tile",
            "connections_loop": "for(Building other : tile.getPowerConnections(outArray1)){",
            "skip_comment": "//a graph has already been assigned to this tile from a previous call, skip it",
            "skip_guard": "if(other.power.graph != this) continue;",
            "create_comment": "//create graph for this branch",
            "graph_create": "PowerGraph graph = new PowerGraph();",
            "graph_check_add": "graph.checkAdd();",
            "graph_add_other": "graph.add(other);",
            "queue_comment": "//add to queue for BFS",
            "queue_clear": "queue.clear();",
            "queue_add_other": "queue.addLast(other);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_remove_branch_bfs_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_remove_branch_bfs_source"))
        report = source_parity.verify_power_graph_remove_branch_bfs_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "while_queue": "while(queue.size > 0){",
            "get_child_comment": "//get child from queue",
            "remove_first": "Building child = queue.removeFirst();",
            "add_child_comment": "//add it to the new branch graph",
            "graph_add_child": "graph.add(child);",
            "connections_comment": "//go through connections",
            "connections_loop": "for(Building next : child.getPowerConnections(outArray2)){",
            "branch_guard_comment": "//make sure it hasn't looped back, and that the new graph being assigned hasn't already been assigned",
            "skip_closed_comment": "//also skip closed tiles",
            "branch_guard": "if(next != tile && next.power.graph != graph){",
            "graph_add_next": "graph.add(next);",
            "queue_add_next": "queue.addLast(next);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_remove_branch_update_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_remove_branch_update_source"))
        report = source_parity.verify_power_graph_remove_branch_update_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "update_comment": "//update the graph once so direct consumers without any connected producer lose their power",
            "graph_update": "graph.update();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_remove_empty_entity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_remove_empty_entity_source"))
        report = source_parity.verify_power_graph_remove_empty_entity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "empty_graph_comment": "//implied empty graph here",
            "entity_remove_guard": "if(entity != null) entity.remove();",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_get_id_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_get_id_source"))
        report = source_parity.verify_power_graph_get_id_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "method": "public int getId(){",
            "return_graph_id": "return graphID;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_graph_to_string_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_graph_to_string_source"))
        report = source_parity.verify_power_graph_to_string_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/power/PowerGraph.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public String toString(){",
            "return_prefix": 'return "PowerGraph{" +',
            "producers": '"producers=" + producers +',
            "consumers": '", consumers=" + consumers +',
            "batteries": '", batteries=" + batteries +',
            "all": '", all=" + all +',
            "graph_id": '", graphID=" + graphID +',
            "return_close": "'}';",
        })
        self.assertEqual(report["missing"], [])

    def test_overdrive_projector_target_filter_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_overdrive_projector_target_filter_source"))
        report = source_parity.verify_overdrive_projector_target_filter_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/OverdriveProjector.java")
        self.assertEqual(report["checked"], {
            "predicate": "other.block.canOverdrive",
            "action": "other.applyBoost(realBoost(), reload + 1f)",
        })

    def test_building_time_scale_decay_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_time_scale_decay_source"))
        report = source_parity.verify_building_time_scale_decay_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "duration_decay": "if((timeScaleDuration -= Time.delta) <= 0f)",
            "reset": "timeScale = 1f;",
        })

    def test_building_delta_edelta_helpers_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_delta_edelta_source"))
        report = source_parity.verify_building_delta_edelta_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "delta": "return Time.delta * timeScale;",
            "edelta": "return efficiency * delta();",
        })

    def test_conveyor_update_uses_edelta_movement_source(self):
        self.assertTrue(hasattr(source_parity, "verify_conveyor_edelta_source"))
        report = source_parity.verify_conveyor_edelta_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/distribution/Conveyor.java")
        self.assertEqual(report["checked"], {
            "movement": "float moved = speed * edelta();",
        })

    def test_drill_update_uses_delta_progress_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_delta_source"))
        report = source_parity.verify_drill_delta_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "progress": "progress += delta() * dominantItems * speed * warmup;",
        })

    def test_unit_vec2_angle_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_vec2_angle_source"))
        report = source_parity.verify_unit_vec2_angle_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "rotate_move_guard": "if(!vec.isZero()){",
            "rotate_move_angle_call": "rotation = Angles.moveToward(rotation, vec.angle(), type.rotateSpeed * Time.delta * speedMultiplier);",
            "vec2_angle_method": "public float angle(){",
            "vec2_angle_expr": "float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees;",
            "vec2_angle_negative_wrap": "if(angle < 0) angle += 360;",
            "vec2_angle_return": "return angle;",
            "mathf_atan2_method": "public static float atan2(float x, final float y){",
            "mathf_radians_to_degrees": "public static final float radiansToDegrees = 180f / PI;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_weapon_damage_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_weapon_damage_source"))
        report = source_parity.verify_unit_weapon_damage_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["bullet_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["unit_types_source"], "core/src/mindustry/content/UnitTypes.java")
        self.assertEqual(report["checked"], {
            "unit_weapons_field": "public Seq<Weapon> weapons = new Seq<>();",
            "weapon_bullet_field": "public BulletType bullet = Bullets.placeholder;",
            "bullet_damage_field": "public float damage = 1f;",
            "bullet_constructor_damage": "this.damage = damage;",
            "dagger_weapon": "weapons.add(new Weapon(\"large-weapon\"){{",
            "dagger_bullet_damage": "bullet = new BasicBulletType(2.5f, 9){{",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_world_speed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_world_speed_source"))
        report = source_parity.verify_unit_world_speed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["unit_types_source"], "core/src/mindustry/content/UnitTypes.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["checked"], {
            "unit_speed_comment": "/** movement speed (world units/t) */",
            "unit_speed_field": "public float speed = 1.1f,",
            "set_stats_method": "public void setStats(){",
            "speed_stat": "stats.add(Stat.speed, speed * 60f / tilesize, StatUnit.tilesSecond);",
            "dagger_unit": "dagger = new UnitType(\"dagger\"){{",
            "dagger_speed": "speed = 0.5f;",
            "tilesize_comment": "/** size of tiles in units */",
            "tilesize_field": "public static final int tilesize = 8;",
        })
        self.assertEqual(report["missing"], [])

    def test_drill_warmup_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_warmup_source"))
        report = source_parity.verify_drill_warmup_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "warmup_default": "public float warmupSpeed = 0.015f;",
            "warmup_active": "warmup = Mathf.approachDelta(warmup, speed, warmupSpeed);",
            "warmup_inactive": "warmup = Mathf.approachDelta(warmup, 0f, warmupSpeed);",
        })

    def test_drill_time_drilled_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_time_drilled_source"))
        report = source_parity.verify_drill_time_drilled_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "time_drilled": "timeDrilled += warmup * delta();",
        })

    def test_drill_last_drill_speed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_last_speed_source"))
        report = source_parity.verify_drill_last_speed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "speed": "float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;",
            "last_speed_active": "lastDrillSpeed = (speed * dominantItems * warmup) / delay;",
            "last_speed_inactive": "lastDrillSpeed = 0f;",
        })

    def test_drill_item_capacity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_item_capacity_source"))
        report = source_parity.verify_drill_item_capacity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(report["checked"], {
            "block_item_capacity_default": "public int itemCapacity = 10;",
            "drill_has_items": "hasItems = true;",
        })

    def test_drill_output_batch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_output_batch_source"))
        report = source_parity.verify_drill_output_batch_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "output_gate": "if(dominantItems > 0 && progress >= delay && items.total() < itemCapacity){",
            "amount": "int amount = (int)(progress / delay);",
            "offload": "offload(dominantItem);",
            "progress_modulo": "progress %= delay;",
        })

    def test_drill_dump_timer_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_dump_timer_source"))
        report = source_parity.verify_drill_dump_timer_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "timer_dump": "protected final int timerDump = timers++;",
            "dump_time_default": "public int dumpTime = 5;",
            "dump_gate": "if(timer(timerDump, dumpTime / timeScale)){",
            "dump_call": "dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);",
        })

    def test_drill_progress_fraction_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_drill_progress_fraction_source"))
        report = source_parity.verify_drill_progress_fraction_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/production/Drill.java")
        self.assertEqual(report["checked"], {
            "progress_method": "public float progress(){",
            "progress_fraction": "return dominantItem == null ? 0f : Mathf.clamp(progress / getDrillTime(dominantItem));",
        })

    def test_building_offload_fallback_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_offload_inventory_fallback_source"))
        report = source_parity.verify_building_offload_inventory_fallback_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "offload_method": "public void offload(Item item){",
            "offload_produced": "produced(item, 1);",
            "offload_neighbor": "other.handleItem(self(), item);",
            "offload_fallback": "handleItem(self(), item);",
            "item_module_add": "items[item] += amount;",
        })

    def test_building_dump_removes_inventory_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_remove_source"))
        report = source_parity.verify_building_dump_remove_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "dump_method": "public boolean dump(Item todump){",
            "dump_guard": "if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;",
            "dump_neighbor": "other.handleItem(self(), todump);",
            "dump_remove": "items.remove(todump, 1);",
            "dump_success": "return true;",
        })

    def test_building_dump_accept_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_accept_source"))
        report = source_parity.verify_building_dump_accept_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["core_source"], "core/src/mindustry/world/blocks/storage/CoreBlock.java")
        self.assertEqual(report["checked"], {
            "dump_accept_guard": "if(other.acceptItem(self(), todump) && canDump(other, todump)){",
            "dump_neighbor": "other.handleItem(self(), todump);",
            "dump_remove": "items.remove(todump, 1);",
            "core_accept_item": "return state.rules.coreIncinerates || items.get(item) < getMaximumAccepted(item);",
            "core_maximum_accepted": "return state.rules.coreIncinerates ? Integer.MAX_VALUE/2 : storageCapacity;",
        })

    def test_core_handle_item_capacity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_core_handle_item_source"))
        report = source_parity.verify_core_handle_item_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/storage/CoreBlock.java")
        self.assertEqual(report["building_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "core_handle_method": "public void handleItem(Building source, Item item){",
            "core_full_gate": "if(items.get(item) >= storageCapacity || incinerate){",
            "core_handle_else": "}else{",
            "core_super_handle": "super.handleItem(source, item);",
            "building_handle_add": "items.add(item, 1);",
        })

    def test_building_dump_cursor_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_cursor_source"))
        report = source_parity.verify_building_dump_cursor_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "cursor_field": "transient int cdump;",
            "cursor_snapshot": "int dump = this.cdump;",
            "cursor_index": "Building other = proximity.get((i + dump) % proximity.size);",
            "increment_call": "incrementDump(proximity.size);",
            "increment_method": "public void incrementDump(int prox){",
            "increment_guard": "if(prox != 0){",
            "increment_modulo": "cdump = ((cdump + 1) % prox);",
        })

    def test_building_dump_accumulate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_accumulate_source"))
        report = source_parity.verify_building_dump_accumulate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "accum_field": "private transient float dumpAccum;",
            "accum_no_arg": "public boolean dumpAccumulate(){",
            "accum_no_arg_call": "return dumpAccumulate(null);",
            "accum_method": "public boolean dumpAccumulate(Item item){",
            "accum_result": "boolean res = false;",
            "accum_add_delta": "dumpAccum += delta();",
            "accum_loop": "while(dumpAccum >= 1f){",
            "accum_dump": "res |= dump(item);",
            "accum_subtract": "dumpAccum -=1f;",
            "accum_return": "return res;",
        })

    def test_building_move_forward_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_forward_source"))
        report = source_parity.verify_building_move_forward_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "move_method": "public boolean moveForward(Item item){",
            "front_lookup": "Building other = front();",
            "move_guard": "if(other != null && other.team == team && other.acceptItem(self(), item)){",
            "move_handle": "other.handleItem(self(), item);",
            "move_success": "return true;",
            "move_failure": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_handle_accept_item_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_handle_accept_item_source"))
        report = source_parity.verify_building_handle_accept_item_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "handle_method": "public void handleItem(Building source, Item item){",
            "handle_add": "items.add(item, 1);",
            "accept_method": "public boolean acceptItem(Building source, Item item){",
            "accept_guard": "return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_handle_accept_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_handle_accept_liquid_source"))
        report = source_parity.verify_building_handle_accept_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "accept_method": "public boolean acceptLiquid(Building source, Liquid liquid){",
            "accept_guard": "return block.hasLiquids && block.consumesLiquid(liquid);",
            "handle_method": "public void handleLiquid(Building source, Liquid liquid, float amount){",
            "handle_add": "liquids.add(liquid, amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_liquid_default_scaling_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_liquid_default_scaling_source"))
        report = source_parity.verify_building_dump_liquid_default_scaling_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method_default": "public void dumpLiquid(Liquid liquid){",
            "default_scaling_call": "dumpLiquid(liquid, 2f);",
            "method_scaling": "public void dumpLiquid(Liquid liquid, float scaling){",
            "output_dir_call": "dumpLiquid(liquid, scaling, -1);",
            "method_output_dir": "public void dumpLiquid(Liquid liquid, float scaling, int outputDir){",
            "dump_cursor_assignment": "int dump = this.cdump;",
            "empty_liquid_return": "if(liquids.get(liquid) <= 0.0001f) return;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_liquid_campaign_unlock_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_liquid_campaign_unlock_source"))
        report = source_parity.verify_building_dump_liquid_campaign_unlock_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method_output_dir": "public void dumpLiquid(Liquid liquid, float scaling, int outputDir){",
            "empty_liquid_return": "if(liquids.get(liquid) <= 0.0001f) return;",
            "campaign_unlock_guard": "if(!net.client() && state.isCampaign() && team == state.rules.defaultTeam) liquid.unlock();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_liquid_routing_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_liquid_routing_gate_source"))
        report = source_parity.verify_building_dump_liquid_routing_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "loop": "for(int i = 0; i < proximity.size; i++){",
            "increment_dump_call": "incrementDump(proximity.size);",
            "proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
            "output_dir_filter": "if(outputDir != -1 && (outputDir + rotation) % 4 != relativeTo(other)) continue;",
            "destination_call": "other = other.getLiquidDestination(self(), liquid);",
            "eligibility_guard": "if(other != null && other.block.hasLiquids && canDumpLiquid(other, liquid) && other.liquids != null){",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_liquid_fraction_transfer_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_liquid_fraction_transfer_source"))
        report = source_parity.verify_building_dump_liquid_fraction_transfer_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "ofract": "float ofract = other.liquids.get(liquid) / other.block.liquidCapacity;",
            "fract": "float fract = liquids.get(liquid) / block.liquidCapacity;",
            "transfer_guard": "if(ofract < fract) transferLiquid(other, (fract - ofract) * block.liquidCapacity / scaling, liquid);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_transfer_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_transfer_liquid_source"))
        report = source_parity.verify_building_transfer_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void transferLiquid(Building next, float amount, Liquid liquid){",
            "flow": "float flow = Math.min(next.block.liquidCapacity - next.liquids.get(liquid), amount);",
            "accept_guard": "if(next.acceptLiquid(self(), liquid)){",
            "handle_liquid_call": "next.handleLiquid(self(), liquid, flow);",
            "remove_liquid_call": "liquids.remove(liquid, flow);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_can_dump_liquid_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_can_dump_liquid_default_source"))
        report = source_parity.verify_building_can_dump_liquid_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public boolean canDumpLiquid(Building to, Liquid liquid){",
            "return_true": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_can_dump_item_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_can_dump_item_default_source"))
        report = source_parity.verify_building_can_dump_item_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public boolean canDump(Building to, Item item){",
            "return_true": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_proximity_removed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_proximity_removed_source"))
        report = source_parity.verify_building_on_proximity_removed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Called shortly before this building is removed. */",
            "method": "public void onProximityRemoved(){",
            "power_guard": "if(power != null){",
            "power_graph_removed_call": "powerGraphRemoved();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_proximity_added_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_proximity_added_source"))
        report = source_parity.verify_building_on_proximity_added_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Called after this building is created in the world. May be called multiple times, or when adjacent buildings change. */",
            "todo": "//TODO ??? this is just onProximityUpdate ?",
            "method": "public void onProximityAdded(){",
            "power_guard": "if(power != null){",
            "update_power_graph_call": "updatePowerGraph();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_proximity_update_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_proximity_update_source"))
        report = source_parity.verify_building_on_proximity_update_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Called when anything adjacent to this building is placed/removed, including itself. */",
            "method": "public void onProximityUpdate(){",
            "no_sleep_call": "noSleep();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_update_power_graph_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_power_graph_source"))
        report = source_parity.verify_building_update_power_graph_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void updatePowerGraph(){",
            "connection_loop": "for(Building other : getPowerConnections(tempBuilds)){",
            "power_guard": "if(other.power != null){",
            "add_graph_call": "other.power.graph.addGraph(power.graph);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_conducts_to_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_conducts_to_source"))
        report = source_parity.verify_building_conducts_to_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public boolean conductsTo(Building other){",
            "return_not_insulated": "return !block.insulated;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_power_connections_empty_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_power_connections_empty_guard_source"))
        report = source_parity.verify_building_get_power_connections_empty_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public Seq<Building> getPowerConnections(Seq<Building> out){",
            "clear_out": "out.clear();",
            "power_null_guard": "if(power == null) return out;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_power_connections_proximity_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_power_connections_proximity_guard_source"))
        report = source_parity.verify_building_get_power_connections_proximity_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "proximity_loop": "for(Building other : proximity){",
            "other_power_guard": "if(other != null && other.power != null",
            "same_team_guard": "&& other.team == team",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_power_connections_power_compatibility_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_power_connections_power_compatibility_guard_source"))
        report = source_parity.verify_building_get_power_connections_power_compatibility_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "power_compatibility_guard": "&& !(block.consumesPower && other.block.consumesPower && !block.outputsPower && !other.block.outputsPower && !block.conductivePower && !other.block.conductivePower)",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_power_connections_conducts_link_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_power_connections_conducts_link_guard_source"))
        report = source_parity.verify_building_get_power_connections_conducts_link_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "conducts_to_other_guard": "&& conductsTo(other)",
            "other_conducts_to_self_guard": "&& other.conductsTo(self())",
            "duplicate_link_guard": "&& !power.links.contains(other.pos())){",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_power_connections_automatic_add_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_power_connections_automatic_add_source"))
        report = source_parity.verify_building_get_power_connections_automatic_add_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "out_add_other": "out.add(other);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_power_connections_manual_links_loop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_power_connections_manual_links_loop_source"))
        report = source_parity.verify_building_get_power_connections_manual_links_loop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "manual_links_loop": "for(int i = 0; i < power.links.size; i++){",
            "manual_link_tile_lookup": "Tile link = world.tile(power.links.get(i));",
            "manual_link_add_guard": "if(link != null && link.build != null && link.build.power != null && link.build.team == team) out.add(link.build);",
            "return_out": "return out;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_liquid_forward_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_liquid_forward_source"))
        report = source_parity.verify_building_move_liquid_forward_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public float moveLiquidForward(boolean leaks, Liquid liquid){",
            "nearby_lookup": "Tile next = tile.nearby(rotation);",
            "null_return": "if(next == null) return 0;",
            "move_liquid_call": "return moveLiquid(next.build, liquid);",
            "leak_guard": "}else if(leaks && !next.block().solid && !next.block().hasLiquids){",
            "leak_amount": "float leakAmount = liquids.get(liquid) / 1.5f;",
            "puddles_deposit_call": "Puddles.deposit(next, tile, liquid, leakAmount, true, true);",
            "remove_liquid_call": "liquids.remove(liquid, leakAmount);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_liquid_source"))
        report = source_parity.verify_building_move_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public float moveLiquid(Building next, Liquid liquid){",
            "null_return": "if(next == null) return 0;",
            "get_liquid_destination_call": "next = next.getLiquidDestination(self(), liquid);",
            "main_guard": "if(next.team == team && next.block.hasLiquids && liquids.get(liquid) > 0f){",
            "ofract": "float ofract = next.liquids.get(liquid) / next.block.liquidCapacity;",
            "fract": "float fract = liquids.get(liquid) / block.liquidCapacity * block.liquidPressure;",
            "flow_initial": "float flow = Math.min(Mathf.clamp((fract - ofract)) * (block.liquidCapacity), liquids.get(liquid));",
            "flow_capacity_clamp": "flow = Math.min(flow, next.block.liquidCapacity - next.liquids.get(liquid));",
            "transfer_guard": "if(flow > 0f && ofract <= fract && next.acceptLiquid(self(), liquid)){",
            "handle_liquid_call": "next.handleLiquid(self(), liquid, flow);",
            "remove_liquid_call": "liquids.remove(liquid, flow);",
            "return_flow": "return flow;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_liquid_reaction_setup_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_liquid_reaction_setup_source"))
        report = source_parity.verify_building_move_liquid_reaction_setup_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "reaction_guard": "}else if(!next.block.consumesLiquid(liquid) && next.liquids.currentAmount() / next.block.liquidCapacity > 0.1f && fract > 0.1f){",
            "effect_position": "float fx = (x + next.x) / 2f, fy = (y + next.y) / 2f;",
            "current_liquid": "Liquid other = next.liquids.current();",
            "block_reactive_guard": "if(other.blockReactive && liquid.blockReactive){",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_liquid_fire_reaction_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_liquid_fire_reaction_source"))
        report = source_parity.verify_building_move_liquid_fire_reaction_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "fire_reaction_guard": "if((other.flammability > 0.3f && liquid.temperature > 0.7f) || (liquid.flammability > 0.3f && other.temperature > 0.7f)){",
            "self_damage_call": "damageContinuous(1);",
            "next_damage_call": "next.damageContinuous(1);",
            "fire_chance_guard": "if(Mathf.chanceDelta(0.1)){",
            "fire_effect_call": "Fx.fire.at(fx, fy);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_liquid_steam_reaction_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_liquid_steam_reaction_source"))
        report = source_parity.verify_building_move_liquid_steam_reaction_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "steam_reaction_guard": "}else if((liquid.temperature > 0.7f && other.temperature < 0.55f) || (other.temperature > 0.7f && liquid.temperature < 0.55f)){",
            "remove_liquid_call": "liquids.remove(liquid, Math.min(liquids.get(liquid), 0.7f * Time.delta));",
            "steam_chance_guard": "if(Mathf.chanceDelta(0.2f)){",
            "steam_effect_call": "Fx.steam.at(fx, fy);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_liquid_return_zero_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_liquid_return_zero_source"))
        report = source_parity.verify_building_move_liquid_return_zero_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "final_return": "return 0;",
            "next_method": "public Building getLiquidDestination(Building from, Liquid liquid){",
            "anchored_block": "return 0;\n    }\n\n    public Building getLiquidDestination(Building from, Liquid liquid){",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_liquid_destination_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_liquid_destination_default_source"))
        report = source_parity.verify_building_get_liquid_destination_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public Building getLiquidDestination(Building from, Liquid liquid){",
            "return_self": "return self();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_payload_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_payload_default_source"))
        report = source_parity.verify_building_get_payload_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public @Nullable Payload getPayload(){",
            "return_null": "return null;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_take_payload_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_take_payload_default_source"))
        report = source_parity.verify_building_take_payload_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Tries to take the payload. Returns null if no payload is present. */",
            "method": "public @Nullable Payload takePayload(){",
            "return_null": "return null;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_get_payloads_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_get_payloads_default_source"))
        report = source_parity.verify_building_get_payloads_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public @Nullable PayloadSeq getPayloads(){",
            "return_null": "return null;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_put_item_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_put_item_source"))
        report = source_parity.verify_building_put_item_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": " * Tries to put this item into a nearby container. Returns success. Unlike #offload(), this method does not change the block inventory.",
            "method": "public boolean put(Item item){",
            "dump_assign": "int dump = this.cdump;",
            "loop": "for(int i = 0; i < proximity.size; i++){",
            "increment_dump": "incrementDump(proximity.size);",
            "proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
            "accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
            "handle_item": "other.handleItem(self(), item);",
            "return_true": "return true;",
            "return_false": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_produced_item_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_produced_item_default_source"))
        report = source_parity.verify_building_produced_item_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void produced(Item item){",
            "delegate": "produced(item, 1);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_produced_item_amount_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_produced_item_amount_source"))
        report = source_parity.verify_building_produced_item_amount_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void produced(Item item, int amount){",
            "production_guard": "if(Vars.state.rules.sector != null && team == state.rules.defaultTeam){",
            "handle_production": "Vars.state.rules.sector.info.handleProduction(item, amount);",
            "unlock_guard": "if(!net.client()) item.unlock();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_accumulate_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_accumulate_default_source"))
        report = source_parity.verify_building_dump_accumulate_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Dumps any item with an accumulator. May dump multiple times per frame. Use with care. */",
            "method": "public boolean dumpAccumulate(){",
            "delegate": "return dumpAccumulate(null);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_default_source"))
        report = source_parity.verify_building_dump_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Try dumping any item near the building. */",
            "method": "public boolean dump(){",
            "delegate": "return dump(null);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_null_item_scan_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_null_item_scan_source"))
        report = source_parity.verify_building_dump_null_item_scan_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public boolean dump(Item todump){",
            "all_items": "var allItems = content.items();",
            "item_size": "int itemSize = allItems.size;",
            "item_array": "Object[] itemArray = allItems.items;",
            "null_branch": "if(todump == null){",
            "item_loop": "for(int ii = 0; ii < itemSize; ii++){",
            "has_item_skip": "if(!items.has(ii)) continue;",
            "item_cast": "Item item = (Item)itemArray[ii];",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_null_proximity_scan_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_null_proximity_scan_source"))
        report = source_parity.verify_building_dump_null_proximity_scan_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public boolean dump(Item todump){",
            "dump_assign": "int dump = this.cdump;",
            "null_branch": "if(todump == null){",
            "proximity_loop": "for(int i = 0; i < proximity.size; i++){",
            "proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
            "increment_dump_call": "incrementDump(proximity.size);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_null_remove_item_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_null_remove_item_source"))
        report = source_parity.verify_building_dump_null_remove_item_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "null_branch": "if(todump == null){",
            "accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
            "remove_item_call": "items.remove(item, 1);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_null_success_handoff_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_null_success_handoff_source"))
        report = source_parity.verify_building_dump_null_success_handoff_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "null_branch": "if(todump == null){",
            "accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
            "handle_item_call": "other.handleItem(self(), item);",
            "return_true": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_specific_proximity_scan_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_specific_proximity_scan_source"))
        report = source_parity.verify_building_dump_specific_proximity_scan_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "else_branch": "}else{",
            "proximity_loop": "for(int i = 0; i < proximity.size; i++){",
            "proximity_get": "Building other = proximity.get((i + dump) % proximity.size);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_terminal_failure_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_terminal_failure_source"))
        report = source_parity.verify_building_dump_terminal_failure_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "method": "public boolean dump(Item todump){",
            "terminal_segment": "}\n\n        return false;\n    }",
            "terminal_return": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_maximum_accepted_and_handle_stack_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_maximum_accepted_stack_source"))
        report = source_parity.verify_building_maximum_accepted_stack_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "maximum_method": "public int getMaximumAccepted(Item item){",
            "maximum_return": "return block.itemCapacity;",
            "stack_method": "public void handleStack(Item item, int amount, @Nullable Teamc source){",
            "stack_no_sleep": "noSleep();",
            "stack_add": "items.add(item, amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_accept_stack_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_accept_stack_source"))
        report = source_parity.verify_building_accept_stack_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "accept_stack_method": "public int acceptStack(Item item, int amount, Teamc source){",
            "accept_stack_guard": "if(acceptItem(self(), item) && block.hasItems && (source == null || source.team() == team)){",
            "accept_stack_amount": "return Math.min(getMaximumAccepted(item) - items.get(item), amount);",
            "accept_stack_failure": "return 0;",
        })
        self.assertEqual(report["missing"], [])


    def test_building_remove_stack_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_remove_stack_source"))
        report = source_parity.verify_building_remove_stack_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "remove_stack_method": "public int removeStack(Item item, int amount){",
            "remove_stack_null_guard": "if(items == null) return 0;",
            "remove_stack_clamp": "amount = Math.min(amount, items.get(item));",
            "remove_stack_no_sleep": "noSleep();",
            "remove_stack_remove": "items.remove(item, amount);",
            "remove_stack_return": "return amount;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_payload_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_payload_default_source"))
        report = source_parity.verify_building_payload_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "accept_payload_method": "public boolean acceptPayload(Building source, Payload payload){",
            "accept_payload_return": "return false;",
            "handle_payload_method": "public void handlePayload(Building source, Payload payload){",
            "handle_payload_empty_body": "public void handlePayload(Building source, Payload payload){\n\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_move_payload_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_move_payload_source"))
        report = source_parity.verify_building_move_payload_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "move_payload_method": "public boolean movePayload(Payload todump){",
            "move_payload_offset": "int trns = block.size/2 + 1;",
            "move_payload_next": "Tile next = tile.nearby(Geometry.d4(rotation).x * trns, Geometry.d4(rotation).y * trns);",
            "move_payload_guard": "if(next != null && next.build != null && next.build.team == team && next.build.acceptPayload(self(), todump)){",
            "move_payload_handle": "next.build.handlePayload(self(), todump);",
            "move_payload_success": "return true;",
            "move_payload_failure": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_dump_payload_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_dump_payload_source"))
        report = source_parity.verify_building_dump_payload_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "dump_payload_method": "public boolean dumpPayload(Payload todump){",
            "dump_payload_empty_guard": "if(proximity.size == 0) return false;",
            "dump_payload_cursor_snapshot": "int dump = this.cdump;",
            "dump_payload_loop": "for(int i = 0; i < proximity.size; i++){",
            "dump_payload_index": "Building other = proximity.get((i + dump) % proximity.size);",
            "dump_payload_accept_guard": "if(other.acceptPayload(self(), todump)){",
            "dump_payload_handle": "other.handlePayload(self(), todump);",
            "dump_payload_increment": "incrementDump(proximity.size);",
            "dump_payload_success": "return true;",
            "dump_payload_failure": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_can_be_replaced_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_can_be_replaced_source"))
        report = source_parity.verify_building_can_be_replaced_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["block_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(report["checked"], {
            "building_can_be_replaced_method": "public boolean canBeReplaced(Block other){",
            "building_can_be_replaced_delegate": "return other.canReplace(block);",
            "block_can_replace_method": "public boolean canReplace(Block other){",
            "block_can_replace_always": "if(other.alwaysReplace) return true;",
            "block_can_replace_privileged": "if(other.privileged) return false;",
            "block_can_replace_replaceable": "return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) &&",
            "block_can_replace_size": "(size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));",
        })
        self.assertEqual(report["missing"], [])

    def test_building_default_activity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_default_activity_source"))
        report = source_parity.verify_building_default_activity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "should_consume_method": "public boolean shouldConsume(){",
            "should_consume_return": "return enabled;",
            "production_valid_method": "public boolean productionValid(){",
            "production_valid_return": "return true;",
            "consume_trigger_valid_method": "public boolean consumeTriggerValid(){",
            "consume_trigger_valid_return": "return false;",
            "power_production_method": "public float getPowerProduction(){",
            "power_production_return": "return 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_should_consume_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_should_consume_source"))
        report = source_parity.verify_building_should_consume_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "should_consume_method": "public boolean shouldConsume(){",
            "should_consume_return": "return enabled;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_progress_display_ambient_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_progress_display_ambient_source"))
        report = source_parity.verify_building_progress_display_ambient_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "progress_method": "public float getProgressIncrease(float baseTime){",
            "progress_return": "return 1f / baseTime * edelta();",
            "display_efficiency_method": "public float getDisplayEfficiency(){",
            "display_efficiency_return": "return getProgressIncrease(1f) / edelta();",
            "ambient_method": "public boolean shouldAmbientSound(){",
            "ambient_return": "return shouldConsume();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_status_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_status_source"))
        report = source_parity.verify_building_draw_status_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_status_method": "public void drawStatus(){",
            "draw_status_guard": "if(block.enableDrawStatus && block.consumers.length > 0){",
            "draw_status_multiplier": "float multiplier = block.size > 1 ? 1 : 0.64f;",
            "draw_status_brcx": "float brcx = x + (block.size * tilesize / 2f) - (tilesize * multiplier / 2f);",
            "draw_status_brcy": "float brcy = y - (block.size * tilesize / 2f) + (tilesize * multiplier / 2f);",
            "draw_status_gray_square": "Fill.square(brcx, brcy, 2.5f * multiplier, 45);",
            "draw_status_color_square": "Fill.square(brcx, brcy, 1.5f * multiplier, 45);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_cracks_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_cracks_source"))
        report = source_parity.verify_building_draw_cracks_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_cracks_method": "public void drawCracks(){",
            "draw_cracks_guard": "if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;",
            "draw_cracks_id": "int id = pos();",
            "draw_cracks_region": "TextureRegion region = renderer.blocks.cracks[block.size - 1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)];",
            "draw_cracks_color": "Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);",
            "draw_cracks_rotation": "Draw.rect(region, x, y, (id%4)*90);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_select_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_select_source"))
        report = source_parity.verify_building_draw_select_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_select_method": "public void drawSelect(){",
            "draw_select_overlay": "block.drawOverlay(x, y, rotation);",
            "draw_select_status_guard": "if(status() == BlockStatus.inactiveUnitFactory){",
            "draw_select_place_text": "block.drawPlaceText(Core.bundle.format(\"rules.unitfactoryactivation.objective\", UI.formatTime((float)Math.max(0f, state.rules.unitActivationDelay(team) - state.tick))), tile.x, tile.y, false);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_item_selection_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_item_selection_source"))
        report = source_parity.verify_building_draw_item_selection_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_item_selection_method": "public void drawItemSelection(@Nullable UnlockableContent selection){",
            "draw_item_selection_guard": "if(selection != null){",
            "draw_item_selection_geometry": "float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;",
            "draw_item_selection_shadow_mix": "Draw.mixcol(Color.darkGray, 1f);",
            "draw_item_selection_shadow_rect": "Draw.rect(selection.fullIcon, dx, dy - 1, s, h);",
            "draw_item_selection_reset": "Draw.reset();",
            "draw_item_selection_rect": "Draw.rect(selection.fullIcon, dx, dy, s, h);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_disabled_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_disabled_source"))
        report = source_parity.verify_building_draw_disabled_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_disabled_method": "public void drawDisabled(){",
            "draw_disabled_color": "Draw.color(Color.scarlet);",
            "draw_disabled_alpha": "Draw.alpha(0.8f);",
            "draw_disabled_size": "float size = 6f;",
            "draw_disabled_rect": "Draw.rect(Icon.cancel.getRegion(), x, y, size, size);",
            "draw_disabled_reset": "Draw.reset();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_drawrot_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_drawrot_source"))
        report = source_parity.verify_building_drawrot_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "drawrot_method": "public float drawrot(){",
            "drawrot_return": "return block.rotate && block.rotateDraw ? rotation * 90 : 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_source"))
        report = source_parity.verify_building_draw_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_rand_source"], "arc-core/src/arc/math/Rand.java")
        self.assertEqual(report["checked"], {
            "draw_method": "public void draw(){",
            "draw_region_guard": "if(block.variants == 0 || block.variantRegions == null){",
            "draw_region_rect": "Draw.rect(block.region, x, y, drawrot());",
            "draw_variant_rect": "Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());",
            "draw_team_top": "drawTeamTop();",
            "mathf_random_seed_int": "public static int randomSeed(long seed, int min, int max){",
            "mathf_random_seed_set_seed": "seedr.setSeed(seed);",
            "mathf_random_seed_power_two_skip": "if(isPowerOfTwo(max)){",
            "mathf_random_seed_return": "return seedr.nextInt(max - min + 1) + min;",
            "mathf_is_power_of_two": "return value != 0 && (value & value - 1) == 0;",
            "rand_murmur_method": "private static long murmurHash3(long x){",
            "rand_murmur_const1": "x *= 0xff51afd7ed558ccdL;",
            "rand_murmur_const2": "x *= 0xc4ceb9fe1a85ec53L;",
            "rand_next_long_method": "public long nextLong(){",
            "rand_next_long_shift": "s1 ^= s1 << 23;",
            "rand_next_long_return": "return (this.seed1 = (s1 ^ s0 ^ (s1 >>> 17) ^ (s0 >>> 26))) + s0;",
            "rand_next_int_bound": "return (int)nextLong(n);",
            "rand_next_long_bound_bits": "final long bits = nextLong() >>> 1;",
            "rand_next_long_bound_accept": "if(bits - value + (n - 1) >= 0) return value;",
            "rand_set_seed": "long seed0 = murmurHash3(seed == 0 ? Long.MIN_VALUE : seed);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_cached_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_cached_source"))
        report = source_parity.verify_building_draw_cached_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_cached_method": "public void drawCached(){",
            "draw_cached_delegate": "draw();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_recache_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_recache_source"))
        report = source_parity.verify_building_recache_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "recache_method": "public void recache(){",
            "recache_guard": "if(!headless) renderer.blocks.recacheBuilding(block.buildingCacheLayer, tile);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_payload_draw_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_payload_draw_source"))
        report = source_parity.verify_building_payload_draw_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "payload_draw_method": "public void payloadDraw(){",
            "payload_draw_saved_z": "float z = Draw.z();",
            "payload_draw_cached_guard": "if(block.drawCached){",
            "payload_draw_cached_z": "Draw.z(block.buildingCacheLayer.layer);",
            "payload_draw_cached_call": "drawCached();",
            "payload_draw_dynamic_guard": "if(block.drawDynamic){",
            "payload_draw_restore_z": "Draw.z(z);",
            "payload_draw_dynamic_call": "draw();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_team_top_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_team_top_source"))
        report = source_parity.verify_building_draw_team_top_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_team_top_method": "public void drawTeamTop(){",
            "draw_team_top_found_guard": "if(block.teamRegion.found()){",
            "draw_team_top_color_guard": "if(block.teamRegions[team.id] == block.teamRegion) Draw.color(team.color);",
            "draw_team_top_rect": "Draw.rect(block.teamRegions[team.id], x, y);",
            "draw_team_top_color_reset": "Draw.color();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_liquid_light_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_liquid_light_source"))
        report = source_parity.verify_building_draw_liquid_light_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_liquid_light_method": "public void drawLiquidLight(Liquid liquid, float amount){",
            "draw_liquid_light_amount_guard": "if(amount > 0.01f){",
            "draw_liquid_light_color": "Color color = liquid.lightColor;",
            "draw_liquid_light_fract": "float fract = 1f;",
            "draw_liquid_light_opacity": "float opacity = color.a * fract;",
            "draw_liquid_light_opacity_guard": "if(opacity > 0.001f){",
            "draw_liquid_light_call": "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_light_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_light_source"))
        report = source_parity.verify_building_draw_light_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "draw_light_method": "public void drawLight(){",
            "draw_light_liquid_select": "Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;",
            "draw_light_guard": "if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){",
            "draw_light_lerp": "visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);",
            "draw_light_call": "drawLiquidLight(liq, visualLiquid);",
            "mathf_lerp": "return fromValue + (toValue - fromValue) * progress;",
            "mathf_clamp_01": "return Math.max(Math.min(value, 1f), 0f);",
            "mathf_lerp_delta": "return lerp(fromValue, toValue, clamp(progress * Time.delta));",
        })
        self.assertEqual(report["missing"], [])

    def test_building_draw_team_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_team_source"))
        report = source_parity.verify_building_draw_team_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "draw_team_method": "public void drawTeam(){",
            "draw_team_color": "Draw.color(team.color);",
            "draw_team_rect": "Draw.rect(\"block-border\", x - block.size * tilesize / 2f + 4, y - block.size * tilesize / 2f + 4);",
            "draw_team_color_reset": "Draw.color();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_check_suppression_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_check_suppression_source"))
        report = source_parity.verify_building_check_suppression_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "is_heal_suppressed_method": "public boolean isHealSuppressed(){",
            "is_heal_suppressed_return": "return block.suppressable && Time.time <= healSuppressionTime;",
            "check_suppression_method": "public boolean checkSuppression(){",
            "check_suppression_guard": "if(isHealSuppressed()){",
            "check_suppression_chance": "if(Mathf.chanceDelta(0.03)){",
            "check_suppression_effect": "Fx.regenSuppressParticle.at(x + Mathf.range(block.size * tilesize/2f - 1f), y + Mathf.range(block.size * tilesize/2f - 1f), suppressColor);",
            "check_suppression_true": "return true;",
            "check_suppression_false": "return false;",
            "mathf_range_float": "return random(-range, range);",
            "mathf_chance_delta": "return rand.nextFloat() < d * Time.delta;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_player_placed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_player_placed_source"))
        report = source_parity.verify_building_player_placed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "player_placed_call_super": "@CallSuper",
            "player_placed_method": "public void playerPlaced(Object config){",
            "player_placed_empty_body": "public void playerPlaced(Object config){\n\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_placed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_placed_source"))
        report = source_parity.verify_building_placed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "placed_call_super": "@CallSuper",
            "placed_method": "public void placed(){",
            "placed_client_guard": "if(net.client()) return;",
            "placed_power_guard": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){",
            "placed_links": "PowerNode.getNodeLinks(tile, block, team, other -> {",
            "placed_link_missing_guard": "if(!other.power.links.contains(pos())){",
            "placed_configure": "other.configureAny(pos());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_repaired_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_repaired_source"))
        report = source_parity.verify_building_on_repaired_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_repaired_call_super": "@CallSuper",
            "on_repaired_method": "public void onRepaired(){",
            "on_repaired_placed": "placed();",
            "on_repaired_fog_guard": "if(block.flags.contains(BlockFlag.hasFogRadius)){",
            "on_repaired_force_update": "fogControl.forceUpdate(team, self());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_is_commandable_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_is_commandable_source"))
        report = source_parity.verify_building_is_commandable_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "is_commandable_method": "public boolean isCommandable(){",
            "is_commandable_return": "return block.commandable;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_is_payload_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_is_payload_source"))
        report = source_parity.verify_building_is_payload_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "is_payload_comment": "/** @return whether this building is in a payload */",
            "is_payload_method": "public boolean isPayload(){",
            "is_payload_return": "return tile == emptyTile;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_overwrote_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_overwrote_source"))
        report = source_parity.verify_building_overwrote_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "overwrote_comment": "Called when a block is placed over some other blocks. This seq will always have at least one item.",
            "overwrote_method": "public void overwrote(Seq<Building> previous){",
            "overwrote_empty_body": "public void overwrote(Seq<Building> previous){\n\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_removed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_removed_source"))
        report = source_parity.verify_building_on_removed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_removed_method": "public void onRemoved(){",
            "on_removed_empty_body": "public void onRemoved(){\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_unit_on_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_unit_on_source"))
        report = source_parity.verify_building_unit_on_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "unit_on_comment": "Called every frame a unit is on this. Hovering/flying/steppy units do not apply.",
            "unit_on_method": "public void unitOn(Unit unit){",
            "unit_on_empty_body": "public void unitOn(Unit unit){\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_unit_on_any_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_unit_on_any_source"))
        report = source_parity.verify_building_unit_on_any_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "unit_on_any_comment": "Called every frame a unit is on this. Applies to any unit.",
            "unit_on_any_method": "public void unitOnAny(Unit unit){",
            "unit_on_any_empty_body": "public void unitOnAny(Unit unit){\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_unit_removed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_unit_removed_source"))
        report = source_parity.verify_building_unit_removed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "unit_removed_comment": "Called when a unit that spawned at this tile is removed.",
            "unit_removed_method": "public void unitRemoved(Unit unit){",
            "unit_removed_empty_body": "public void unitRemoved(Unit unit){\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_puddle_on_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_puddle_on_source"))
        report = source_parity.verify_building_puddle_on_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "puddle_on_comment": "Called when a puddle is on this building. Only called at an interval (40 ticks).",
            "puddle_on_method": "public void puddleOn(Puddle puddle){",
            "puddle_on_empty_body": "public void puddleOn(Puddle puddle){\n\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_configured_type_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configured_type_source"))
        report = source_parity.verify_building_configured_type_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "configured_comment": "Called when arbitrary configuration is applied to a tile.",
            "configured_method": "public void configured(@Nullable Unit builder, @Nullable Object value){",
            "configured_type_line": "Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();",
            "configured_item_type": "if(value instanceof Item) type = Item.class;",
            "configured_block_type": "if(value instanceof Block) type = Block.class;",
            "configured_liquid_type": "if(value instanceof Liquid) type = Liquid.class;",
            "configured_unit_type": "if(value instanceof UnitType) type = UnitType.class;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_configured_last_access_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configured_last_access_source"))
        report = source_parity.verify_building_configured_last_access_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "configured_player_guard": "if(builder != null && builder.isPlayer()){",
            "configured_update_last_access_call": "updateLastAccess(builder.getPlayer());",
            "update_last_access_method": "public void updateLastAccess(Player player){",
            "update_last_access_assignment": "lastAccessed = player.coloredName();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_configured_direct_handler_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configured_direct_handler_source"))
        report = source_parity.verify_building_configured_direct_handler_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "configured_handler_guard": "if(block.configurations.containsKey(type)){",
            "configured_handler_call": "block.configurations.get(type).get(this, value);",
            "configured_building_copy_branch": "}else if(value instanceof Building build){",
        })
        self.assertEqual(report["missing"], [])

    def test_building_configured_copy_config_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configured_copy_config_source"))
        report = source_parity.verify_building_configured_copy_config_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "configured_building_copy_branch": "}else if(value instanceof Building build){",
            "configured_copy_comment": "//copy config of another building",
            "configured_copy_config_line": "var conf = build.config();",
            "configured_copy_config_guard": "if(conf != null && !(conf instanceof Building)){",
            "configured_copy_config_recurse": "configured(builder, conf);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_tapped_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_tapped_source"))
        report = source_parity.verify_building_tapped_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "tapped_comment": "Called when the block is tapped by the local player.",
            "tapped_method": "public void tapped(){",
            "tapped_empty_body": "public void tapped(){\n\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_building_after_destroyed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_after_destroyed_source"))
        report = source_parity.verify_building_after_destroyed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "after_destroyed_comment": "Called *after* the tile has been removed.",
            "after_destroyed_method": "public void afterDestroyed(){",
            "after_destroyed_guard": "if(block.destroyBullet != null){",
            "after_destroyed_team": "block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));",
            "mathf_random_seed_float_max": "public static float randomSeed(long seed, float max){",
            "mathf_random_seed_float_max_seed": "seedr.setSeed(seed * 99999);",
            "mathf_random_seed_float_max_body": "return seedr.nextFloat() * max;",
            "rand_next_float": "return (float)((nextLong() >>> 40) * NORM_FLOAT);",
            "rand_norm_float": "private static final double NORM_FLOAT = 1.0 / (1L << 24);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_explosion_item_cap_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_explosion_item_cap_source"))
        report = source_parity.verify_building_explosion_item_cap_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "explosion_item_cap_comment": "@return the cap for item amount calculations, used when this block explodes.",
            "explosion_item_cap_method": "public int explosionItemCap(){",
            "explosion_item_cap_return": "return block.itemCapacity;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_splash_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_splash_liquid_source"))
        report = source_parity.verify_building_splash_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "splash_liquid_method": "public void splashLiquid(Liquid liquid, float amount){",
            "splash_liquid_splash": "float splash = Mathf.clamp(amount / 4f, 0f, 10f);",
            "splash_liquid_loop": "for(int i = 0; i < Mathf.clamp(amount / 5, 0, 30); i++){",
            "splash_liquid_delay": "Time.run(i / 2f, () -> {",
            "splash_liquid_tile_world": "Tile other = world.tileWorld(x + Mathf.range(block.size * tilesize / 2), y + Mathf.range(block.size * tilesize / 2));",
            "splash_liquid_deposit_guard": "if(other != null){",
            "splash_liquid_deposit": "Puddles.deposit(other, liquid, splash);",
            "mathf_clamp_float": "return Math.max(Math.min(value, max), min);",
            "mathf_range_float": "public static float range(float range){",
            "mathf_range_float_body": "return random(-range, range);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_deconstructed_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_deconstructed_liquid_source"))
        report = source_parity.verify_building_on_deconstructed_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_deconstructed_comment": "Called when a block begins (not finishes!) deconstruction. The building is still present at this point.",
            "on_deconstructed_method": "public void onDeconstructed(@Nullable Unit builder){",
            "on_deconstructed_liquid_comment": "//deposit non-incinerable liquid on ground",
            "on_deconstructed_liquid_guard": "if(liquids != null && liquids.currentAmount() > 0 && (!liquids.current().incinerable || block.deconstructDropAllLiquid)){",
            "on_deconstructed_per_cell": "float perCell = liquids.currentAmount() / (block.size * block.size) * 2f;",
            "on_deconstructed_deposit": "tile.getLinkedTiles(other -> Puddles.deposit(other, liquids.current(), perCell));",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_item_explosion_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_item_explosion_source"))
        report = source_parity.verify_building_on_destroyed_item_explosion_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_comment": "Called when the block is destroyed. The tile is still intact at this stage.",
            "on_destroyed_method": "public void onDestroyed(){",
            "on_destroyed_base_explosiveness": "float explosiveness = block.baseExplosiveness;",
            "on_destroyed_flammability_zero": "float flammability = 0f;",
            "on_destroyed_power_zero": "float power = 0f;",
            "on_destroyed_has_items_guard": "if(block.hasItems){",
            "on_destroyed_item_loop": "for(Item item : content.items()){",
            "on_destroyed_item_cap": "int amount = Math.min(items.get(item), explosionItemCap());",
            "on_destroyed_item_explosiveness": "explosiveness += item.explosiveness * amount;",
            "on_destroyed_item_flammability": "flammability += item.flammability * amount;",
            "on_destroyed_item_power": "power += item.charge * Mathf.pow(amount, 1.1f) * 150f;",
            "mathf_pow_float": "public static float pow(float a, float b){",
            "mathf_pow_float_body": "return (float)Math.pow(a, b);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_liquid_explosion_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_liquid_explosion_source"))
        report = source_parity.verify_building_on_destroyed_liquid_explosion_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_has_liquids_guard": "if(block.hasLiquids){",
            "on_destroyed_liquid_flammability": "flammability += liquids.sum((liquid, amount) -> liquid.flammability * amount / 2f);",
            "on_destroyed_liquid_explosiveness": "explosiveness += liquids.sum((liquid, amount) -> liquid.explosiveness * amount / 2f);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_buffered_power_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_buffered_power_source"))
        report = source_parity.verify_building_on_destroyed_buffered_power_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_buffered_power_guard": "if(block.consPower != null && block.consPower.buffered){",
            "on_destroyed_buffered_power_add": "power += this.power.status * block.consPower.capacity;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_splash_liquid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_splash_liquid_source"))
        report = source_parity.verify_building_on_destroyed_splash_liquid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_splash_liquid_guard": "if(block.hasLiquids && state.rules.damageExplosions){",
            "on_destroyed_splash_liquid_each": "liquids.each(this::splashLiquid);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_dynamic_explosion_call_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_dynamic_explosion_call_source"))
        report = source_parity.verify_building_on_destroyed_dynamic_explosion_call_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_dynamic_explosion_comment": "//cap explosiveness so fluid tanks/vaults don't instakill units",
            "on_destroyed_dynamic_explosion_call": "Damage.dynamicExplosion(x, y, flammability * block.flammabilityScale, explosiveness * 3.5f * block.explosivenessScale, power, tilesize * block.size / 2f, state.rules.damageExplosions, block.destroyEffect, block.baseShake);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_rubble_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_rubble_source"))
        report = source_parity.verify_building_on_destroyed_rubble_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_rubble_guard": "if(block.createRubble && !floor().solid && !floor().isLiquid){",
            "on_destroyed_rubble_effect": "Effect.rubble(x, y, block.size);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_base_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_base_sound_source"))
        report = source_parity.verify_building_on_destroyed_base_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_headless_guard": "if(!headless){",
            "on_destroyed_play_destroy_sound": "playDestroySound();",
            "play_destroy_sound_method": "public void playDestroySound(){",
            "play_destroy_sound_call": "block.destroySound.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_reactive_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_reactive_sound_source"))
        report = source_parity.verify_building_on_destroyed_reactive_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_explosive_sound_guard": "if(explosiveness > 40f){",
            "on_destroyed_explosive_sound_call": "(Mathf.chance(0.5) ? Sounds.blockExplodeExplosive : Sounds.blockExplodeExplosiveAlt).at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
            "on_destroyed_flammable_sound_guard": "}else if(flammability > 5f){",
            "on_destroyed_flammable_sound_call": "Sounds.blockExplodeFlammable.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
            "mathf_chance_method": "public static boolean chance(double d){",
            "mathf_chance_body": "return d >= 1f || rand.nextFloat() < d;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_on_destroyed_power_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_destroyed_power_sound_source"))
        report = source_parity.verify_building_on_destroyed_power_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_destroyed_big_power_sound_guard": "if(power > 30000f){",
            "on_destroyed_big_power_sound_call": "Sounds.blockExplodeElectricBig.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
            "on_destroyed_power_sound_guard": "}else if(power > 2000f){",
            "on_destroyed_power_sound_call": "Sounds.blockExplodeElectric.at(tile, Mathf.random(block.destroyPitchMin, block.destroyPitchMax), block.destroySoundVolume);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_display_name_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_display_name_source"))
        report = source_parity.verify_building_display_name_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_display_name_method": "public String getDisplayName(){",
            "building_display_name_comment": "//derelict team icon currently doesn't display",
            "building_display_name_derelict": 'block.localizedName + "\\n" + Core.bundle.get("block.derelict")',
            "building_display_name_regular": 'block.localizedName + (team == player.team() || team.emoji.isEmpty() ? "" : " " + team.emoji);',
        })
        self.assertEqual(report["missing"], [])

    def test_building_display_icon_and_flow_items_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_display_icon_flow_items_source"))
        report = source_parity.verify_building_display_icon_flow_items_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_display_icon_method": "public TextureRegion getDisplayIcon(){",
            "building_display_icon_return": "return block.uiIcon;",
            "building_flow_items_comment": "/** @return the item module to use for flow rate calculations */",
            "building_flow_items_method": "public ItemModule flowItems(){",
            "building_flow_items_return": "return items;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_display_ui_gates_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_display_ui_gates_source"))
        report = source_parity.verify_building_display_ui_gates_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_display_method": "public void display(Table table){",
            "building_display_header_comment": "//display the block stuff",
            "building_display_icon_line": "t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);",
            "building_display_name_line": "t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);",
            "building_display_same_team_comment": "//only display everything else if the team is the same",
            "building_display_same_team_guard": "if(team == player.team()){",
            "building_display_bars_call": "displayBars(bars);",
            "building_display_consumption_call": "table.table(this::displayConsumption).growX();",
            "building_display_flow_gate": "boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;",
            "building_display_last_accessed_guard": "if(net.active() && lastAccessed != null){",
        })
        self.assertEqual(report["missing"], [])

    def test_building_display_consumption_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_display_consumption_source"))
        report = source_parity.verify_building_display_consumption_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_display_consumption_method": "public void displayConsumption(Table table){",
            "building_display_consumption_table_left": "table.left();",
            "building_display_consumption_consumers_loop": "for(Consume cons : block.consumers){",
            "building_display_consumption_optional_booster_skip": "if(cons.optional && cons.booster) continue;",
            "building_display_consumption_build_call": "cons.build(self(), table);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_display_bars_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_display_bars_source"))
        report = source_parity.verify_building_display_bars_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_display_bars_method": "public void displayBars(Table table){",
            "building_display_bars_loop": "for(Func<Building, Bar> bar : block.listBars()){",
            "building_display_bars_get_result": "var result = bar.get(self());",
            "building_display_bars_null_skip": "if(result == null) continue;",
            "building_display_bars_add": "table.add(result).growX();",
            "building_display_bars_row": "table.row();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_display_flow_rate_label_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_display_flow_rate_label_source"))
        report = source_parity.verify_building_display_flow_rate_label_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["arc_source"], "arc-core/src/arc/util/Strings.java")
        self.assertEqual(report["checked"], {
            "building_display_flow_per_second_label": 'String ps = " " + StatUnit.perSecond.localized();',
            "building_display_flow_item_label": 'l.label(() -> flowItems.getFlowRate(item) < 0 ? "..." : Strings.fixed(flowItems.getFlowRate(item), 1) + ps).color(Color.lightGray);',
            "building_display_flow_liquid_label": 'l.label(() -> liquids.getFlowRate(liquid) < 0 ? "..." : Strings.fixed(liquids.getFlowRate(liquid), 1) + ps).color(Color.lightGray);',
            "arc_strings_fixed_method": 'public static String fixed(float d, int decimalPlaces){',
            "arc_strings_fixed_negative": 'boolean negative = d < 0;',
            "arc_strings_fixed_abs": 'd = Math.abs(d);',
            "arc_strings_fixed_scaled": 'dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));',
            "arc_strings_fixed_zero_case": 'if(decimalPlaces == 0){',
            "arc_strings_fixed_zero_prefix": 'result.append("0.");',
        })
        self.assertEqual(report["missing"], [])

    def test_building_cursor_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_cursor_gate_source"))
        report = source_parity.verify_building_cursor_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_cursor_method": "public Cursor getCursor(){",
            "building_cursor_comment": "/** Returns whether a hand cursor should be shown over this block. */",
            "building_cursor_hand": "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_configure_tap_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configure_tap_gate_source"))
        report = source_parity.verify_building_configure_tap_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_configure_tap_method": "public boolean onConfigureBuildTapped(Building other){",
            "building_configure_tap_clear_on_double_tap": "if(block.clearOnDoubleTap){",
            "building_configure_tap_same_building": "if(self() == other){",
            "building_configure_tap_deselect": "deselect();",
            "building_configure_tap_configure_null": "configure(null);",
            "building_configure_tap_return_false": "return false;",
            "building_configure_tap_return_true": "return true;",
            "building_configure_tap_return_not_same": "return self() != other;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_configure_position_tap_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configure_position_tap_source"))
        report = source_parity.verify_building_configure_position_tap_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_configure_position_tap_comment": "* Called when a position is tapped while this building is selected.",
            "building_configure_position_tap_return_comment": "* @return whether the tap event is consumed - if true, the player will not start shooting or interact with things under the cursor.",
            "building_configure_position_tap_method": "public boolean onConfigureTapped(float x, float y){",
            "building_configure_position_tap_return_false": "return false;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_configure_closed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_configure_closed_source"))
        report = source_parity.verify_building_configure_closed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_configure_closed_comment": "* Called when this block's config menu is closed.",
            "building_configure_closed_method": "public void onConfigureClosed(){}",
        })
        self.assertEqual(report["missing"], [])
    def test_building_should_show_configure_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_should_show_configure_source"))
        report = source_parity.verify_building_should_show_configure_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_should_show_configure_comment": "/** Returns whether this config menu should show when the specified player taps it. */",
            "building_should_show_configure_method": "public boolean shouldShowConfigure(Player player){",
            "building_should_show_configure_return_true": "return true;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_should_hide_configure_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_should_hide_configure_source"))
        report = source_parity.verify_building_should_hide_configure_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_should_hide_configure_comment": "/** Whether this configuration should be hidden now. Called every frame the config is open. */",
            "building_should_hide_configure_method": "public boolean shouldHideConfigure(Player player){",
            "building_should_hide_configure_return_false": "return false;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_draw_configure_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_draw_configure_source"))
        report = source_parity.verify_building_draw_configure_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_draw_configure_method": "public void drawConfigure(){",
            "building_draw_configure_color": "Draw.color(Pal.accent);",
            "building_draw_configure_stroke": "Lines.stroke(1f);",
            "building_draw_configure_square": "Lines.square(x, y, block.size * tilesize / 2f + 1f);",
            "building_draw_configure_reset": "Draw.reset();",
        })
        self.assertEqual(report["missing"], [])
    def test_building_check_solid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_check_solid_source"))
        report = source_parity.verify_building_check_solid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_check_solid_method": "public boolean checkSolid(){",
            "building_check_solid_return_false": "return false;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_handle_damage_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_handle_damage_source"))
        report = source_parity.verify_building_handle_damage_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_handle_damage_method": "public float handleDamage(float amount){",
            "building_handle_damage_return_amount": "return amount;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_absorb_lasers_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_absorb_lasers_source"))
        report = source_parity.verify_building_absorb_lasers_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_absorb_lasers_method": "public boolean absorbLasers(){",
            "building_absorb_lasers_return_block_value": "return block.absorbLasers;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_is_insulated_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_is_insulated_source"))
        report = source_parity.verify_building_is_insulated_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_is_insulated_method": "public boolean isInsulated(){",
            "building_is_insulated_return_block_value": "return block.insulated;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_collide_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_collide_source"))
        report = source_parity.verify_building_collide_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_collide_method": "public boolean collide(Bullet other){",
            "building_collide_return_true": "return true;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_collision_damage_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_collision_damage_source"))
        report = source_parity.verify_building_collision_damage_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_collision_method": "public boolean collision(Bullet other){",
            "building_collision_was_dead": "boolean wasDead = health <= 0;",
            "building_collision_type": "BulletType t = other.type;",
            "building_collision_building_damage": "float damage = other.type.buildingDamage(other);",
            "building_collision_pierce_gate": "if(!t.pierceArmor){",
            "building_collision_apply_armor": "damage = Damage.applyArmor(damage, block.armor * t.armorMultiplier * t.blockArmorMultiplier);",
            "building_collision_damage_call": "damage(other, other.team, damage);",
            "building_collision_destroy_event_gate": "if(health <= 0 && !wasDead){",
            "building_collision_destroy_event": "Events.fire(new BuildingBulletDestroyEvent(self(), other));",
            "building_collision_return_true": "return true;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_damage_delegates_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_damage_delegates_source"))
        report = source_parity.verify_building_damage_delegates_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_damage_team_comment": "/** Used to handle damage from splash damage for certain types of blocks. */",
            "building_damage_team_method": "public void damage(@Nullable Team source, float damage){",
            "building_damage_team_delegate": "damage(damage);",
            "building_damage_bullet_comment": "/** Handles splash damage with a bullet source. */",
            "building_damage_bullet_method": "public void damage(Bullet bullet, Team source, float damage){",
            "building_damage_bullet_delegate": "damage(source, damage);",
            "building_damage_bullet_event": "Events.fire(bulletDamageEvent.set(self(), bullet));",
        })
        self.assertEqual(report["missing"], [])
    def test_building_change_team_delegate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_change_team_delegate_source"))
        report = source_parity.verify_building_change_team_delegate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_change_team_comment": "/** Changes this building's team in a safe manner. */",
            "building_change_team_delegate_method": "public void changeTeam(Team next){",
            "building_change_team_delegate_call": "changeTeam(next, true);",
        })
        self.assertEqual(report["missing"], [])
    def test_building_change_team_initial_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_change_team_initial_source"))
        report = source_parity.verify_building_change_team_initial_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_change_team_method": "public void changeTeam(Team next, boolean updatePower){",
            "building_change_team_same_team_return": "if(this.team == next) return;",
            "building_change_team_force_team": "if(block.forceTeam != null) team = block.forceTeam;",
            "building_change_team_last_snapshot": "Team last = this.team;",
            "building_change_team_last_next_return": "if(last == next) return;",
            "building_change_team_was_valid": "boolean was = isValid();",
            "building_change_team_remove_index": "if(was) indexer.removeIndex(tile);",
            "building_change_team_assign_next": "this.team = next;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_change_team_power_proximity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_change_team_power_proximity_source"))
        report = source_parity.verify_building_change_team_power_proximity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_change_team_power_guard": "if(power != null && updatePower){",
            "building_change_team_old_graph": "var oldGraph = power.graph;",
            "building_change_team_proximity_loop": "for(var other : proximity){",
            "building_change_team_proximity_reflow_guard": "if(other != null && other.team != team && other.power != null && other.power.graph == oldGraph){",
            "building_change_team_proximity_reflow": "new PowerGraph().reflow(other);",
        })
        self.assertEqual(report["missing"], [])
    def test_building_change_team_power_links_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_change_team_power_links_source"))
        report = source_parity.verify_building_change_team_power_links_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_change_team_links_loop": "for(int i = 0; i < power.links.size; i++){",
            "building_change_team_world_build": "var other = world.build(power.links.items[i]);",
            "building_change_team_links_comment": "//only reflow links that were connected to the old power graph; ones that have a new one were already covered.",
            "building_change_team_links_guard": "if(other != null && other.team != team && other.power != null && other.power.graph == oldGraph){",
            "building_change_team_remove_link": "power.links.removeIndex(i);",
            "building_change_team_remove_other_link": "other.power.links.removeValue(pos());",
            "building_change_team_reflow_other": "new PowerGraph().reflow(other);",
            "building_change_team_decrement_index": "i --;",
            "building_change_team_reflow_self": "new PowerGraph().reflow(self());",
            "building_change_team_update_power_graph": "updatePowerGraph();",
        })
        self.assertEqual(report["missing"], [])
    def test_building_change_team_final_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_change_team_final_state_source"))
        report = source_parity.verify_building_change_team_final_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_change_team_was_guard": "if(was){",
            "building_change_team_add_index": "indexer.addIndex(tile);",
            "building_change_team_event": "Events.fire(teamChangeEvent.set(last, self()));",
            "building_change_team_check_allow_update": "checkAllowUpdate();",
        })
        self.assertEqual(report["missing"], [])
    def test_building_can_pickup_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_can_pickup_source"))
        report = source_parity.verify_building_can_pickup_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "building_can_pickup_signature": "public boolean canPickup(){",
            "building_can_pickup_block_field": "return block.canPickup;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_picked_up_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_picked_up_source"))
        report = source_parity.verify_building_picked_up_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "picked_up_comment": "Called right before this building is picked up.",
            "picked_up_method": "public void pickedUp(){",
            "picked_up_empty_body": "public void pickedUp(){\n\n    }",
        })
        self.assertEqual(report["missing"], [])
    def test_building_after_picked_up_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_after_picked_up_source"))
        report = source_parity.verify_building_after_picked_up_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "after_picked_up_comment": "Called right after this building is picked up.",
            "after_picked_up_signature": "public void afterPickedUp(){",
            "after_picked_up_power_guard": "if(power != null){",
            "after_picked_up_new_graph": "power.graph = new PowerGraph();",
            "after_picked_up_clear_links": "power.links.clear();",
            "after_picked_up_status_reset": "power.status = 0f;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_remove_from_proximity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_remove_from_proximity_source"))
        report = source_parity.verify_building_remove_from_proximity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "remove_from_proximity_signature": "public void removeFromProximity(){",
            "remove_from_proximity_on_removed": "onProximityRemoved();",
            "remove_from_proximity_tmp_clear": "tmpTiles.clear();",
            "remove_from_proximity_edges": "Point2[] nearby = Edges.getEdges(block.size);",
            "remove_from_proximity_comment": "//remove this tile from all nearby tile's proximities",
            "remove_from_proximity_null_guard": "if(other != null){",
            "remove_from_proximity_tmp_add": "tmpTiles.add(other);",
            "remove_from_proximity_remove": "other.proximity.remove(self(), true);",
            "remove_from_proximity_update": "other.onProximityUpdate();",
            "remove_from_proximity_clear": "proximity.clear();",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_proximity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_proximity_source"))
        report = source_parity.verify_building_update_proximity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_proximity_signature": "public void updateProximity(){",
            "update_proximity_tmp_clear": "tmpTiles.clear();",
            "update_proximity_clear": "proximity.clear();",
            "update_proximity_edges": "Point2[] nearby = Edges.getEdges(block.size);",
            "update_proximity_world_build": "Building other = world.build(tile.x + point.x, tile.y + point.y);",
            "update_proximity_team_guard": "if(other == null || other.team != team) continue;",
            "update_proximity_add_unique": "other.proximity.addUnique(self());",
            "update_proximity_tmp_add": "tmpTiles.add(other);",
            "update_proximity_dedup_comment": "//using a set to prevent duplicates",
            "update_proximity_self_add": "proximity.add(tile);",
            "update_proximity_added": "onProximityAdded();",
            "update_proximity_self_update": "onProximityUpdate();",
            "update_proximity_other_update": "other.onProximityUpdate();",
            "update_proximity_recache": "if(!headless && block.drawCached) recache();",
        })
        self.assertEqual(report["missing"], [])
    def test_building_on_nearby_build_added_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_on_nearby_build_added_source"))
        report = source_parity.verify_building_on_nearby_build_added_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "on_nearby_build_added_empty": "public void onNearbyBuildAdded(Building other){}",
        })
        self.assertEqual(report["missing"], [])
    def test_building_consume_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_consume_source"))
        report = source_parity.verify_building_consume_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "consume_signature": "public void consume(){",
            "consume_loop": "for(Consume cons : block.consumers){",
            "consume_trigger": "cons.trigger(self());",
        })
        self.assertEqual(report["missing"], [])
    def test_building_can_consume_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_can_consume_source"))
        report = source_parity.verify_building_can_consume_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "can_consume_signature": "public boolean canConsume(){",
            "can_consume_return": "return potentialEfficiency > 0;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_efficiency_multiplier_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_efficiency_multiplier_source"))
        report = source_parity.verify_building_efficiency_multiplier_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_efficiency_multiplier_signature": "public void updateEfficiencyMultiplier(){",
            "update_efficiency_multiplier_scale": "float scale = efficiencyScale();",
            "update_efficiency_multiplier_efficiency": "efficiency *= scale;",
            "update_efficiency_multiplier_optional": "optionalEfficiency *= scale;",
            "efficiency_scale_signature": "public float efficiencyScale(){",
            "efficiency_scale_return": "return 1f;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_initial_branch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_initial_source"))
        report = source_parity.verify_building_update_consumption_initial_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_signature": "public void updateConsumption(){",
            "update_consumption_initial_comment": "//everything is valid when cheating",
            "update_consumption_initial_guard": "if(!block.hasConsumers || cheating()){",
            "update_consumption_initial_potential": "potentialEfficiency = enabled && productionValid() ? 1f : 0f;",
            "update_consumption_initial_efficiency": "efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;",
            "update_consumption_initial_power": "shouldConsumePower = true;",
            "update_consumption_initial_multiplier": "updateEfficiencyMultiplier();",
            "update_consumption_initial_return": "return;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_disabled_branch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_disabled_source"))
        report = source_parity.verify_building_update_consumption_disabled_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_disabled_comment": "//disabled -> nothing works",
            "update_consumption_disabled_guard": "if(!enabled){",
            "update_consumption_disabled_efficiencies": "potentialEfficiency = efficiency = optionalEfficiency = 0f;",
            "update_consumption_disabled_power": "shouldConsumePower = false;",
            "update_consumption_disabled_return": "return;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_setup_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_setup_source"))
        report = source_parity.verify_building_update_consumption_setup_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_setup_update": "boolean update = shouldConsume() && productionValid();",
            "update_consumption_setup_min_efficiency": "float minEfficiency = 1f;",
            "update_consumption_setup_comment": "//assume efficiency is 1 for the calculations below",
            "update_consumption_setup_efficiencies": "efficiency = optionalEfficiency = 1f;",
            "update_consumption_setup_power": "shouldConsumePower = true;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_non_optional_pass_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_non_optional_pass_source"))
        report = source_parity.verify_building_update_consumption_non_optional_pass_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_non_optional_comment": "//first pass: get the minimum efficiency of any consumer",
            "update_consumption_non_optional_loop": "for(var cons : block.nonOptionalConsumers){",
            "update_consumption_non_optional_result": "float result = cons.efficiency(self());",
            "update_consumption_non_optional_power_gate": "if(cons != block.consPower && result <= 0.0000001f){",
            "update_consumption_non_optional_power_state": "shouldConsumePower = false;",
            "update_consumption_non_optional_min": "minEfficiency = Math.min(minEfficiency, result);",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_optional_pass_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_optional_pass_source"))
        report = source_parity.verify_building_update_consumption_optional_pass_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_optional_comment": "//same for optionals",
            "update_consumption_optional_loop": "for(var cons : block.optionalConsumers){",
            "update_consumption_optional_min": "optionalEfficiency = Math.min(optionalEfficiency, cons.efficiency(self()));",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_efficiency_assignment_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_efficiency_assignment_source"))
        report = source_parity.verify_building_update_consumption_efficiency_assignment_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_efficiency_comment": "//efficiency is now this minimum value",
            "update_consumption_efficiency_assign": "efficiency = minEfficiency;",
            "update_consumption_efficiency_optional_min": "optionalEfficiency = Math.min(optionalEfficiency, minEfficiency);",
            "update_consumption_potential_comment": "//assign \"potential\"",
            "update_consumption_potential_assign": "potentialEfficiency = efficiency;",
            "update_consumption_no_update_comment": "//no updating means zero efficiency",
            "update_consumption_no_update_guard": "if(!update){",
            "update_consumption_no_update_zero": "efficiency = optionalEfficiency = 0f;",
        })
        self.assertEqual(report["missing"], [])
    def test_building_update_consumption_second_pass_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_second_pass_source"))
        report = source_parity.verify_building_update_consumption_second_pass_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_multiplier_call": "updateEfficiencyMultiplier();",
            "update_consumption_second_pass_comment": "//second pass: update every consumer based on efficiency",
            "update_consumption_second_pass_guard": "if(update && efficiency > 0){",
            "update_consumption_second_pass_loop": "for(var cons : block.updateConsumers){",
            "update_consumption_second_pass_update": "cons.update(self());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_ambient_volume_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_ambient_volume_source"))
        report = source_parity.verify_building_ambient_volume_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "ambient_volume_method": "public float ambientVolume(){",
            "ambient_volume_return": "return efficiency;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_should_ambient_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_should_ambient_sound_source"))
        report = source_parity.verify_building_should_ambient_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "should_ambient_sound_method": "public boolean shouldAmbientSound(){",
            "should_ambient_sound_return": "return shouldConsume();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_config_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_config_default_source"))
        report = source_parity.verify_building_config_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "config_comment": "/** Tile configuration. Defaults to null. Used for block rebuilding. */",
            "config_nullable": "@Nullable",
            "config_method": "public Object config(){",
            "config_return": "return null;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_is_valid_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_is_valid_source"))
        report = source_parity.verify_building_is_valid_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "is_valid_method": "public boolean isValid(){",
            "is_valid_return": "return tile.build == self() && !dead();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_heal_delegates_health_changed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_heal_health_changed_source"))
        report = source_parity.verify_building_heal_health_changed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "heal_priority": "@MethodPriority(100)",
            "heal_method": "public void heal(){",
            "heal_amount_method": "public void heal(float amount){",
            "health_changed_call": "healthChanged();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_hit_size_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_hit_size_source"))
        report = source_parity.verify_building_hit_size_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "hit_size_method": "public float hitSize(){",
            "hit_size_return": "return tile.block().size * tilesize;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_kill_calls_build_destroyed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_kill_source"))
        report = source_parity.verify_building_kill_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "kill_replace": "@Replace",
            "kill_method": "public void kill(){",
            "kill_call": "Call.buildDestroyed(self());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_damage_dead_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_damage_dead_guard_source"))
        report = source_parity.verify_building_damage_dead_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "damage_replace": "@Replace",
            "damage_method": "public void damage(float damage){",
            "damage_dead_guard": "if(dead()) return;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_damage_block_health_scale_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_damage_block_health_scale_source"))
        report = source_parity.verify_building_damage_block_health_scale_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "damage_block_health": "float dm = state.rules.blockHealth(team);",
            "damage_last_damage_time": "lastDamageTime = Time.time;",
            "damage_zero_guard": "if(Mathf.zero(dm)){",
            "damage_zero_assignment": "damage = health + 1;",
            "damage_scale_assignment": "damage /= dm;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_damage_handle_damage_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_damage_handle_damage_gate_source"))
        report = source_parity.verify_building_damage_handle_damage_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "damage_client_todo": "//TODO handle this better on the client.",
            "damage_non_client_guard": "if(!net.client()){",
            "damage_handle_damage": "health -= handleDamage(damage);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_damage_health_changed_call_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_damage_health_changed_call_source"))
        report = source_parity.verify_building_damage_health_changed_call_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "damage_health_changed_call": "healthChanged();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_damage_destroy_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_damage_destroy_gate_source"))
        report = source_parity.verify_building_damage_destroy_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "damage_destroy_gate": "if(health <= 0){",
            "damage_build_destroyed_call": "Call.buildDestroyed(self());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_health_changed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_health_changed_source"))
        report = source_parity.verify_building_health_changed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "health_changed_method": "public void healthChanged(){",
            "health_changed_server_comment": "//server-side, health updates are batched.",
            "health_changed_server_guard": "if(net.server()){",
            "health_changed_server_update": "netServer.buildHealthUpdate(self());",
            "health_changed_indexer_notify": "indexer.notifyHealthChanged(self());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_position_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_position_source"))
        report = source_parity.verify_building_sense_position_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["world_source"], "core/src/mindustry/core/World.java")
        self.assertEqual(report["checked"], {
            "sense_method": "public double sense(LAccess sensor){",
            "sense_switch": "return switch(sensor){",
            "sense_x": "case x -> World.conv(x);",
            "sense_y": "case y -> World.conv(y);",
            "world_conv_method": "public static float conv(float coord){",
            "world_conv_return": "return coord / tilesize;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_health_process_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_health_process_source"))
        report = source_parity.verify_building_sense_health_process_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_health": "case health -> health;",
            "sense_max_health": "case maxHealth -> maxHealth;",
            "sense_efficiency": "case efficiency -> efficiency;",
            "sense_timescale": "case timescale -> timeScale;",
            "sense_range": "case range -> this instanceof Ranged r ? r.range() / tilesize : 0;",
            "sense_rotation": "case rotation -> rotation;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_totals_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_totals_source"))
        report = source_parity.verify_building_sense_totals_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_total_items": "case totalItems -> items == null ? 0 : items.total();",
            "sense_total_liquids_comment": "//totalLiquids is inherently bad design, but unfortunately it is useful for conduits/tanks",
            "sense_total_liquids": "case totalLiquids -> liquids == null ? 0 : liquids.currentAmount();",
            "sense_total_power": "case totalPower -> power == null || block.consPower == null ? 0 : power.status * (block.consPower.buffered ? block.consPower.capacity : 1f);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_capacity_power_net_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_capacity_power_net_source"))
        report = source_parity.verify_building_sense_capacity_power_net_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_item_capacity": "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;",
            "sense_liquid_capacity": "case liquidCapacity -> block.hasLiquids ? block.liquidCapacity : 0;",
            "sense_power_capacity": "case powerCapacity -> block.consPower != null ? block.consPower.capacity : 0f;",
            "sense_power_net_in": "case powerNetIn -> power == null ? 0 : power.graph.getLastScaledPowerIn() * 60;",
            "sense_power_net_out": "case powerNetOut -> power == null ? 0 : power.graph.getLastScaledPowerOut() * 60;",
            "sense_power_net_stored": "case powerNetStored -> power == null ? 0 : power.graph.getLastPowerStored();",
            "sense_power_net_capacity": "case powerNetCapacity -> power == null ? 0 : power.graph.getLastCapacity();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_enabled_controlled_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_enabled_controlled_source"))
        report = source_parity.verify_building_sense_enabled_controlled_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_enabled": "case enabled -> enabled ? 1 : 0;",
            "sense_controlled": "case controlled -> this instanceof ControlBlock c && c.isControlled() ? GlobalVars.ctrlPlayer : 0;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_payload_size_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_payload_size_source"))
        report = source_parity.verify_building_sense_payload_size_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_payload_count": "case payloadCount -> (getPayloads() != null ? getPayloads().total() : 0) + (getPayload() != null ? 1 : 0);",
            "sense_size": "case size -> block.size;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_object_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_object_source"))
        report = source_parity.verify_building_sense_object_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_object_method": "public Object senseObject(LAccess sensor){",
            "sense_object_type": "case type -> block;",
            "sense_object_first_item": "case firstItem -> items == null ? null : items.first();",
            "sense_object_config": "case config -> block.configSenseable() ? config() : null;",
            "sense_object_payload_type": "case payloadType -> getPayload() instanceof UnitPayload p1 ? p1.unit.type : getPayload() instanceof BuildPayload p2 ? p2.block() : null;",
            "sense_object_default": "default -> noSensed;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_content_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_content_source"))
        report = source_parity.verify_building_sense_content_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_content_method": "public double sense(Content content){",
            "sense_content_item": "if(content instanceof Item i && items != null) return items.get(i);",
            "sense_content_liquid": "if(content instanceof Liquid l && liquids != null) return liquids.get(l);",
            "sense_content_payloads_guard": "if(getPayloads() != null){",
            "sense_content_unit": "if(content instanceof UnitType u) return getPayloads().get(u);",
            "sense_content_block": "if(content instanceof Block b) return getPayloads().get(b);",
            "sense_content_invalid": "return Float.NaN; //invalid sense",
        })
        self.assertEqual(report["missing"], [])

    def test_building_sense_camera_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_sense_camera_default_source"))
        report = source_parity.verify_building_sense_camera_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "sense_method": "public double sense(LAccess sensor){",
            "camera_case": "case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;",
            "default_case": "default -> Float.NaN; //gets converted to null in logic",
        })
        self.assertEqual(report["missing"], [])

    def test_building_control_enabled_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_control_enabled_source"))
        report = source_parity.verify_building_control_enabled_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "control_enabled_method": "public void control(LAccess type, double p1, double p2, double p3, double p4){",
            "control_enabled_guard": "if(type == LAccess.enabled){",
            "control_enabled_assignment": "enabled = !Mathf.zero((float)p1);",
            "mathf_float_rounding_error": "public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits",
            "mathf_zero_float_method": "public static boolean zero(float value){",
            "mathf_zero_float_return": "return Math.abs(value) <= FLOAT_ROUNDING_ERROR;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_control_config_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_control_config_source"))
        report = source_parity.verify_building_control_config_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "control_config_method": "public void control(LAccess type, Object p1, double p2, double p3, double p4){",
            "control_config_lag_comment": "//don't execute configure instructions that copy logic building configures; this can cause extreme lag",
            "control_config_guard": "if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){",
            "control_config_new_comment": "//change config only if it's new",
            "control_config_call": "configured(null, p1);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_set_prop_health_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_set_prop_health_source"))
        report = source_parity.verify_building_set_prop_health_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "set_prop_double_method": "public void setProp(LAccess prop, double value){",
            "set_prop_switch": "switch(prop){",
            "set_prop_health_case": "case health -> {",
            "set_prop_health_clamp": "health = (float)Mathf.clamp(value, 0, maxHealth);",
            "set_prop_health_destroy_guard": "if(health <= 0f && !dead()){",
            "set_prop_health_destroy_call": "Call.buildDestroyed(self());",
            "set_prop_health_else": "}else{",
            "set_prop_health_changed": "healthChanged();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_set_prop_team_double_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_set_prop_team_double_source"))
        report = source_parity.verify_building_set_prop_team_double_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "set_prop_double_method": "public void setProp(LAccess prop, double value){",
            "set_prop_team_case": "case team -> {",
            "set_prop_team_get": "Team team = Team.get((int)value);",
            "set_prop_team_guard": "if(this.team != team){",
            "set_prop_team_change": "changeTeam(team);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_set_prop_total_power_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_set_prop_total_power_source"))
        report = source_parity.verify_building_set_prop_total_power_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "set_prop_double_method": "public void setProp(LAccess prop, double value){",
            "set_prop_total_power_case": "case totalPower -> {",
            "set_prop_total_power_guard": "if(power != null && block.consPower != null && block.consPower.buffered){",
            "set_prop_total_power_status": "power.status = Mathf.clamp((float)(value / block.consPower.capacity));",
        })
        self.assertEqual(report["missing"], [])

    def test_building_set_prop_team_object_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_set_prop_team_object_source"))
        report = source_parity.verify_building_set_prop_team_object_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "set_prop_object_method": "public void setProp(LAccess prop, Object value){",
            "set_prop_object_switch": "switch(prop){",
            "set_prop_object_team_case": "case team -> {",
            "set_prop_object_team_guard": "if(value instanceof Team team && this.team != team){",
            "set_prop_object_team_change": "changeTeam(team);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_set_prop_item_content_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_set_prop_item_content_source"))
        report = source_parity.verify_building_set_prop_item_content_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "set_prop_content_method": "public void setProp(UnlockableContent content, double value){",
            "set_prop_item_guard": "if(content instanceof Item item && items != null){",
            "set_prop_item_amount": "int amount = (int)value;",
            "set_prop_item_diff_guard": "if(items.get(item) != amount){",
            "set_prop_item_increase_guard": "if(items.get(item) < amount){",
            "set_prop_item_handle_stack": "handleStack(item, acceptStack(item, amount - items.get(item), null), null);",
            "set_prop_item_decrease_guard": "}else if(amount >= 0){",
            "set_prop_item_remove_stack": "removeStack(item, items.get(item) - amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_set_prop_liquid_content_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_set_prop_liquid_content_source"))
        report = source_parity.verify_building_set_prop_liquid_content_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "set_prop_content_method": "public void setProp(UnlockableContent content, double value){",
            "set_prop_liquid_guard": "}else if(content instanceof Liquid liquid && liquids != null){",
            "set_prop_liquid_amount": "float amount = Mathf.clamp((float)value, 0f, block.liquidCapacity);",
            "set_prop_liquid_decrease_comment": "//decreasing amount is always allowed",
            "set_prop_liquid_gate": "if(amount < liquids.get(liquid) || (acceptLiquid(self(), liquid) && (liquids.current() == liquid || liquids.currentAmount() <= 0.1f || block.consumesLiquid(liquid)))){",
            "set_prop_liquid_set": "liquids.set(liquid, amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_in_fog_initial_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_in_fog_initial_gate_source"))
        report = source_parity.verify_building_in_fog_initial_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "in_fog_replace": "@Replace",
            "in_fog_override": "@Override",
            "in_fog_method": "public boolean inFogTo(Team viewer){",
            "in_fog_initial_gate": "if(team == viewer || !state.rules.fog) return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_in_fog_discovery_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_in_fog_discovery_gate_source"))
        report = source_parity.verify_building_in_fog_discovery_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "in_fog_method": "public boolean inFogTo(Team viewer){",
            "in_fog_grid_snapshot": "int size = block.size, of = block.sizeOffset, tx = tile.x, ty = tile.y;",
            "in_fog_discovered_gate": "if(!isDiscovered(viewer)) return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_in_fog_visibility_loop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_in_fog_visibility_loop_source"))
        report = source_parity.verify_building_in_fog_visibility_loop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "in_fog_x_loop": "for(int x = 0; x < size; x++){",
            "in_fog_y_loop": "for(int y = 0; y < size; y++){",
            "in_fog_visible_check": "if(fogControl.isVisibleTile(viewer, tx + x + of, ty + y + of)){",
            "in_fog_visible_return": "return false;",
            "in_fog_final_return": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_killed_initial_side_effects_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_killed_initial_side_effects_source"))
        report = source_parity.verify_building_killed_initial_side_effects_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "killed_method": "public void killed(){",
            "killed_dead_assignment": "dead = true;",
            "killed_destroy_event": "Events.fire(new BlockDestroyEvent(tile));",
            "killed_on_destroyed": "onDestroyed();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_killed_removal_side_effects_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_killed_removal_side_effects_source"))
        report = source_parity.verify_building_killed_removal_side_effects_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "killed_tile_gate": "if(tile != emptyTile){",
            "killed_tile_remove": "tile.remove();",
            "killed_remove": "remove();",
            "killed_after_destroyed": "afterDestroyed();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_check_allow_update_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_check_allow_update_source"))
        report = source_parity.verify_building_check_allow_update_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "check_allow_update_method": "public void checkAllowUpdate(){",
            "check_allow_update_gate": "if(!allowUpdate()){",
            "check_allow_update_disable": "enabled = false;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_update_timescale_decay_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_timescale_decay_source"))
        report = source_parity.verify_building_update_timescale_decay_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_final_replace": "@Replace",
            "update_method": "public void update(){",
            "update_timescale_decay_gate": "if((timeScaleDuration -= Time.delta) <= 0f){",
            "update_timescale_reset": "timeScale = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_building_update_ambient_sound_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_ambient_sound_gate_source"))
        report = source_parity.verify_building_update_ambient_sound_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_ambient_sound_comment": "//TODO separate multithreaded system for sound? AudioSource, etc",
            "update_ambient_sound_gate": "if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){",
            "update_ambient_sound_loop": "control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());",
        })
        self.assertEqual(report["missing"], [])

    def test_building_update_consumption_call_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_consumption_call_source"))
        report = source_parity.verify_building_update_consumption_call_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_consumption_call": "updateConsumption();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_update_tile_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_tile_gate_source"))
        report = source_parity.verify_building_update_tile_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_tile_gate": "if(enabled || !block.noUpdateDisabled){",
            "update_tile_call": "updateTile();",
        })
        self.assertEqual(report["missing"], [])

    def test_building_update_fog_visibility_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_update_fog_visibility_source"))
        report = source_parity.verify_building_update_fog_visibility_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "update_fog_visibility_method": "public void updateFogVisibility(){",
            "update_fog_visibility_gate": "if(!wasVisible && !inFogTo(player.team())){",
            "update_fog_visibility_flag": "visibleFlags |= (1L << player.team().id);",
            "update_fog_visibility_was_visible": "wasVisible = true;",
            "update_fog_visibility_shadow": "renderer.blocks.updateShadow(self());",
            "update_fog_visibility_minimap": "renderer.minimap.update(tile);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_hitbox_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_hitbox_source"))
        report = source_parity.verify_building_hitbox_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "hitbox_override": "@Override",
            "hitbox_method": "public void hitbox(Rect out){",
            "hitbox_set_centered": "out.setCentered(x, y, block.size * tilesize, block.size * tilesize);",
        })
        self.assertEqual(report["missing"], [])

    def test_building_to_string_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_building_to_string_source"))
        report = source_parity.verify_building_to_string_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["checked"], {
            "to_string_override": "@Override",
            "to_string_replace": "@Replace",
            "to_string_method": "public String toString(){",
            "to_string_return": 'return "Building#" + id() + "[" + tileX() + "," + tileY() + "]:" + block;',
        })
        self.assertEqual(report["missing"], [])

    def test_unit_grounded_flying_target_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_grounded_flying_target_source"))
        report = source_parity.verify_unit_grounded_flying_target_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "check_target_method": "public boolean checkTarget(boolean targetAir, boolean targetGround){",
            "check_target_return": "return (isGrounded() && targetGround) || (isFlying() && targetAir);",
            "is_grounded_method": "public boolean isGrounded(){",
            "is_grounded_return": "return elevation < 0.001f;",
            "is_flying_method": "public boolean isFlying(){",
            "is_flying_return": "return elevation >= 0.09f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_can_drown_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_can_drown_source"))
        report = source_parity.verify_unit_can_drown_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "can_drown_method": "public boolean canDrown(){",
            "can_drown_return": "return isGrounded() && type.canDrown;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_drown_floor_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_drown_floor_source"))
        report = source_parity.verify_unit_drown_floor_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "drown_floor_method": "public @Nullable Floor drownFloor(){",
            "drown_floor_return": "return floorOn();",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_wobble_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_wobble_source"))
        report = source_parity.verify_unit_wobble_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "wobble_method": "public void wobble(){",
            "wobble_x": "x += Mathf.sin(Time.time + (id % 10) * 12, 25f, 0.05f) * Time.delta * elevation;",
            "wobble_y": "y += Mathf.cos(Time.time + (id % 10) * 12, 25f, 0.05f) * Time.delta * elevation;",
            "sin_bits": "private static final int sinBits = 14;",
            "sin_mask": "private static final int sinMask = ~(-1 << sinBits);",
            "sin_table_fill": "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);",
            "sin_lookup": "return sinTable[(int)(radians * radToIndex) & sinMask];",
            "cos_lookup": "return sinTable[(int)((radians + PI / 2) * radToIndex) & sinMask];",
            "sin_scaled": "return sin(radians / scl) * mag;",
            "cos_scaled": "return cos(radians / scl) * mag;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_move_at_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_move_at_source"))
        report = source_parity.verify_unit_move_at_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "move_at_method": "public void moveAt(Vec2 vector, float acceleration){",
            "move_at_target": "Vec2 t = tmp1.set(vector); //target vector",
            "move_at_delta": "tmp2.set(t).sub(vel).limit(acceleration * vector.len() * Time.delta); //delta vector",
            "move_at_add": "vel.add(tmp2);",
            "vec2_len": "return (float)Math.sqrt(x * x + y * y);",
            "vec2_set": "public Vec2 set(Vec2 v){",
            "vec2_sub": "public Vec2 sub(Vec2 v){",
            "vec2_add": "public Vec2 add(Vec2 v){",
            "vec2_limit": "public Vec2 limit(float limit){",
            "vec2_limit2": "if(len2 > limit2){",
            "vec2_limit2_scale": "return scl((float)Math.sqrt(limit2 / len2));",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_move_at_default_accel_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_move_at_default_accel_source"))
        report = source_parity.verify_unit_move_at_default_accel_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "move_at_default_method": "public void moveAt(Vec2 vector){",
            "move_at_default_call": "moveAt(vector, type.accel);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_approach_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_approach_source"))
        report = source_parity.verify_unit_approach_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "unit_approach_method": "public void approach(Vec2 vector){",
            "unit_approach_call": "vel.approachDelta(vector, type.accel * speed());",
            "vec2_approach_delta": "return approach(target, Time.delta * alpha);",
            "vec2_approach_method": "public Vec2 approach(Vec2 target, float alpha){",
            "vec2_dx_dy": "float dx = x - target.x, dy = y - target.y;",
            "vec2_alpha2": "float alpha2 = alpha*alpha;",
            "vec2_len2": "float len2 = Mathf.len2(dx, dy);",
            "vec2_scl": "float scl = Mathf.sqrt(alpha2 / len2);",
            "vec2_sub": "return sub(dx, dy);",
            "vec2_set": "return set(target);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_rotate_move_motion_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_rotate_move_motion_source"))
        report = source_parity.verify_unit_rotate_move_motion_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "rotate_move_method": "public void rotateMove(Vec2 vec){",
            "rotate_move_motion": "moveAt(Tmp.v2.trns(rotation, vec.len()));",
            "vec2_trns": "return set(amount, 0).rotate(angle);",
            "vec2_len": "return (float)Math.sqrt(x * x + y * y);",
            "vec2_rotate": "return rotateRad(degrees * Mathf.degreesToRadians);",
            "vec2_rotate_rad": "public Vec2 rotateRad(float radians){",
            "vec2_rotate_new_x": "float newX = this.x * cos - this.y * sin;",
            "vec2_rotate_new_y": "float newY = this.x * sin + this.y * cos;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_rotate_move_rotation_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_rotate_move_rotation_source"))
        report = source_parity.verify_unit_rotate_move_rotation_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "rotate_move_gate": "if(!vec.isZero()){",
            "rotate_move_rotation": "rotation = Angles.moveToward(rotation, vec.angle(), type.rotateSpeed * Time.delta * speedMultiplier);",
            "vec2_is_zero": "return x == 0 && y == 0;",
            "vec2_angle": "float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees;",
            "vec2_angle_wrap": "if(angle < 0) angle += 360;",
            "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
            "angles_move_snap": "if(Math.abs(angleDist(angle, to)) < speed) return to;",
            "angles_move_branch": "if(angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)){",
            "angles_forward_distance": "return Math.abs(angle1 - angle2);",
            "angles_backward_distance": "return 360 - Math.abs(angle1 - angle2);",
            "mathf_mod_float": "return ((f % n) + n) % n;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_aim_look_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_aim_look_source"))
        report = source_parity.verify_unit_aim_look_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "aim_look_position_method": "public void aimLook(Position pos){",
            "aim_look_position_aim": "aim(pos);",
            "aim_look_position_look_at": "lookAt(pos);",
            "aim_look_xy_method": "public void aimLook(float x, float y){",
            "aim_look_xy_aim": "aim(x, y);",
            "aim_look_xy_look_at": "lookAt(x, y);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_look_at_angle_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_look_at_angle_source"))
        report = source_parity.verify_unit_look_at_angle_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "look_at_angle_method": "public void lookAt(float angle){",
            "look_at_angle_rotation": "rotation = Angles.moveToward(rotation, angle, type.rotateSpeed * Time.delta * speedMultiplier());",
            "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
            "angles_move_snap": "if(Math.abs(angleDist(angle, to)) < speed) return to;",
            "angles_move_branch": "if(angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)){",
            "mathf_mod_float": "return ((f % n) + n) % n;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_look_at_position_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_look_at_position_source"))
        report = source_parity.verify_unit_look_at_position_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "look_at_position_method": "public void lookAt(Position pos){",
            "look_at_position_call": "lookAt(angleTo(pos));",
            "position_angle_to_method": "default float angleTo(Position other){",
            "position_angle_to_return": "return Angles.angle(getX(), getY(), other.getX(), other.getY());",
            "angles_angle_method": "public static float angle(float x, float y, float x2, float y2){",
            "angles_angle_delta": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
            "angles_angle_wrap": "if(ang < 0) ang += 360f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_look_at_xy_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_look_at_xy_source"))
        report = source_parity.verify_unit_look_at_xy_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "look_at_xy_method": "public void lookAt(float x, float y){",
            "look_at_xy_call": "lookAt(angleTo(x, y));",
            "position_angle_to_xy_method": "default float angleTo(float x, float y){",
            "position_angle_to_xy_return": "return Angles.angle(getX(), getY(), x, y);",
            "angles_angle_method": "public static float angle(float x, float y, float x2, float y2){",
            "angles_angle_delta": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
            "angles_angle_wrap": "if(ang < 0) ang += 360f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_controller_predicates_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_controller_predicates_source"))
        report = source_parity.verify_unit_controller_predicates_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["ai_controller_source"], "core/src/mindustry/entities/units/AIController.java")
        self.assertEqual(report["command_ai_source"], "core/src/mindustry/ai/types/CommandAI.java")
        self.assertEqual(report["checked"], {
            "is_ai_method": "public boolean isAI(){",
            "is_ai_return": "return controller instanceof AIController;",
            "allow_command_method": "public boolean allowCommand(){",
            "allow_command_return": "return controller instanceof CommandAI;",
            "is_commandable_method": "public boolean isCommandable(){",
            "is_commandable_return": "return controller instanceof CommandAI;",
            "ai_controller_class": "public class AIController implements UnitController{",
            "command_ai_class": "public class CommandAI extends AIController{",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_can_target_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_can_target_source"))
        report = source_parity.verify_unit_can_target_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "can_target_method": "public boolean canTarget(Teamc other){",
            "can_target_return": "return other != null && (other instanceof Unit u ? u.checkTarget(type.targetAir, type.targetGround) : (other instanceof Building b && type.targetGround));",
            "check_target_method": "public boolean checkTarget(boolean targetAir, boolean targetGround){",
            "check_target_return": "return (isGrounded() && targetGround) || (isFlying() && targetAir);",
            "unit_type_target_air": "targetAir = true,",
            "unit_type_target_ground": "targetGround = true,",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_command_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_command_source"))
        report = source_parity.verify_unit_command_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["command_ai_source"], "core/src/mindustry/ai/types/CommandAI.java")
        self.assertEqual(report["checked"], {
            "command_method": "public CommandAI command(){",
            "command_ai_gate": "if(controller instanceof CommandAI ai){",
            "command_return": "return ai;",
            "command_else": "}else{",
            "command_throw": "throw new IllegalArgumentException(\"Unit cannot be commanded - check isCommandable() first.\");",
            "command_ai_class": "public class CommandAI extends AIController{",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_is_missile_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_is_missile_source"))
        report = source_parity.verify_unit_is_missile_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_types_source"], "core/src/mindustry/content/UnitTypes.java")
        self.assertEqual(report["checked"], {
            "is_missile_method": "public boolean isMissile(){",
            "is_missile_return": "return this instanceof TimedKillc;",
            "missile_comment": "missile definition, unused here but needed for codegen",
            "missile_entity_def": "public static @EntityDef({Unitc.class, TimedKillc.class}) UnitType missile;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_count_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_count_source"))
        report = source_parity.verify_unit_count_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["team_source"], "core/src/mindustry/game/Team.java")
        self.assertEqual(report["teams_source"], "core/src/mindustry/game/Teams.java")
        self.assertEqual(report["checked"], {
            "count_method": "public int count(){",
            "count_return": "return team.data().countType(type);",
            "team_data_method": "public TeamData data(){",
            "team_data_return": "return state.teams.get(this);",
            "team_count_type_method": "public int countType(UnitType type){",
            "team_count_type_return": "return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_cap_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_cap_source"))
        report = source_parity.verify_unit_cap_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["team_source"], "core/src/mindustry/game/Team.java")
        self.assertEqual(report["teams_source"], "core/src/mindustry/game/Teams.java")
        self.assertEqual(report["checked"], {
            "cap_method": "public int cap(){",
            "cap_return": "return Units.getCap(team);",
            "get_cap_method": "public static int getCap(Team team){",
            "get_cap_wave_comment": "wave team has no cap",
            "get_cap_guard": "if((team == state.rules.waveTeam && !state.rules.pvp) || (state.isCampaign() && team == state.rules.waveTeam) || state.rules.disableUnitCap || team.ignoreUnitCap){",
            "get_cap_max": "return Integer.MAX_VALUE;",
            "get_cap_return": "return Math.max(0, state.rules.unitCapVariable ? state.rules.unitCap + team.data().unitCap : state.rules.unitCap);",
            "rules_unit_cap_variable": "public boolean unitCapVariable = true;",
            "rules_unit_cap": "public int unitCap = 0;",
            "rules_disable_unit_cap": "public boolean disableUnitCap;",
            "team_ignore_unit_cap": "public boolean ignoreUnitCap = false;",
            "team_data_unit_cap": "public int unitCap;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_set_type_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_set_type_source"))
        report = source_parity.verify_unit_set_type_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "set_type_method": "public void setType(UnitType type){",
            "assign_type": "this.type = type;",
            "assign_max_health": "this.maxHealth = type.health;",
            "assign_drag": "this.drag = type.drag;",
            "assign_armor": "this.armor = type.armor;",
            "assign_hit_size": "this.hitSize = type.hitSize;",
            "setup_weapons_guard": "if(mounts().length != type.weapons.size) setupWeapons(type);",
            "abilities_guard": "if(abilities.length != type.abilities.size || (abilities.length > 0 && abilities[0] instanceof EmptyDataAbility)){",
            "abilities_array": "abilities = new Ability[type.abilities.size];",
            "ability_copy": "abilities[i] = type.abilities.get(i).copy();",
            "ability_data_carry": "abilities[i].data = old[i].data;",
            "controller_guard": "if(controller == null) controller(type.createController(self()));",
            "unit_type_health": "health = 200f,",
            "unit_type_drag": "drag = 0.3f,",
            "unit_type_armor": "armor = 0f,",
            "unit_type_hit_size": "hitSize = 6f,",
            "unit_type_abilities": "public Seq<Ability> abilities = new Seq<>();",
            "unit_type_weapons": "public Seq<Weapon> weapons = new Seq<>();",
            "unit_type_create_controller": "public UnitController createController(Unit unit){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_player_controllable_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_player_controllable_source"))
        report = source_parity.verify_unit_player_controllable_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["logic_ai_source"], "core/src/mindustry/ai/types/LogicAI.java")
        self.assertEqual(report["block_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(report["checked"], {
            "player_controllable_method": "public boolean playerControllable(){",
            "player_controllable_return": "return type.playerControllable && !(controller instanceof LogicAI ai && ai.controller != null && ai.controller.block.privileged);",
            "unit_type_player_controllable": "playerControllable = true,",
            "logic_ai_class": "public class LogicAI extends AIController{",
            "logic_ai_controller": "public @Nullable Building controller;",
            "block_privileged": "public boolean privileged = false;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_targetable_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_targetable_source"))
        report = source_parity.verify_unit_targetable_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["payload_comp_source"], "core/src/mindustry/entities/comp/PayloadComp.java")
        self.assertEqual(report["checked"], {
            "unit_targetable_method": "public boolean targetable(Team targeter){",
            "unit_targetable_return": "return type.targetable(self(), targeter);",
            "type_targetable_method": "public boolean targetable(Unit unit, Team targeter){",
            "type_targetable_return": "return targetable || (vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload());",
            "type_targetable_default": "targetable = true,",
            "type_vulnerable_with_payloads_default": "vulnerableWithPayloads = false,",
            "payload_comp_has_payload": "boolean hasPayload(){",
            "payload_comp_has_payload_return": "return payloads.size > 0;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_killable_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_killable_source"))
        report = source_parity.verify_unit_killable_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "unit_killable_method": "public boolean killable(){",
            "unit_killable_return": "return type.killable(self());",
            "type_killable_method": "public boolean killable(Unit unit){",
            "type_killable_return": "return killable;",
            "type_killable_default": "killable = true,",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_hittable_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_hittable_source"))
        report = source_parity.verify_unit_hittable_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["payload_comp_source"], "core/src/mindustry/entities/comp/PayloadComp.java")
        self.assertEqual(report["checked"], {
            "unit_hittable_method": "public boolean hittable(){",
            "unit_hittable_return": "return type.hittable(self());",
            "type_hittable_method": "public boolean hittable(Unit unit){",
            "type_hittable_return": "return hittable || (vulnerableWithPayloads && unit instanceof Payloadc p && p.hasPayload());",
            "type_hittable_default": "hittable = true,",
            "type_vulnerable_with_payloads_default": "vulnerableWithPayloads = false,",
            "payload_comp_has_payload": "boolean hasPayload(){",
            "payload_comp_has_payload_return": "return payloads.size > 0;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_after_sync_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_after_sync_source"))
        report = source_parity.verify_unit_after_sync_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_controller_source"], "core/src/mindustry/entities/units/UnitController.java")
        self.assertEqual(report["checked"], {
            "after_sync_override": "@Override\n    public void afterSync(){",
            "after_sync_comment": "set up type info after reading",
            "after_sync_set_type": "setType(this.type);",
            "after_sync_controller_unit": "controller.unit(self());",
            "unit_controller_unit": "void unit(Unit unit);",
            "unit_controller_unit_getter": "@Nullable Unit unit();",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_after_read_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_after_read_source"))
        report = source_parity.verify_unit_after_read_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["ai_controller_source"], "core/src/mindustry/entities/units/AIController.java")
        self.assertEqual(report["command_ai_source"], "core/src/mindustry/ai/types/CommandAI.java")
        self.assertEqual(report["logic_ai_source"], "core/src/mindustry/ai/types/LogicAI.java")
        self.assertEqual(report["checked"], {
            "after_read_override": "@Override\n    public void afterRead(){",
            "after_read_set_type": "setType(this.type);",
            "after_read_controller_unit": "controller.unit(self());",
            "after_read_reset_comment": "reset controller state",
            "after_read_reset_guard": "if(!(controller instanceof AIController ai && ai.keepState())){",
            "after_read_create_controller": "controller(type.createController(self()));",
            "ai_keep_state_method": "public boolean keepState(){",
            "ai_keep_state_return": "return false;",
            "command_ai_keep_state": "public boolean keepState(){\n        return true;\n    }",
            "logic_ai_keep_state_comment": "LogicAI state should not be reset after reading.",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_after_read_all_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_after_read_all_source"))
        report = source_parity.verify_unit_after_read_all_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_controller_source"], "core/src/mindustry/entities/units/UnitController.java")
        self.assertEqual(report["checked"], {
            "after_read_all_override": "@Override\n    public void afterReadAll(){",
            "after_read_all_controller_after_read": "controller.afterRead(self());",
            "unit_controller_after_read": "default void afterRead(Unit unit){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_add_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_add_source"))
        report = source_parity.verify_unit_add_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["teams_source"], "core/src/mindustry/game/Teams.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["checked"], {
            "add_override": "@Override\n    public void add(){",
            "add_update_count": "team.data().updateCount(type, 1);",
            "add_unit_cap_comment": "check if over unit cap",
            "add_cap_guard": "if(type.useUnitCap && count() > cap() && !spawnedByCore && !dead && !state.rules.editor){",
            "add_unit_cap_death": "Call.unitCapDeath(self());",
            "add_update_count_negative": "team.data().updateCount(type, -1);",
            "team_data_update_count": "public void updateCount(UnitType type, int amount){",
            "team_data_update_null": "if(type == null) return;",
            "team_data_update_unit_count": "unitCount = Math.max(amount + unitCount, 0);",
            "team_data_update_type_count": "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);",
            "units_unit_cap_death": "public static void unitCapDeath(Unit unit){",
            "unit_cap_death_dead": "unit.dead = true;",
            "unit_type_use_unit_cap_default": "useUnitCap = true,",
            "rules_editor_default": "public boolean editor = false;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_remove_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_remove_source"))
        report = source_parity.verify_unit_remove_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["teams_source"], "core/src/mindustry/game/Teams.java")
        self.assertEqual(report["unit_controller_source"], "core/src/mindustry/entities/units/UnitController.java")
        self.assertEqual(report["fx_source"], "core/src/mindustry/content/Fx.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["trail_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(report["checked"], {
            "remove_override": "@Override\n    public void remove(){",
            "remove_update_count": "team.data().updateCount(type, -1);",
            "remove_controller_removed": "controller.removed(self());",
            "remove_trail_comment": "make sure trail doesn't just go poof",
            "remove_trail_guard": "if(trail != null && trail.size() > 0){",
            "remove_trail_fade": "Fx.trailFade.at(x, y, trail.width(), type.trailColor == null ? team.color : type.trailColor, trail.copy());",
            "team_data_update_count": "public void updateCount(UnitType type, int amount){",
            "team_data_update_type_count": "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);",
            "unit_controller_removed": "default void removed(Unit unit){",
            "fx_trail_fade": "trailFade = new Effect(400f, e -> {",
            "fx_trail_instance_guard": "if(!(e.data instanceof Trail trail)) return;",
            "unit_type_trail_color": "public @Nullable Color trailColor;",
            "trail_copy": "public Trail copy(){",
            "trail_width": "public float width(){",
            "trail_size": "public int size(){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_landed_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_landed_source"))
        report = source_parity.verify_unit_landed_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["checked"], {
            "landed_override": "@Override\n    public void landed(){",
            "landed_shake_guard": "if(type.mechLandShake > 0f){",
            "landed_shake_call": "Effect.shake(type.mechLandShake, type.mechLandShake, this);",
            "landed_type_call": "type.landed(self());",
            "unit_type_mech_land_shake": "public float mechLandShake = 0f;",
            "unit_type_landed": "public void landed(Unit unit){}",
            "effect_shake_position": "public static void shake(float intensity, float duration, Position loc){",
            "effect_shake_position_call": "shake(intensity, duration, loc.getX(), loc.getY());",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_drowning_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_drowning_source"))
        report = source_parity.verify_unit_update_drowning_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["floor_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["event_type_source"], "core/src/mindustry/game/EventType.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "drown_time_field": "transient float drownTime;",
            "last_drown_floor_field": "transient @Nullable Floor lastDrownFloor;",
            "method": "public void updateDrowning(){",
            "floor_lookup": "Floor floor = drownFloor();",
            "drown_guard": "if(floor != null && floor.isLiquid && floor.drownTime > 0 && canDrown()){",
            "last_floor_set": "lastDrownFloor = floor;",
            "drown_increment": "drownTime += Time.delta / (hitSize / 8f * type.drownTimeMultiplier * floor.drownTime);",
            "chance_gate": "if(Mathf.chanceDelta(0.05f)){",
            "drown_effect_call": "floor.drownUpdateEffect.at(x, y, hitSize, floor.mapColor);",
            "kill_guard": "if(drownTime >= 0.999f && !net.client()){",
            "kill_call": "kill();",
            "event_call": "Events.fire(new UnitDrownEvent(self()));",
            "dry_decay": "drownTime -= Time.delta / 50f;",
            "clamp": "drownTime = Mathf.clamp(drownTime);",
            "floor_drown_time": "public float drownTime = 0f;",
            "floor_drown_update_effect": "public Effect drownUpdateEffect = Fx.bubble;",
            "floor_is_liquid": "public boolean isLiquid;",
            "unit_drown_event": "public static class UnitDrownEvent{",
            "unit_drown_event_unit": "public final Unit unit;",
            "unit_type_drown_multiplier": "drownTimeMultiplier = 1f,",
            "mathf_chance_delta": "public static boolean chanceDelta(double d){",
            "mathf_chance_delta_delta": "return rand.nextFloat() < d * Time.delta;",
            "mathf_clamp_unit": "public static float clamp(float value){",
            "mathf_clamp_unit_body": "return Math.max(Math.min(value, 1f), 0f);",
            "time_delta_default": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_type_hook_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_type_hook_source"))
        report = source_parity.verify_unit_update_type_hook_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "update_override": "@Override\n    public void update(){",
            "type_update_call": "type.update(self());",
            "unit_type_update_hook": "public void update(Unit unit){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_bounds_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_bounds_source"))
        report = source_parity.verify_unit_update_bounds_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["world_source"], "core/src/mindustry/core/World.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "warp_dst": "static final float warpDst = 8f;",
            "bounded_guard": "if(type.bounded){",
            "world_bounds": "float bot = 0f, left = 0f, top = world.unitHeight(), right = world.unitWidth();",
            "limit_area_guard": "if(state.rules.limitMapArea && !team.isAI()){",
            "limit_bot": "bot = state.rules.limitY * tilesize;",
            "limit_left": "left = state.rules.limitX * tilesize;",
            "limit_top": "top = state.rules.limitHeight * tilesize + bot;",
            "limit_right": "right = state.rules.limitWidth * tilesize + left;",
            "net_local_guard": "if(!net.client() || isLocal()){",
            "dx_left": "if(x < left) dx += (-(x - left)/warpDst);",
            "dy_bot": "if(y < bot) dy += (-(y - bot)/warpDst);",
            "dx_right": "if(x > right - tilesize) dx -= (x - (right - tilesize))/warpDst;",
            "dy_top": "if(y > top - tilesize) dy -= (y - (top - tilesize))/warpDst;",
            "vel_add_net": "velAddNet(dx * Time.delta, dy * Time.delta);",
            "margin": "float margin = tilesize * 1f;",
            "margin_clamp_x": "x = Mathf.clamp(x, left - margin, right - tilesize + margin);",
            "margin_clamp_y": "y = Mathf.clamp(y, bot - margin, top - tilesize + margin);",
            "grounded_guard": "if(isGrounded()){",
            "grounded_clamp_x": "x = Mathf.clamp(x, left, right - tilesize);",
            "grounded_clamp_y": "y = Mathf.clamp(y, bot, top - tilesize);",
            "kill_guard": "if(x < -finalWorldBounds + left || y < -finalWorldBounds + bot || x >= right + finalWorldBounds || y >= top + finalWorldBounds){",
            "kill_call": "kill();",
            "tilesize": "public static final int tilesize = 8;",
            "final_world_bounds": "public static final float finalWorldBounds = 250;",
            "rules_limit_map_area": "public boolean limitMapArea = false;",
            "rules_limit_rect": "public int limitX, limitY, limitWidth = 1, limitHeight = 1;",
            "world_unit_width": "public int unitWidth(){",
            "world_unit_width_body": "return width()*tilesize;",
            "world_unit_height": "public int unitHeight(){",
            "world_unit_height_body": "return height()*tilesize;",
            "mathf_clamp_range": "public static float clamp(float value, float min, float max){",
            "mathf_clamp_range_body": "return Math.max(Math.min(value, max), min);",
            "time_delta_default": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_nan_health_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_nan_health_source"))
        report = source_parity.verify_unit_update_nan_health_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "nan_guard": "if(Float.isNaN(health)){",
            "health_zero": "health = 0f;",
            "kill_call": "kill();",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_flying_transition_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_flying_transition_source"))
        report = source_parity.verify_unit_update_flying_transition_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["floor_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["tile_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(report["fx_source"], "core/src/mindustry/content/Fx.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["checked"], {
            "floor_lookup": "Floor floor = floorOn();",
            "tile_lookup": "Tile tile = tileOn();",
            "transition_guard": "if(isFlying() != wasFlying){",
            "was_flying_guard": "if(wasFlying){",
            "tile_guard": "if(tile != null){",
            "unit_land_call": "Fx.unitLand.at(x, y, floor.isLiquid ? 1f : 0.5f, tile.getFloorColor());",
            "was_flying_assign": "wasFlying = isFlying();",
            "floor_is_liquid": "public boolean isLiquid;",
            "tile_get_floor_color": "public Color getFloorColor(){",
            "tile_get_floor_color_body": "return floor.getColor(this);",
            "fx_unit_land": "unitLand = new Effect(30, e -> {",
            "effect_at_rotation_color": "public void at(float x, float y, float rotation, Color color){",
            "effect_at_rotation_color_body": "create(x, y, rotation, color, null);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_walk_effect_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_walk_effect_source"))
        report = source_parity.verify_unit_update_walk_effect_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["floor_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["tile_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["hitbox_source"], "core/src/mindustry/entities/comp/HitboxComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "walk_gate": "if(!type.hovering && isGrounded() && type.emitWalkEffect){",
            "timer_add_threshold": "if((splashTimer += Mathf.dst(deltaX(), deltaY())) >= (7f + hitSize()/8f)){",
            "walk_effect_call": "floor.walkEffect.at(x, y, hitSize() / 8f, tile != null ? tile.getFloorColor() : floor.mapColor);",
            "splash_timer_reset": "splashTimer = 0f;",
            "walk_sound_guard": "if(type.emitWalkSound){",
            "walk_sound_call": "floor.walkSound.at(x, y, Mathf.random(floor.walkSoundPitchMin, floor.walkSoundPitchMax), floor.walkSoundVolume);",
            "floor_walk_effect": "public Effect walkEffect = Fx.none;",
            "floor_walk_sound": "public Sound walkSound = Sounds.none;",
            "floor_walk_sound_params": "public float walkSoundVolume = 0.1f, walkSoundPitchMin = 0.8f, walkSoundPitchMax = 1.2f;",
            "liquid_walk_effect": "walkEffect = Fx.ripple;",
            "liquid_walk_sound": "walkSound = Sounds.stepWater;",
            "tile_get_floor_color": "public Color getFloorColor(){",
            "tile_get_floor_color_body": "return floor.getColor(this);",
            "unit_type_emit_walk_sound": "public boolean emitWalkSound = true;",
            "unit_type_emit_walk_effect": "public boolean emitWalkEffect = true;",
            "hitbox_delta_fields": "transient float lastX, lastY, deltaX, deltaY, hitSize;",
            "hitbox_delta_x_assign": "deltaX = x - lastX;",
            "hitbox_delta_y_assign": "deltaY = y - lastY;",
            "mathf_dst": "public static float dst(float x1, float y1){",
            "mathf_dst_body": "return (float)Math.sqrt(x1 * x1 + y1*y1);",
            "mathf_random_float_range": "public static float random(float start, float end){",
            "mathf_random_float_range_body": "return start + rand.nextFloat() * (end - start);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_heal_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_heal_source"))
        report = source_parity.verify_unit_heal_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["health_comp_source"], "core/src/mindustry/entities/comp/HealthComp.java")
        self.assertEqual(report["checked"], {
            "was_healed_field": "private transient boolean wasHealed;",
            "heal_override": "@Override\n    public void heal(float amount){",
            "heal_guard": "if(health < maxHealth && amount > 0){",
            "heal_was_healed": "wasHealed = true;",
            "update_was_healed_gate": "if(wasHealed && healTime <= -1f){",
            "update_heal_time": "healTime = 1f;",
            "update_was_healed_reset": "wasHealed = false;",
            "health_comp_heal_comment": "Heals by a flat amount.",
            "health_comp_heal_method": "void heal(float amount){",
            "health_comp_heal_add": "health += amount;",
            "health_comp_heal_clamp": "clampHealth();",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_heal_time_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_heal_time_source"))
        report = source_parity.verify_unit_update_heal_time_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "heal_time_field": "transient float shadowAlpha = -1f, healTime;",
            "was_healed_field": "private transient boolean wasHealed;",
            "drowning_before_heal": "updateDrowning();",
            "was_healed_gate": "if(wasHealed && healTime <= -1f){",
            "heal_time_reset": "healTime = 1f;",
            "heal_time_decay": "healTime -= Time.delta / 20f;",
            "was_healed_reset": "wasHealed = false;",
            "time_delta_default": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_captured_sector_death_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_captured_sector_death_source"))
        report = source_parity.verify_unit_update_captured_sector_death_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["team_source"], "core/src/mindustry/game/Team.java")
        self.assertEqual(report["game_state_source"], "core/src/mindustry/core/GameState.java")
        self.assertEqual(report["sector_source"], "core/src/mindustry/type/Sector.java")
        self.assertEqual(report["checked"], {
            "captured_comment": "//die on captured sectors immediately",
            "captured_guard": "if(team.isOnlyAI() && state.isCampaign() && state.getSector().isCaptured()){",
            "kill_call": "kill();",
            "team_is_only_ai": "public boolean isOnlyAI(){",
            "team_is_only_ai_body": "return isAI() && data().players.size == 0;",
            "state_is_campaign": "public boolean isCampaign(){",
            "state_is_campaign_body": "return rules.sector != null;",
            "state_get_sector": "public @Nullable Sector getSector(){",
            "state_get_sector_body": "return rules.sector;",
            "sector_is_captured": "public boolean isCaptured(){",
            "sector_playing_capture": "if(isBeingPlayed()) return !state.rules.waves && !state.rules.attackMode;",
            "sector_save_capture": "return save != null && !info.waves && !info.attack;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_sound_loop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_sound_loop_source"))
        report = source_parity.verify_unit_update_sound_loop_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["sound_control_source"], "core/src/mindustry/audio/SoundControl.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "headless_guard": "if(!headless){",
            "loop_sound_call": "control.sound.loop(type.loopSound, this, type.loopSoundVolume);",
            "move_sound_guard": "if(type.moveSound != Sounds.none){",
            "move_progress": "float progress = Mathf.clamp(vel.len() / type.speed);",
            "move_pitch": "float pitch = Mathf.lerp(type.moveSoundPitchMin,  type.moveSoundPitchMax, progress);",
            "move_sound_call": "control.sound.loop(type.moveSound, this, type.moveSoundVolume * progress, pitch);",
            "vars_headless": "public static boolean headless;",
            "unit_loop_sound": "public Sound loopSound = Sounds.none;",
            "unit_loop_sound_volume": "public float loopSoundVolume = 0.5f;",
            "unit_move_sound": "public Sound moveSound = Sounds.none;",
            "unit_move_sound_volume": "public float moveSoundVolume = 1f;",
            "unit_move_sound_pitch": "public float moveSoundPitchMin = 1f, moveSoundPitchMax = 1f;",
            "sound_control_loop_pos": "public void loop(Sound sound, Position pos, float volume, float pitch){",
            "sound_control_guard": "if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;",
            "mathf_clamp_unit": "public static float clamp(float value){",
            "mathf_clamp_unit_body": "return Math.max(Math.min(value, 1f), 0f);",
            "mathf_lerp": "public static float lerp(float fromValue, float toValue, float progress){",
            "mathf_lerp_body": "return fromValue + (toValue - fromValue) * progress;",
            "vec2_len": "public float len(){",
            "vec2_len_body": "return (float)Math.sqrt(x * x + y * y);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_unsupported_env_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_unsupported_env_source"))
        report = source_parity.verify_unit_update_unsupported_env_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["teams_source"], "core/src/mindustry/game/Teams.java")
        self.assertEqual(report["checked"], {
            "unsupported_env_comment": "//check if environment is unsupported",
            "unsupported_env_guard": "if(!type.supportsEnv(state.rules.env) && !dead){",
            "unit_env_death_call": "Call.unitEnvDeath(self());",
            "update_count_negative": "team.data().updateCount(type, -1);",
            "unit_supports_env_method": "public boolean supportsEnv(int env){",
            "unit_supports_env_body": "return (envEnabled & env) != 0 && (envDisabled & env) == 0 && (envRequired == 0 || (envRequired & env) == envRequired);",
            "units_unit_env_death": "public static void unitEnvDeath(Unit unit){",
            "units_unit_env_dead": "unit.dead = true;",
            "units_unit_env_effect": "Fx.unitEnvKill.at(unit);",
            "units_unit_env_destroy": "Core.app.post(() -> Call.unitDestroy(unit.id));",
            "team_data_update_count": "public void updateCount(UnitType type, int amount){",
            "team_data_update_count_null_guard": "if(type == null) return;",
            "team_data_update_count_total": "unitCount = Math.max(amount + unitCount, 0);",
            "team_data_update_count_type": "typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_abilities_loop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_abilities_loop_source"))
        report = source_parity.verify_unit_update_abilities_loop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["ability_source"], "core/src/mindustry/entities/abilities/Ability.java")
        self.assertEqual(report["checked"], {
            "unit_abilities_field": "Ability[] abilities = {};",
            "abilities_loop": "for(Ability a : abilities){",
            "ability_update_call": "a.update(self());",
            "ability_update_method": "public void update(Unit unit){}",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_trail_position_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_trail_position_source"))
        report = source_parity.verify_unit_update_trail_position_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["trail_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "trail_field": "transient @Nullable Trail trail;",
            "trail_guard": "if(trail != null){",
            "trail_length_set": "trail.length = type.trailLength;",
            "trail_scale": "float scale = type.useEngineElevation ? elevation : 1f;",
            "trail_offset": "float offset = type.engineOffset/2f + type.engineOffset/2f*scale;",
            "trail_position": "float cx = x + Angles.trnsx(rotation + 180, offset), cy = y + Angles.trnsy(rotation + 180, offset);",
            "trail_update_call": "trail.update(cx, cy);",
            "unit_engine_offset": "engineOffset = 5f,",
            "unit_use_engine_elevation": "public boolean useEngineElevation = true;",
            "unit_trail_length": "public int trailLength = 0;",
            "trail_update_xy": "public void update(float x, float y){",
            "trail_update_width_delegate": "update(x, y, 1f);",
            "angles_trnsx": "public static float trnsx(float angle, float len){",
            "angles_trnsx_body": "return len * Mathf.cosDeg(angle);",
            "angles_trnsy": "public static float trnsy(float angle, float len){",
            "angles_trnsy_body": "return len * Mathf.sinDeg(angle);",
            "mathf_sin_deg": "public static float sinDeg(float degrees){",
            "mathf_cos_deg": "public static float cosDeg(float degrees){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_drag_formula_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_drag_formula_source"))
        report = source_parity.verify_unit_update_drag_formula_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["floor_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["checked"], {
            "unit_import_drag": "@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;",
            "drag_formula": "drag = type.drag * (isGrounded() ? (floorOn().dragMultiplier) : 1f) * dragMultiplier * state.rules.dragMultiplier;",
            "unit_type_drag_default": "drag = 0.3f,",
            "floor_drag_multiplier": "public float dragMultiplier = 1f;",
            "rules_drag_multiplier": "public float dragMultiplier = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_spawn_knockback_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_spawn_knockback_source"))
        report = source_parity.verify_unit_update_spawn_knockback_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["game_state_source"], "core/src/mindustry/core/GameState.java")
        self.assertEqual(report["wave_spawner_source"], "core/src/mindustry/ai/WaveSpawner.java")
        self.assertEqual(report["net_source"], "core/src/mindustry/net/Net.java")
        self.assertEqual(report["vel_comp_source"], "core/src/mindustry/entities/comp/VelComp.java")
        self.assertEqual(report["arc_position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "spawn_knockback_comment": "//apply knockback based on spawns",
            "spawn_knockback_guard": "if(team != state.rules.waveTeam && state.hasSpawns() && (!net.client() || isLocal()) && hittable()){",
            "relative_size": "float relativeSize = state.rules.dropZoneRadius + hitSize/2f + 1f;",
            "spawn_loop": "for(Tile spawn : spawner.getSpawns()){",
            "spawn_within_guard": "if(within(spawn.worldx(), spawn.worldy(), relativeSize)){",
            "vel_add_net_call": "velAddNet(Tmp.v1.set(this).sub(spawn.worldx(), spawn.worldy()).setLength(0.1f + 1f - dst(spawn) / relativeSize).scl(0.45f * Time.delta));",
            "rules_drop_zone_radius": "public float dropZoneRadius = 300f;",
            "rules_wave_team": "public Team waveTeam = Team.crux;",
            "state_has_spawns": "public boolean hasSpawns(){",
            "state_has_spawns_body": "return rules.waves && ((rules.waveTeam.cores().size > 0 && rules.attackMode) || rules.spawns.size > 0);",
            "spawner_get_spawns": "public Seq<Tile> getSpawns(){",
            "spawner_get_spawns_body": "return spawns;",
            "net_client": "public boolean client(){",
            "net_client_body": "return !server && active;",
            "vel_add_net_vec": "void velAddNet(Vec2 v){",
            "vel_add_net_add": "vel.add(v);",
            "vel_add_net_remote_x": "x += v.x;",
            "vel_add_net_remote_y": "y += v.y;",
            "position_within": "default boolean within(float x, float y, float dst){",
            "position_within_body": "return Mathf.dst2(getX(), getY(), x, y) < dst*dst;",
            "position_dst": "default float dst(float x, float y){",
            "position_dst_body": "return Mathf.sqrt(xd * xd + yd * yd);",
            "vec2_set_position": "public Vec2 set(Position v){",
            "vec2_set_position_x": "x = v.getX();",
            "vec2_sub": "public Vec2 sub(float x, float y){",
            "vec2_set_length": "public Vec2 setLength(float len){",
            "vec2_scl": "public Vec2 scl(float scalar){",
            "time_delta_default": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_falling_drag_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_falling_drag_source"))
        report = source_parity.verify_unit_update_falling_drag_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "unit_import_dead": "@Import boolean dead, disarmed;",
            "unit_import_health_drag": "@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;",
            "falling_comment": "//simulate falling down",
            "falling_guard": "if(dead || health <= 0){",
            "less_drag_comment": "//less drag when dead",
            "falling_drag": "drag = 0.01f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_falling_smoke_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_falling_smoke_source"))
        report = source_parity.verify_unit_update_falling_smoke_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["fx_source"], "core/src/mindustry/content/Fx.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["arc_tmp_source"], "arc-core/src/arc/util/Tmp.java")
        self.assertEqual(report["checked"], {
            "standard_fall_smoke_comment": "//standard fall smoke",
            "standard_fall_smoke_chance": "if(Mathf.chanceDelta(0.1)){",
            "standard_fall_smoke_tmp": "Tmp.v1.rnd(Mathf.range(hitSize));",
            "standard_fall_smoke_effect": "type.fallEffect.at(x + Tmp.v1.x, y + Tmp.v1.y);",
            "unit_type_fall_effect": "public Effect fallEffect = Fx.fallSmoke;",
            "fx_fall_smoke": "fallSmoke = new Effect(110, e -> {",
            "mathf_range_float": "public static float range(float range){",
            "mathf_range_float_body": "return random(-range, range);",
            "mathf_chance_delta": "public static boolean chanceDelta(double d){",
            "mathf_chance_delta_body": "return rand.nextFloat() < d * Time.delta;",
            "tmp_v1": "public static final Vec2 v1 = new Vec2();",
            "vec2_rnd": "public Vec2 rnd(float length){",
            "vec2_rnd_body": "setToRandomDirection().scl(length);",
            "effect_at_xy": "public void at(float x, float y){",
            "effect_at_xy_body": "create(x, y, 0, Color.white, null);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_falling_engine_trail_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_falling_engine_trail_source"))
        report = source_parity.verify_unit_update_falling_engine_trail_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "thruster_fall_trail_comment": "//thruster fall trail",
            "thruster_chance": "if(Mathf.chanceDelta(0.2)){",
            "thruster_offset": "float offset = type.engineOffset/2f + type.engineOffset/2f * elevation;",
            "thruster_range": "float range = Mathf.range(type.engineSize);",
            "thruster_effect_call": "type.fallEngineEffect.at(",
            "thruster_effect_x": "x + Angles.trnsx(rotation + 180, offset) + Mathf.range(range),",
            "thruster_effect_y": "y + Angles.trnsy(rotation + 180, offset) + Mathf.range(range),",
            "thruster_effect_rotation": "Mathf.random()",
            "unit_type_fall_engine_effect": "public Effect fallEngineEffect = Fx.fallSmoke;",
            "unit_engine_offset": "engineOffset = 5f,",
            "unit_engine_size": "engineSize = 2.5f,",
            "mathf_chance_delta": "public static boolean chanceDelta(double d){",
            "mathf_range_float": "public static float range(float range){",
            "mathf_random": "public static float random(){",
            "angles_trnsx": "public static float trnsx(float angle, float len){",
            "angles_trnsx_body": "return len * Mathf.cosDeg(angle);",
            "angles_trnsy": "public static float trnsy(float angle, float len){",
            "angles_trnsy_body": "return len * Mathf.sinDeg(angle);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_falling_descent_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_falling_descent_source"))
        report = source_parity.verify_unit_update_falling_descent_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "move_down_comment": "//move down",
            "fall_descent": "elevation -= type.fallSpeed * Time.delta;",
            "destroy_guard": "if(isGrounded() || health <= -maxHealth * type.wreckHealthMultiplier){",
            "unit_destroy_call": "Call.unitDestroy(id);",
            "unit_type_fall_speed": "fallSpeed = 0.018f,",
            "unit_type_wreck_health_multiplier": "wreckHealthMultiplier = 0.25f,",
            "time_delta": "public static float delta = 1f;",
            "units_unit_destroy_remote": "@Remote(called = Loc.server)",
            "units_unit_destroy": "public static void unitDestroy(int uid){",
            "units_destroy_body": "unit.destroy();",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_tile_unit_on_any_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_tile_unit_on_any_source"))
        report = source_parity.verify_unit_update_tile_unit_on_any_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["building_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["tile_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(report["checked"], {
            "tile_build_guard": "if(tile != null && tile.build != null){",
            "tile_build_unit_on_any": "tile.build.unitOnAny(self());",
            "tile_build_field": "public @Nullable Building build;",
            "building_unit_on_any_comment": "/** Called every frame a unit is on this. Applies to any unit.  */",
            "building_unit_on_any": "public void unitOnAny(Unit unit){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_tile_unit_on_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_tile_unit_on_source"))
        report = source_parity.verify_unit_update_tile_unit_on_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["building_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["tile_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "grounded_tile_guard": "if(tile != null && isGrounded() && !type.hovering){",
            "unit_block_update_comment": "//unit block update",
            "tile_build_guard": "if(tile.build != null){",
            "tile_build_unit_on": "tile.build.unitOn(self());",
            "apply_damage_comment": "//apply damage",
            "tile_build_field": "public @Nullable Building build;",
            "unit_type_hovering_default": "hovering = false,",
            "building_unit_on_comment": "/** Called every frame a unit is on this. Hovering/flying/steppy units do not apply.  */",
            "building_unit_on": "public void unitOn(Unit unit){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_floor_damage_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_floor_damage_source"))
        report = source_parity.verify_unit_update_floor_damage_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["floor_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["health_source"], "core/src/mindustry/entities/comp/HealthComp.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "grounded_tile_guard": "if(tile != null && isGrounded() && !type.hovering){",
            "apply_damage_comment": "//apply damage",
            "floor_damage_guard": "if(floor.damageTaken > 0f){",
            "floor_damage_call": "damageContinuous(floor.damageTaken);",
            "floor_damage_taken_default": "public float damageTaken = 0f;",
            "floor_damages": "return damageTaken > 0f || (status != null && status.damage > 0f);",
            "health_damage_continuous": "void damageContinuous(float amount){",
            "health_damage_continuous_body": "damage(amount * Time.delta, hitTime <= -10 + hitDuration);",
            "time_delta": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_solid_tile_response_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_solid_tile_response_source"))
        report = source_parity.verify_unit_update_solid_tile_response_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["vel_source"], "core/src/mindustry/entities/comp/VelComp.java")
        self.assertEqual(report["entity_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["net_source"], "core/src/mindustry/net/Net.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["checked"], {
            "solid_tile_comment": "//kill entities on tiles that are solid to them",
            "solid_tile_guard": "if(tile != null && !canPassOn()){",
            "boost_comment": "//boost if possible",
            "can_boost_guard": "if(type.canBoost){",
            "boost_elevation": "elevation = 1f;",
            "kill_guard": "else if(!net.client() && !(!headless && isRemote())){",
            "kill_call": "kill();",
            "unit_type_can_boost_default": "canBoost = false,",
            "vel_can_pass_on": "boolean canPassOn(){",
            "vel_can_pass_on_body": "return canPass(tileX(), tileY());",
            "entity_is_remote": "boolean isRemote(){",
            "entity_is_remote_body": "return ((Object)this) instanceof Unitc u && u.isPlayer() && !isLocal();",
            "net_client": "public boolean client(){",
            "net_client_body": "return !server && active;",
            "vars_headless": "public static boolean headless;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_ai_controller_server_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_ai_controller_server_gate_source"))
        report = source_parity.verify_unit_update_ai_controller_server_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_controller_source"], "core/src/mindustry/entities/units/UnitController.java")
        self.assertEqual(report["net_source"], "core/src/mindustry/net/Net.java")
        self.assertEqual(report["checked"], {
            "controller_field": "private UnitController controller;",
            "dead_import": "@Import boolean dead, disarmed;",
            "ai_server_comment": "//AI only updates on the server",
            "ai_server_guard": "if(!net.client() && !dead && shouldUpdateController()){",
            "controller_update_call": "controller.updateUnit();",
            "should_update_method": "public boolean shouldUpdateController(){",
            "should_update_default": "return true;",
            "unit_controller_update": "default void updateUnit(){",
            "net_client": "public boolean client(){",
            "net_client_body": "return !server && active;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_invalid_controller_reset_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_invalid_controller_reset_source"))
        report = source_parity.verify_unit_update_invalid_controller_reset_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_controller_source"], "core/src/mindustry/entities/units/UnitController.java")
        self.assertEqual(report["checked"], {
            "clear_controller_comment": "//clear controller when it becomes invalid",
            "invalid_controller_guard": "if(!controller.isValidController()){",
            "reset_controller_call": "resetController();",
            "reset_controller_method": "public void resetController(){",
            "reset_controller_body": "controller(type.createController(self()));",
            "controller_setter": "public void controller(UnitController next){",
            "controller_unit_sync": "if(controller.unit() != self()) controller.unit(self());",
            "unit_controller_is_valid": "default boolean isValidController(){",
            "unit_controller_is_valid_default": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_spawned_core_despawn_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_spawned_core_despawn_source"))
        report = source_parity.verify_unit_update_spawned_core_despawn_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["checked"], {
            "spawned_by_core_field": "boolean spawnedByCore;",
            "dead_import": "@Import boolean dead, disarmed;",
            "core_despawn_comment": "//remove units spawned by the core",
            "core_despawn_guard": "if(spawnedByCore && !isPlayer() && !dead){",
            "core_despawn_call": "Call.unitDespawn(self());",
            "is_player_method": "public boolean isPlayer(){",
            "is_player_body": "return controller instanceof Player;",
            "unit_despawn_remote": "@Remote(called = Loc.server)",
            "unit_despawn_method": "public static void unitDespawn(Unit unit){",
            "unit_despawn_null_guard": "if(unit == null) return;",
            "unit_despawn_effect": "Fx.unitDespawn.at(unit.x, unit.y, 0, unit);",
            "unit_despawn_remove": "unit.remove();",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_icon_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_icon_source"))
        report = source_parity.verify_unit_icon_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unlockable_content_source"], "core/src/mindustry/ctype/UnlockableContent.java")
        self.assertEqual(report["checked"], {
            "icon_comment": "/** @return a preview UI icon for this unit. */",
            "icon_method": "public TextureRegion icon(){",
            "icon_return": "return type.uiIcon;",
            "unlockable_ui_icon": "public TextureRegion uiIcon;",
            "unlockable_ui_icon_load": "uiIcon = Core.atlas.find(getContentType().name() + \"-\" + name + \"-ui\", fullIcon);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_initial_payload_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_initial_payload_source"))
        report = source_parity.verify_unit_destroy_initial_payload_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["entity_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["items_source"], "core/src/mindustry/entities/comp/ItemsComp.java")
        self.assertEqual(report["item_source"], "core/src/mindustry/type/Item.java")
        self.assertEqual(report["item_stack_source"], "core/src/mindustry/type/ItemStack.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "destroy_comment": "/** Actually destroys the unit, removing it and creating explosions. **/",
            "destroy_method": "public void destroy(){",
            "destroy_guard": "if(!isAdded() || !killable()) return;",
            "explosiveness_formula": "float explosiveness = 2f + item().explosiveness * stack().amount * 1.53f;",
            "flammability_formula": "float flammability = item().flammability * stack().amount / 1.9f;",
            "power_formula": "float power = item().charge * Mathf.pow(stack().amount, 1.11f) * 160f;",
            "entity_is_added": "boolean isAdded(){",
            "entity_is_added_body": "return added;",
            "unit_killable": "public boolean killable(){",
            "unit_killable_body": "return type.killable(self());",
            "items_item": "Item item(){",
            "items_item_body": "return stack.item;",
            "item_explosiveness": "public float explosiveness = 0f;",
            "item_flammability": "public float flammability = 0f;",
            "item_charge": "public float charge = 0f;",
            "item_stack_amount": "public int amount = 0;",
            "mathf_pow": "public static float pow(float a, float b){",
            "mathf_pow_body": "return (float)Math.pow(a, b);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_explosion_dispatch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_explosion_dispatch_source"))
        report = source_parity.verify_unit_destroy_explosion_dispatch_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["damage_source"], "core/src/mindustry/entities/Damage.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["checked"], {
            "destroy_not_spawned_guard": "if(!spawnedByCore){",
            "destroy_dynamic_explosion_call": "Damage.dynamicExplosion(x, y, flammability, explosiveness, power, (bounds() + type.legLength/1.7f) / 2f, state.rules.damageExplosions && state.rules.unitCrashDamage(team) > 0, item().flammability > 1, team, type.deathExplosionEffect, 0f);",
            "destroy_spawned_core_else": "}else{",
            "destroy_spawned_core_effect": "type.deathExplosionEffect.at(x, y, bounds() / 2f / 8f);",
            "unit_death_explosion_effect": "public Effect deathExplosionEffect = Fx.dynamicExplosion;",
            "unit_leg_length": "public float legLength = 10f,",
            "damage_dynamic_explosion_overload": "public static void dynamicExplosion(float x, float y, float flammability, float explosiveness, float power, float radius, boolean damage, boolean fire, @Nullable Team ignoreTeam, Effect explosionFx, float baseShake){",
            "rules_unit_crash_damage": "public float unitCrashDamage(Team team){",
            "rules_unit_crash_damage_body": "return unitDamage(team) * unitCrashDamageMultiplier * teams.get(team).unitCrashDamageMultiplier;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_visual_effects_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_visual_effects_source"))
        report = source_parity.verify_unit_destroy_visual_effects_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["checked"], {
            "destroy_shake_formula": "float shake = type.deathShake < 0 ? 3f + hitSize / 3f : type.deathShake;",
            "destroy_create_scorch_guard": "if(type.createScorch){",
            "destroy_scorch_call": "Effect.scorch(x, y, (int)(hitSize / 5));",
            "destroy_shake_call": "Effect.shake(shake, shake, this);",
            "unit_hit_size_default": "hitSize = 6f,",
            "unit_death_shake_default": "deathShake = -1f,",
            "unit_create_scorch_default": "createScorch = true,",
            "effect_shake_position_overload": "public static void shake(float intensity, float duration, Position loc){",
            "effect_shake_position_body": "shake(intensity, duration, loc.getX(), loc.getY());",
            "effect_scorch_method": "public static void scorch(float x, float y, int size){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_sound_and_event_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_sound_and_event_source"))
        report = source_parity.verify_unit_destroy_sound_and_event_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["event_type_source"], "core/src/mindustry/game/EventType.java")
        self.assertEqual(report["arc_sound_source"], "arc-core/src/arc/audio/Sound.java")
        self.assertEqual(report["arc_events_source"], "arc-core/src/arc/Events.java")
        self.assertEqual(report["checked"], {
            "destroy_death_sound_call": "type.deathSound.at(this, 1f, type.deathSoundVolume);",
            "destroy_unit_destroy_event": "Events.fire(new UnitDestroyEvent(self()));",
            "unit_death_sound_field": "public Sound deathSound = Sounds.unset;",
            "unit_death_sound_volume": "public float deathSoundVolume = 1f;",
            "sound_at_position": "public int at(Position pos, float pitch, float volume){",
            "sound_at_position_body": "return at(pos.getX(), pos.getY(), pitch, volume);",
            "unit_destroy_event_class": "public static class UnitDestroyEvent{",
            "unit_destroy_event_unit": "public final Unit unit;",
            "unit_destroy_event_constructor": "public UnitDestroyEvent(Unit unit){",
            "arc_events_fire_object": "public static <T> void fire(T type){",
            "arc_events_fire_object_body": "fire(type.getClass(), type);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_suicide_bomb_trigger_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_suicide_bomb_trigger_source"))
        report = source_parity.verify_unit_destroy_suicide_bomb_trigger_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["entity_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["event_type_source"], "core/src/mindustry/game/EventType.java")
        self.assertEqual(report["arc_events_source"], "arc-core/src/arc/Events.java")
        self.assertEqual(report["checked"], {
            "was_player_field": "private transient boolean wasPlayer;",
            "destroy_suicide_bomb_guard": "if(explosiveness > 7f && (isLocal() || wasPlayer)){",
            "destroy_suicide_bomb_event": "Events.fire(Trigger.suicideBomb);",
            "entity_is_local": "boolean isLocal(){",
            "entity_is_local_body": "return ((Object)this) == player || ((Object)this) instanceof Unitc u && u.controller() == player;",
            "killed_was_player": "wasPlayer = isLocal();",
            "trigger_suicide_bomb": "suicideBomb,",
            "arc_events_fire_enum": "public static <T extends Enum<T>> void fire(Enum<T> type){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_shoot_on_death_mounts_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_shoot_on_death_mounts_source"))
        report = source_parity.verify_unit_destroy_shoot_on_death_mounts_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "mounts_import": "@Import WeaponMount[] mounts;",
            "has_target_field": "transient boolean hasTarget;",
            "destroy_mount_loop": "for(WeaponMount mount : mounts){",
            "destroy_shoot_on_death_guard": "if(mount.weapon.shootOnDeath && !(mount.weapon.bullet.killShooter && mount.totalShots > 0)){",
            "destroy_shoot_on_death_effect_guard": "if(mount.weapon.shootOnDeathEffect != null && !hasTarget){",
            "destroy_allow_shoot_effects_false": "mount.allowShootEffects = false;",
            "destroy_shoot_on_death_effect_at": "mount.weapon.shootOnDeathEffect.at(x, y, rotation);",
            "destroy_mount_reload_zero": "mount.reload = 0f;",
            "destroy_mount_shoot_true": "mount.shoot = true;",
            "destroy_weapon_update": "mount.weapon.update(self(), mount);",
            "weapon_shoot_on_death": "public boolean shootOnDeath = false;",
            "weapon_shoot_on_death_effect": "public @Nullable Effect shootOnDeathEffect = null;",
            "weapon_mount_weapon": "public final Weapon weapon;",
            "weapon_mount_reload": "public float reload;",
            "weapon_mount_shoot": "public boolean shoot = false;",
            "weapon_mount_allow_effects": "public boolean allowShootEffects = true;",
            "weapon_mount_total_shots": "public int totalShots;",
            "bullet_type_kill_shooter": "public boolean killShooter;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_crash_landing_damage_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_crash_landing_damage_source"))
        report = source_parity.verify_unit_destroy_crash_landing_damage_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["rules_source"], "core/src/mindustry/game/Rules.java")
        self.assertEqual(report["damage_source"], "core/src/mindustry/entities/Damage.java")
        self.assertEqual(report["explosion_shield_source"], "core/src/mindustry/world/blocks/ExplosionShield.java")
        self.assertEqual(report["block_flag_source"], "core/src/mindustry/world/meta/BlockFlag.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "destroy_crash_landing_comment": "//if this unit crash landed (was flying), damage stuff in a radius",
            "destroy_crash_landing_guard": "if(type.flying && !spawnedByCore && type.createWreck && state.rules.unitCrashDamage(team) > 0){",
            "destroy_shield_lookup": "var shields = indexer.getEnemy(team, BlockFlag.shield);",
            "destroy_crash_damage_formula": "float crashDamage = Mathf.pow(hitSize, 0.75f) * type.crashDamageMultiplier * 2.5f * state.rules.unitCrashDamage(team);",
            "destroy_shield_absorb_guard": "if(shields.isEmpty() || !shields.contains(b -> b instanceof ExplosionShield s && s.absorbExplosion(x, y, crashDamage))){",
            "destroy_damage_call": "Damage.damage(team, x, y, Mathf.pow(hitSize, 0.94f) * 1.25f, crashDamage, true, false, true);",
            "unit_type_crash_damage_multiplier": "crashDamageMultiplier = 1f,",
            "unit_type_flying": "flying = false,",
            "unit_type_create_wreck": "createWreck = true,",
            "rules_unit_crash_damage_multiplier": "public float unitCrashDamageMultiplier = 1f;",
            "rules_unit_crash_damage": "return unitDamage(team) * unitCrashDamageMultiplier * teams.get(team).unitCrashDamageMultiplier;",
            "team_rules_unit_crash_damage_multiplier": "public float unitCrashDamageMultiplier = 1f;",
            "explosion_shield_absorb": "boolean absorbExplosion(float x, float y, float damage);",
            "block_flag_shield": "shield,",
            "damage_overload": "public static void damage(Team team, float x, float y, float radius, float damage, boolean complete, boolean air, boolean ground){",
            "mathf_pow_float": "public static float pow(float a, float b){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_wreck_decal_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_wreck_decal_source"))
        report = source_parity.verify_unit_destroy_wreck_decal_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["texture_region_source"], "arc-core/src/arc/graphics/g2d/TextureRegion.java")
        self.assertEqual(report["tmp_source"], "arc-core/src/arc/util/Tmp.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "vars_static_import": "import static mindustry.Vars.*;",
            "destroy_wreck_decal_guard": "if(!headless && type.createScorch){",
            "destroy_wreck_region_loop": "for(int i = 0; i < type.wreckRegions.length; i++){",
            "destroy_wreck_region_found_guard": "if(type.wreckRegions[i].found()){",
            "destroy_wreck_range": "float range = type.hitSize /4f;",
            "destroy_tmp_rnd": "Tmp.v1.rnd(range);",
            "destroy_decal_call": "Effect.decal(type.wreckRegions[i], x + Tmp.v1.x, y + Tmp.v1.y, rotation - 90);",
            "unit_type_hit_size": "hitSize = 6f,",
            "unit_type_create_scorch": "createScorch = true,",
            "unit_type_wreck_regions": "public TextureRegion[] wreckRegions, segmentRegions, segmentCellRegions, segmentOutlineRegions;",
            "unit_type_wreck_region_init": "wreckRegions = new TextureRegion[3];",
            "unit_type_wreck_region_load": "wreckRegions[i] = Core.atlas.find(name + \"-wreck\" + i);",
            "vars_headless": "public static boolean headless;",
            "texture_region_found": "public boolean found(){",
            "effect_decal_overload": "public static void decal(TextureRegion region, float x, float y, float rotation){",
            "tmp_v1": "public static final Vec2 v1 = new Vec2();",
            "vec2_rnd": "public Vec2 rnd(float length){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_ability_death_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_ability_death_source"))
        report = source_parity.verify_unit_destroy_ability_death_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["ability_source"], "core/src/mindustry/entities/abilities/Ability.java")
        self.assertEqual(report["checked"], {
            "ability_import": "import mindustry.entities.abilities.*;",
            "abilities_field": "Ability[] abilities = {};",
            "destroy_ability_loop": "for(Ability a : abilities){",
            "destroy_ability_death_call": "a.death(self());",
            "ability_death_default": "public void death(Unit unit){}",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_destroy_type_killed_remove_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_destroy_type_killed_remove_source"))
        report = source_parity.verify_unit_destroy_type_killed_remove_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "destroy_type_killed_call": "type.killed(self());",
            "destroy_remove_call": "remove();",
            "unit_type_killed_default": "public void killed(Unit unit){}",
            "unit_remove_override": "@Override\n    public void remove(){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_killed_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_killed_state_source"))
        report = source_parity.verify_unit_killed_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["entity_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["sound_source"], "arc-core/src/arc/audio/Sound.java")
        self.assertEqual(report["checked"], {
            "was_player_field": "private transient boolean wasPlayer;",
            "killed_method": "public void killed(){",
            "killed_was_player": "wasPlayer = isLocal();",
            "entity_is_local": "boolean isLocal(){",
            "entity_is_local_controller": "return ((Object)this) == player || ((Object)this) instanceof Unitc u && u.controller() == player;",
            "killed_health_clamp": "health = Math.min(health, 0);",
            "killed_dead_assignment": "dead = true;",
            "killed_destroy_guard": "if(!type.flying || !type.createWreck){",
            "killed_destroy_call": "destroy();",
            "killed_wreck_sound_call": "type.wreckSound.at(this, 1f, type.wreckSoundVolume);",
            "unit_type_create_wreck": "createWreck = true,",
            "unit_type_wreck_sound": "public Sound wreckSound = Sounds.unset;",
            "unit_type_wreck_sound_volume": "public float wreckSoundVolume = 1f;",
            "sound_at_position_pitch_volume": "public int at(Position pos, float pitch, float volume){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_kill_sync_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_kill_sync_source"))
        report = source_parity.verify_unit_kill_sync_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["checked"], {
            "kill_replace": "@Replace\n    public void kill(){",
            "kill_guard": "if(dead || net.client() || !killable()) return;",
            "kill_sync_comment": "//deaths are synced; this calls killed()",
            "kill_call": "Call.unitDeath(id);",
            "unit_killable": "public boolean killable(){",
            "unit_killable_delegate": "return type.killable(self());",
            "unit_death_remote": "@Remote(called = Loc.server)",
            "unit_death_method": "public static void unitDeath(int uid){",
            "unit_death_lookup": "Unit unit = Groups.unit.getByID(uid);",
            "unit_death_removed_entity": "netClient.addRemovedEntity(uid);",
            "unit_death_killed": "unit.killed();",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_setup_mounts_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_setup_mounts_source"))
        report = source_parity.verify_weapons_setup_mounts_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "mounts_field": "@SyncLocal WeaponMount[] mounts = {};",
            "setup_method": "void setupWeapons(UnitType def){",
            "setup_array": "mounts = new WeaponMount[def.weapons.size];",
            "setup_loop": "for(int i = 0; i < mounts.length; i++){",
            "setup_mount_type_get": "mounts[i] = def.weapons.get(i).mountType.get(def.weapons.get(i));",
            "unit_type_weapons": "public Seq<Weapon> weapons = new Seq<>();",
            "weapon_mount_type": "public Func<Weapon, WeaponMount> mountType = WeaponMount::new;",
            "weapon_mount_constructor": "public WeaponMount(Weapon weapon){",
            "weapon_mount_weapon": "this.weapon = weapon;",
            "weapon_mount_base_rotation": "this.rotation = weapon.baseRotation;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_set_rotation_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_set_rotation_source"))
        report = source_parity.verify_weapons_set_rotation_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "mounts_field": "@SyncLocal WeaponMount[] mounts = {};",
            "set_rotation_method": "void setWeaponRotation(float rotation){",
            "set_rotation_loop": "for(WeaponMount mount : mounts){",
            "set_rotation_assignment": "mount.rotation = rotation;",
            "weapon_mount_rotation": "public float rotation;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_control_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_control_source"))
        report = source_parity.verify_weapons_control_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "is_rotate_field": "@ReadOnly transient boolean isRotate;",
            "is_shooting_field": "boolean isShooting;",
            "control_single_method": "void controlWeapons(boolean rotateShoot){",
            "control_single_delegate": "controlWeapons(rotateShoot, rotateShoot);",
            "control_pair_method": "void controlWeapons(boolean rotate, boolean shoot){",
            "control_loop": "for(WeaponMount mount : mounts){",
            "control_controllable_guard": "if(mount.weapon.controllable){",
            "control_rotate_assignment": "mount.rotate = rotate;",
            "control_shoot_assignment": "mount.shoot = shoot;",
            "control_is_rotate": "isRotate = rotate;",
            "control_is_shooting": "isShooting = shoot;",
            "weapon_controllable": "public boolean controllable = true;",
            "weapon_mount_shoot": "public boolean shoot = false;",
            "weapon_mount_rotate": "public boolean rotate = false;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_aim_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_aim_source"))
        report = source_parity.verify_weapons_aim_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["arc_position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["arc_tmp_source"], "arc-core/src/arc/util/Tmp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "aim_position_method": "void aim(Position pos){",
            "aim_position_delegate": "aim(pos.getX(), pos.getY());",
            "aim_float_method": "void aim(float x, float y){",
            "aim_tmp_set_sub": "Tmp.v1.set(x, y).sub(this.x, this.y);",
            "aim_dst_guard": "if(Tmp.v1.len() < type.aimDst) Tmp.v1.setLength(type.aimDst);",
            "aim_x_adjust": "x = Tmp.v1.x + this.x;",
            "aim_y_adjust": "y = Tmp.v1.y + this.y;",
            "aim_loop": "for(WeaponMount mount : mounts){",
            "aim_controllable_guard": "if(mount.weapon.controllable){",
            "aim_mount_x": "mount.aimX = x;",
            "aim_mount_y": "mount.aimY = y;",
            "aim_unit_x": "aimX = x;",
            "aim_unit_y": "aimY = y;",
            "unit_type_aim_dst": "aimDst = -1f,",
            "weapon_controllable": "public boolean controllable = true;",
            "weapon_mount_aim": "public float aimX, aimY;",
            "position_get_x": "float getX();",
            "position_get_y": "float getY();",
            "tmp_v1": "public static final Vec2 v1 = new Vec2();",
            "vec2_set_length": "public Vec2 setLength(float len){",
            "vec2_set_length_zero_noop": "return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_can_shoot_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_can_shoot_source"))
        report = source_parity.verify_weapons_can_shoot_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["checked"], {
            "disarmed_import": "@Import boolean disarmed;",
            "can_shoot_method": "boolean canShoot(){",
            "can_shoot_return": "return !disarmed;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_remove_continuous_bullet_cleanup_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_remove_continuous_bullet_cleanup_source"))
        report = source_parity.verify_weapons_remove_continuous_bullet_cleanup_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "remove_override": "@Override\n    public void remove(){",
            "remove_loop": "for(WeaponMount mount : mounts){",
            "continuous_bullet_guard": "if(mount.weapon.continuous && mount.bullet != null && mount.bullet.owner == self()){",
            "bullet_time_assignment": "mount.bullet.time = mount.bullet.lifetime - 10f;",
            "bullet_clear": "mount.bullet = null;",
            "weapon_continuous": "public boolean continuous;",
            "weapon_mount_bullet": "public @Nullable Bullet bullet;",
            "bullet_owner": "@Import Entityc owner;",
            "bullet_time_lifetime": "@Import float x, y, damage, lastX, lastY, time, lifetime;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_remove_sound_stop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_remove_sound_stop_source"))
        report = source_parity.verify_weapons_remove_sound_stop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["sound_loop_source"], "core/src/mindustry/audio/SoundLoop.java")
        self.assertEqual(report["checked"], {
            "remove_override": "@Override\n    public void remove(){",
            "remove_loop": "for(WeaponMount mount : mounts){",
            "sound_guard": "if(mount.sound != null){",
            "sound_stop_call": "mount.sound.stop();",
            "weapon_mount_sound_comment": "/** sound loop for continuous weapons */",
            "weapon_mount_sound": "public @Nullable SoundLoop sound;",
            "sound_loop_stop_method": "public void stop(){",
            "sound_loop_id_guard": "if(id != -1){",
            "sound_loop_core_stop": "Core.audio.stop(id);",
            "sound_loop_id_reset": "id = -1;",
            "sound_loop_volume_reset": "volume = 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapons_update_dispatch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapons_update_dispatch_source"))
        report = source_parity.verify_weapons_update_dispatch_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["weapon_source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["checked"], {
            "mounts_field_comment": "/** weapon mount array, never null */",
            "mounts_field": "@SyncLocal WeaponMount[] mounts = {};",
            "update_comment": "/** Update shooting and rotation for this unit. */",
            "update_override": "@Override\n    public void update(){",
            "update_loop": "for(WeaponMount mount : mounts){",
            "weapon_update_call": "mount.weapon.update(self(), mount);",
            "weapon_mount_weapon_comment": "/** weapon associated with this mount */",
            "weapon_mount_weapon": "public final Weapon weapon;",
            "weapon_update_method": "public void update(Unit unit, WeaponMount mount){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_passive_timers_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_passive_timers_source"))
        report = source_parity.verify_weapon_update_passive_timers_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["unit_comp_source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["status_comp_source"], "core/src/mindustry/entities/comp/StatusComp.java")
        self.assertEqual(report["shoot_pattern_source"], "core/src/mindustry/entities/pattern/ShootPattern.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "weapon_update_method": "public void update(Unit unit, WeaponMount mount){",
            "can_shoot_call": "boolean can = unit.canShoot();",
            "last_reload": "float lastReload = mount.reload;",
            "reload_decay": "mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);",
            "recoil_approach": "mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);",
            "recoils_guard": "if(recoils > 0){",
            "recoils_init": "if(mount.recoils == null) mount.recoils = new float[recoils];",
            "recoils_loop": "for(int i = 0; i < recoils; i++){",
            "recoils_approach": "mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);",
            "smooth_reload": "mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);",
            "charge_update": "mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;",
            "warmup_target": "float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;",
            "linear_warmup_guard": "if(linearWarmup){",
            "warmup_approach": "mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);",
            "warmup_lerp": "mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);",
            "weapon_reload_field": "public float reload = 1;",
            "weapon_recoils_field": "public int recoils = -1;",
            "weapon_recoil_time_field": "public float recoilTime = -1f;",
            "weapon_warmup_fields": "public float shootWarmupSpeed = 0.1f, smoothReloadSpeed = 0.15f;",
            "weapon_linear_warmup": "public boolean linearWarmup = false;",
            "weapon_mount_reload": "public float reload;",
            "weapon_mount_recoils": "public @Nullable float[] recoils;",
            "weapon_mount_warmup": "public float warmup;",
            "unit_can_shoot": "return !disarmed && !(type.canBoost && isFlying());",
            "status_reload_multiplier": "reloadMultiplier = 1",
            "shoot_first_delay": "public float firstShotDelay = 0;",
            "time_delta": "public static float delta = 1f;",
            "mathf_approach_delta": "public static float approachDelta(float from, float to, float speed){",
            "mathf_approach_delta_return": "return approach(from, to, Time.delta * speed);",
            "mathf_lerp_delta": "public static float lerpDelta(float fromValue, float toValue, float progress){",
            "mathf_lerp_delta_return": "return lerp(fromValue, toValue, clamp(progress * Time.delta));",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_mount_origin_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_mount_origin_source"))
        report = source_parity.verify_weapon_update_mount_origin_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["unit_comp_source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "weapon_update_method": "public void update(Unit unit, WeaponMount mount){",
            "mount_origin_block": "float\n        mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),\n        mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);",
            "weapon_mount_offsets": "public float x = 5f, y = 0f;",
            "unit_imports": "@Import float x, y, rotation, maxHealth, drag, armor, hitSize, health, shield, dragMultiplier, armorOverride, speedMultiplier;",
            "angles_trnsx_vec": "public static float trnsx(float angle, float x, float y){",
            "angles_trnsx_return": "return rv.set(x, y).rotate(angle).x;",
            "angles_trnsy_vec": "public static float trnsy(float angle, float x, float y){",
            "angles_trnsy_return": "return rv.set(x, y).rotate(angle).y;",
            "vec2_rotate_degrees": "public Vec2 rotate(float degrees){",
            "vec2_rotate_rad_call": "return rotateRad(degrees * Mathf.degreesToRadians);",
            "vec2_rotate_rad": "public Vec2 rotateRad(float radians){",
            "vec2_rotate_new_x": "float newX = this.x * cos - this.y * sin;",
            "vec2_rotate_new_y": "float newY = this.x * sin + this.y * cos;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_auto_target_retarget_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_auto_target_retarget_source"))
        report = source_parity.verify_weapon_update_auto_target_retarget_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "find_target_comment": "//find a new target",
            "auto_target_gate": "if(!controllable && autoTarget){",
            "retarget_decrement_gate": "if((mount.retarget -= Time.delta) <= 0f){",
            "find_target_call": "mount.target = findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround);",
            "retarget_assignment": "mount.retarget = mount.target == null ? targetInterval : targetSwitchInterval;",
            "weapon_controllable": "public boolean controllable = true;",
            "weapon_auto_target": "public boolean autoTarget = false;",
            "weapon_target_intervals": "public float targetInterval = 40f, targetSwitchInterval = 70f;",
            "weapon_mount_target": "public @Nullable Teamc target;",
            "weapon_mount_retarget_comment": "/** retarget counter */",
            "weapon_mount_retarget": "public float retarget = 0f;",
            "find_target_method": "protected Teamc findTarget(Unit unit, float x, float y, float range, boolean air, boolean ground){",
            "find_target_return": "return Units.closestTarget(unit.team, x, y, range + Math.abs(shootY), u -> u.checkTarget(air, ground), t -> ground && (unit.type.targetUnderBlocks || !t.block.underBullets));",
            "bullet_collision_fields": "public boolean collidesAir = true, collidesGround = true;",
            "bullet_range_field": "public float range = 0f;",
            "time_delta": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_auto_target_invalidation_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_auto_target_invalidation_source"))
        report = source_parity.verify_weapon_update_auto_target_invalidation_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["units_source"], "core/src/mindustry/entities/Units.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "auto_target_gate": "if(!controllable && autoTarget){",
            "check_target_guard": "if(mount.target != null && checkTarget(unit, mount.target, mountX, mountY, bullet.range)){",
            "target_clear": "mount.target = null;",
            "check_target_method": "protected boolean checkTarget(Unit unit, Teamc target, float x, float y, float range){",
            "check_target_return": "return Units.invalidateTarget(target, unit.team, x, y, range + Math.abs(shootY));",
            "units_invalidate_method": "public static boolean invalidateTarget(Posc target, Team team, float x, float y, float range){",
            "units_invalidate_null": "return target == null ||",
            "units_invalidate_range": "(range != Float.MAX_VALUE && !target.within(x, y, range + (target instanceof Sized hb ? hb.hitSize()/2f : 0f))) ||",
            "units_invalidate_team": "(target instanceof Teamc t && t.team() == team) ||",
            "units_invalidate_health": "(target instanceof Healthc h && !h.isValid()) ||",
            "units_invalidate_unit": "(target instanceof Unit u && !u.targetable(team));",
            "weapon_mount_target": "public @Nullable Teamc target;",
            "weapon_auto_target": "public boolean autoTarget = false;",
            "weapon_controllable": "public boolean controllable = true;",
            "weapon_shoot_offsets": "public float shootX = 0f, shootY = 3f;",
            "bullet_range_field": "public float range = 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_auto_target_shoot_aim_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_auto_target_shoot_aim_source"))
        report = source_parity.verify_weapon_update_auto_target_shoot_aim_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["predict_source"], "core/src/mindustry/entities/Predict.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "shoot_init": "boolean shoot = false;",
            "target_guard": "if(mount.target != null){",
            "shoot_assignment": "shoot = mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f)) && can;",
            "predict_guard": "if(predictTarget){",
            "predict_call": "Vec2 to = Predict.intercept(unit, mount.target, bullet);",
            "predict_aim_x": "mount.aimX = to.x;",
            "predict_aim_y": "mount.aimY = to.y;",
            "direct_aim_x": "mount.aimX = mount.target.x();",
            "direct_aim_y": "mount.aimY = mount.target.y();",
            "shoot_rotate_assignment": "mount.shoot = mount.rotate = shoot;",
            "logic_note": "//note that shooting state is not affected, as these cannot be controlled",
            "weapon_predict_target": "public boolean predictTarget = true;",
            "weapon_shoot_y": "public float shootX = 0f, shootY = 3f;",
            "weapon_mount_target": "public @Nullable Teamc target;",
            "weapon_mount_aim": "public float aimX, aimY;",
            "weapon_mount_shoot": "public boolean shoot = false;",
            "weapon_mount_rotate": "public boolean rotate = false;",
            "predict_intercept_bullet": "public static Vec2 intercept(Position src, Position dst, BulletType bullet){",
            "predict_intercept_bullet_return": "return intercept(src, dst, 0f, 0f, bullet.keepVelocity, bullet.speed);",
            "bullet_speed": "public float speed = 1f;",
            "bullet_keep_velocity": "public boolean keepVelocity = true;",
            "bullet_range": "public float range = 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_rotate_toward_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_rotate_toward_source"))
        report = source_parity.verify_weapon_update_rotate_toward_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "rotate_comment": "//rotate if applicable",
            "rotate_gate": "if(rotate && (mount.rotate || mount.shoot) && can){",
            "axis_x": "float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),",
            "axis_y": "axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);",
            "target_rotation": "mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;",
            "rotation_move_toward": "mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);",
            "weapon_rotate": "public boolean rotate = false;",
            "weapon_offsets": "public float x = 5f, y = 0f;",
            "weapon_rotate_speed": "public float rotateSpeed = 20f;",
            "weapon_mount_rotation": "public float rotation;",
            "weapon_mount_target_rotation": "public float targetRotation;",
            "weapon_mount_aim": "public float aimX, aimY;",
            "weapon_mount_shoot": "public boolean shoot = false;",
            "weapon_mount_rotate": "public boolean rotate = false;",
            "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
            "angles_angle_body": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
            "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
            "angles_move_toward_snap": "if(Math.abs(angleDist(angle, to)) < speed) return to;",
            "angles_move_toward_mod_angle": "angle = Mathf.mod(angle, 360f);",
            "angles_move_toward_mod_to": "to = Mathf.mod(to, 360f);",
            "angles_angle_dist": "public static float angleDist(float a, float b){",
            "mathf_mod": "public static float mod(float f, float n){",
            "time_delta": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_rotation_limit_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_rotation_limit_source"))
        report = source_parity.verify_weapon_update_rotation_limit_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "rotation_limit_guard": "if(rotationLimit < 360){",
            "limit_dst": "float dst = Angles.angleDist(mount.rotation, baseRotation);",
            "limit_guard": "if(dst > rotationLimit/2f){",
            "limit_move_toward": "mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);",
            "weapon_rotation_limit": "public float rotationLimit = 361f;",
            "weapon_base_rotation": "public float baseRotation = 0f;",
            "angles_angle_dist": "public static float angleDist(float a, float b){",
            "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_non_rotate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_non_rotate_source"))
        report = source_parity.verify_weapon_update_non_rotate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "non_rotate_guard": "}else if(!rotate){",
            "rotation_base": "mount.rotation = baseRotation;",
            "target_rotation_angle_to": "mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);",
            "weapon_rotate": "public boolean rotate = false;",
            "weapon_base_rotation": "public float baseRotation = 0f;",
            "weapon_mount_rotation": "public float rotation;",
            "weapon_mount_target_rotation": "public float targetRotation;",
            "weapon_mount_aim": "public float aimX, aimY;",
            "position_angle_to_float": "default float angleTo(float x, float y){",
            "position_angle_to_return": "return Angles.angle(getX(), getY(), x, y);",
            "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_bullet_origin_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_bullet_origin_source"))
        report = source_parity.verify_weapon_update_bullet_origin_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "weapon_rotation": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
            "bullet_x": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
            "bullet_y": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),",
            "shoot_angle": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY);",
            "bullet_rotation_method": "protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){",
            "bullet_rotation_return": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;",
            "weapon_rotate": "public boolean rotate = false;",
            "weapon_base_rotation": "public float baseRotation = 0f;",
            "weapon_shoot_offsets": "public float shootX = 0f, shootY = 3f;",
            "weapon_mount_rotation": "public float rotation;",
            "weapon_mount_aim": "public float aimX, aimY;",
            "angles_trnsx_vec": "public static float trnsx(float angle, float x, float y){",
            "angles_trnsy_vec": "public static float trnsy(float angle, float x, float y){",
            "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
            "position_angle_to_float": "default float angleTo(float x, float y){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_always_shooting_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_always_shooting_source"))
        report = source_parity.verify_weapon_update_always_shooting_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "always_shooting_assignment": "if(alwaysShooting) mount.shoot = true;",
            "weapon_always_shooting": "public boolean alwaysShooting = false;",
            "weapon_mount_shoot": "public boolean shoot = false;",
            "continuous_comment": "//update continuous state",
            "continuous_guard": "if(continuous && mount.bullet != null){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_continuous_invalidation_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_continuous_invalidation_source"))
        report = source_parity.verify_weapon_update_continuous_invalidation_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["timed_comp_source"], "core/src/mindustry/entities/comp/TimedComp.java")
        self.assertEqual(report["entity_comp_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["checked"], {
            "continuous_comment": "//update continuous state",
            "continuous_guard": "if(continuous && mount.bullet != null){",
            "continuous_invalid_condition": "if(!mount.bullet.isAdded() || mount.bullet.time >= mount.bullet.lifetime || mount.bullet.type != bullet){",
            "continuous_clear_bullet": "mount.bullet = null;",
            "weapon_continuous": "public boolean continuous;",
            "weapon_bullet": "public BulletType bullet = Bullets.placeholder;",
            "weapon_mount_bullet": "public @Nullable Bullet bullet;",
            "bullet_comp_type": "BulletType type;",
            "timed_comp_time_lifetime": "float time, lifetime;",
            "entity_comp_is_added": "boolean isAdded(){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_continuous_live_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_continuous_live_source"))
        report = source_parity.verify_weapon_update_continuous_live_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["unit_comp_source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "continuous_else": "}else{",
            "bullet_rotation_set": "mount.bullet.rotation(weaponRotation + 90);",
            "bullet_position_set": "mount.bullet.set(bulletX, bulletY);",
            "mount_reload_set": "mount.reload = reload;",
            "mount_recoil_set": "mount.recoil = 1f;",
            "unit_vel_recoil_add": "unit.vel.add(Tmp.v1.trns(mount.bullet.rotation() + 180f, mount.bullet.type.recoil * Time.delta));",
            "sound_guard_reserved": "if(shootSound != Sounds.none && !headless){",
            "weapon_reload": "public float reload = 1;",
            "weapon_mount_reload": "public float reload;",
            "weapon_mount_recoil": "public float recoil;",
            "bullet_type_recoil": "public float recoil;",
            "unit_vel": "@Import Vec2 vel;",
            "vec2_trns_amount": "public Vec2 trns(float angle, float amount){",
            "vec2_trns_amount_body": "return set(amount, 0).rotate(angle);",
            "vec2_add": "public Vec2 add(Vec2 v){",
            "time_delta": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_continuous_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_continuous_sound_source"))
        report = source_parity.verify_weapon_update_continuous_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["sound_loop_source"], "core/src/mindustry/audio/SoundLoop.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["checked"], {
            "sound_guard": "if(shootSound != Sounds.none && !headless){",
            "sound_create_guard": "if(mount.sound == null) mount.sound = new SoundLoop(shootSound, 1f);",
            "sound_update_call": "mount.sound.update(bulletX, bulletY, true);",
            "laser_length_reserved": "//target length of laser",
            "weapon_shoot_sound": "public Sound shootSound = Sounds.shoot;",
            "weapon_mount_sound_comment": "/** sound loop for continuous weapons */",
            "weapon_mount_sound": "public @Nullable SoundLoop sound;",
            "sound_loop_constructor": "public SoundLoop(Sound sound, float baseVolume){",
            "sound_loop_update": "public void update(float x, float y, boolean play){",
            "sound_loop_update_delegate": "update(x, y, play, 1f);",
            "vars_headless": "public static boolean headless;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_continuous_laser_aim_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_continuous_laser_aim_source"))
        report = source_parity.verify_weapon_update_continuous_laser_aim_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "target_length_comment": "//target length of laser",
            "shoot_length": "float shootLength = Math.min(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY), range());",
            "current_length_comment": "//current length of laser",
            "cur_length": "float curLength = Mathf.dst(bulletX, bulletY, mount.bullet.aimX, mount.bullet.aimY);",
            "result_length_comment": "//resulting length of the bullet (smoothed)",
            "result_length": "float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);",
            "aim_endpoint_comment": "//actual aim end point based on length",
            "tmp_trns_add": "Tmp.v1.trns(shootAngle, mount.lastLength = resultLength).add(bulletX, bulletY);",
            "bullet_aim_x": "mount.bullet.aimX = Tmp.v1.x;",
            "bullet_aim_y": "mount.bullet.aimY = Tmp.v1.y;",
            "always_continuous_reserved": "if(alwaysContinuous && mount.shoot){",
            "weapon_aim_change_speed": "public float aimChangeSpeed = Float.POSITIVE_INFINITY;",
            "weapon_range_method": "public float range(){",
            "weapon_range_return": "return bullet.range;",
            "weapon_mount_aim": "public float aimX, aimY;",
            "weapon_mount_last_length": "public float lastLength;",
            "bullet_comp_aim": "transient float aimX, aimY;",
            "bullet_type_range": "public float range = 0f;",
            "mathf_dst": "public static float dst(float x1, float y1, float x2, float y2){",
            "mathf_approach_delta": "public static float approachDelta(float from, float to, float speed){",
            "vec2_trns_amount": "public Vec2 trns(float angle, float amount){",
            "vec2_add_xy": "public Vec2 add(float x, float y){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_always_continuous_keepalive_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_always_continuous_keepalive_source"))
        report = source_parity.verify_weapon_update_always_continuous_keepalive_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["status_comp_source"], "core/src/mindustry/entities/comp/StatusComp.java")
        self.assertEqual(report["timed_comp_source"], "core/src/mindustry/entities/comp/TimedComp.java")
        self.assertEqual(report["checked"], {
            "always_continuous_guard": "if(alwaysContinuous && mount.shoot){",
            "bullet_time_assignment": "mount.bullet.time = mount.bullet.lifetime * mount.bullet.type.optimalLifeFract * mount.warmup;",
            "bullet_keep_alive": "mount.bullet.keepAlive = true;",
            "unit_apply": "unit.apply(shootStatus, shootStatusDuration);",
            "weapon_always_continuous": "public boolean alwaysContinuous;",
            "weapon_shoot_status": "public StatusEffect shootStatus = StatusEffects.none;",
            "weapon_shoot_status_duration": "public float shootStatusDuration = 60f * 5f;",
            "weapon_mount_shoot": "public boolean shoot = false;",
            "weapon_mount_warmup": "public float warmup;",
            "bullet_type_optimal_life_fract": "public float optimalLifeFract = 0f;",
            "bullet_comp_keep_alive": "transient boolean keepAlive;",
            "timed_comp_time_lifetime": "float time, lifetime;",
            "status_apply_method": "public void apply(StatusEffect effect, float duration){",
            "status_apply_guard": "if(effect == StatusEffects.none || effect == null || isImmune(effect)) return;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_continuous_idle_heat_sound_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_continuous_idle_heat_sound_source"))
        report = source_parity.verify_weapon_update_continuous_idle_heat_sound_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["status_comp_source"], "core/src/mindustry/entities/comp/StatusComp.java")
        self.assertEqual(report["sound_loop_source"], "core/src/mindustry/audio/SoundLoop.java")
        self.assertEqual(report["time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "continuous_else": "}else{",
            "heat_comment": "//heat decreases when not firing",
            "heat_decay": "mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);",
            "sound_guard": "if(mount.sound != null){",
            "sound_update_false": "mount.sound.update(bulletX, bulletY, false);",
            "weapon_cooldown_time": "public float cooldownTime = 20f;",
            "weapon_mount_heat": "public float heat;",
            "weapon_mount_sound": "public @Nullable SoundLoop sound;",
            "status_reload_multiplier": "reloadMultiplier = 1",
            "time_delta": "public static float delta = 1f;",
            "sound_loop_update": "public void update(float x, float y, boolean play){",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_alternating_side_flip_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_alternating_side_flip_source"))
        report = source_parity.verify_weapon_update_alternating_side_flip_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["weapons_comp_source"], "core/src/mindustry/entities/comp/WeaponsComp.java")
        self.assertEqual(report["checked"], {
            "last_reload": "float lastReload = mount.reload;",
            "flip_comment": "//flip weapon shoot side for alternating weapons",
            "was_flipped": "boolean wasFlipped = mount.side;",
            "flip_guard": "if(otherSide >= 0 && alternate && mount.side == flipSprite && otherSide < unit.mounts.length && mount.reload <= reload / 2f && lastReload > reload / 2f){",
            "other_side_flip": "unit.mounts[otherSide].side = !unit.mounts[otherSide].side;",
            "mount_side_flip": "mount.side = !mount.side;",
            "weapon_other_side": "public int otherSide = -1;",
            "weapon_alternate": "public boolean alternate = true;",
            "weapon_flip_sprite": "public boolean flipSprite = false;",
            "weapon_reload": "public float reload = 1;",
            "mount_side": "public boolean side;",
            "mount_reload": "public float reload;",
            "unit_mounts": "@SyncLocal WeaponMount[] mounts = {};",
            "shoot_gate_uses_was_flipped": "(!alternate || wasFlipped == flipSprite) &&",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_active_sound_loop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_active_sound_loop_source"))
        report = source_parity.verify_weapon_update_active_sound_loop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["sound_control_source"], "core/src/mindustry/audio/SoundControl.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "active_sound_guard": "if(!headless && activeSound != Sounds.none && mount.shoot && can && mount.warmup >= minWarmup){",
            "active_sound_loop": "Vars.control.sound.loop(activeSound, unit, activeSoundVolume);",
            "weapon_active_sound": "public Sound activeSound = Sounds.none;",
            "weapon_active_sound_volume": "public float activeSoundVolume = 1f;",
            "weapon_min_warmup": "public float minWarmup = 0f;",
            "mount_shoot": "public boolean shoot = false;",
            "mount_warmup": "public float warmup;",
            "vars_headless": "public static boolean headless;",
            "vars_control": "public static Control control;",
            "sound_control_loop_unit": "public void loop(Sound sound, Position pos, float volume){",
            "sound_control_loop_pitch": "public void loop(Sound sound, Position pos, float volume, float pitch){",
            "sound_control_guard": "if(Vars.headless || sound == Sounds.none || volume <= 0.00001f) return;",
            "vel_len_reserved": "float velLen = unit.isRemote() ? unit.vel.len() : unit.deltaLen() / Time.delta;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_velocity_length_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_velocity_length_source"))
        report = source_parity.verify_weapon_update_velocity_length_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["entity_comp_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["hitbox_comp_source"], "core/src/mindustry/entities/comp/HitboxComp.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "vel_len": "float velLen = unit.isRemote() ? unit.vel.len() : unit.deltaLen() / Time.delta;",
            "shoot_gate_uses_vel_len": "velLen >= minShootVelocity && //check velocity requirements",
            "entity_is_remote": "boolean isRemote(){\n        return ((Object)this) instanceof Unitc u && u.isPlayer() && !isLocal();\n    }",
            "hitbox_delta_len": "float deltaLen(){\n        return Mathf.len(deltaX, deltaY);\n    }",
            "vec2_len": "public float len(){\n        return (float)Math.sqrt(x * x + y * y);\n    }",
            "time_delta": "public static float delta = 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_shoot_gate_prefix_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_shoot_gate_prefix_source"))
        report = source_parity.verify_weapon_update_shoot_gate_prefix_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "shoot_comment": "//shoot if applicable",
            "mount_shoot_gate": "if(mount.shoot && //must be shooting",
            "can_gate": "can && //must be able to shoot",
            "kill_shooter_gate": "!(bullet.killShooter && mount.totalShots > 0) && //if the bullet kills the shooter, you should only ever be able to shoot once",
            "alternate_gate": "(!alternate || wasFlipped == flipSprite) &&",
            "warmup_gate": "mount.warmup >= minWarmup && //must be warmed up",
            "velocity_gate": "velLen >= minShootVelocity && //check velocity requirements",
            "weapon_alternate": "public boolean alternate = true;",
            "weapon_flip_sprite": "public boolean flipSprite = false;",
            "weapon_min_warmup": "public float minWarmup = 0f;",
            "weapon_min_shoot_velocity": "public float minShootVelocity = -1f;",
            "mount_shoot": "public boolean shoot = false;",
            "mount_warmup": "public float warmup;",
            "mount_total_shots": "public int totalShots;",
            "bullet_kill_shooter": "public boolean killShooter;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_reload_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_reload_gate_source"))
        report = source_parity.verify_weapon_update_reload_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "reload_gate": "(mount.reload <= 0.0001f || (alwaysContinuous && mount.bullet == null)) && //reload has to be 0, or it has to be an always-continuous weapon",
            "cone_gate_reserved": "(alwaysShooting || Angles.within(rotate ? mount.rotation : unit.rotation + baseRotation, mount.targetRotation, shootCone)) //has to be within the cone",
            "weapon_always_continuous": "public boolean alwaysContinuous;",
            "weapon_reload": "public float reload = 1;",
            "mount_reload": "public float reload;",
            "mount_bullet": "public @Nullable Bullet bullet;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_cone_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_cone_gate_source"))
        report = source_parity.verify_weapon_update_cone_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["rot_comp_source"], "core/src/mindustry/entities/comp/RotComp.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "cone_gate": "(alwaysShooting || Angles.within(rotate ? mount.rotation : unit.rotation + baseRotation, mount.targetRotation, shootCone)) //has to be within the cone",
            "shoot_call_reserved": "shoot(unit, mount, bulletX, bulletY, shootAngle);",
            "weapon_always_shooting": "public boolean alwaysShooting = false;",
            "weapon_rotate": "public boolean rotate = false;",
            "weapon_base_rotation": "public float baseRotation = 0f;",
            "weapon_shoot_cone": "public float shootCone = 5f;",
            "mount_rotation": "public float rotation;",
            "mount_target_rotation": "public float targetRotation;",
            "unit_rotation": "@SyncField(false) @SyncLocal float rotation;",
            "angles_within": "public static boolean within(float a, float b, float margin){\n        return angleDist(a, b) <= margin;\n    }",
            "angles_angle_dist": "public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_update_shoot_call_reload_reset_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_update_shoot_call_reload_reset_source"))
        report = source_parity.verify_weapon_update_shoot_call_reload_reset_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "shoot_call": "shoot(unit, mount, bulletX, bulletY, shootAngle);",
            "reload_reset": "mount.reload = reload;",
            "shoot_method": "protected void shoot(Unit unit, WeaponMount mount, float shootX, float shootY, float rotation){",
            "shoot_status_apply_reserved": "unit.apply(shootStatus, shootStatusDuration);",
            "weapon_reload": "public float reload = 1;",
            "mount_reload": "public float reload;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_shoot_charge_start_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_shoot_charge_start_source"))
        report = source_parity.verify_weapon_shoot_charge_start_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["shoot_pattern_source"], "core/src/mindustry/entities/pattern/ShootPattern.java")
        self.assertEqual(report["status_source"], "core/src/mindustry/entities/comp/StatusComp.java")
        self.assertEqual(report["bullet_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "shoot_method": "protected void shoot(Unit unit, WeaponMount mount, float shootX, float shootY, float rotation){",
            "status_apply": "unit.apply(shootStatus, shootStatusDuration);",
            "charge_gate": "if(shoot.firstShotDelay > 0){",
            "mount_charging": "mount.charging = true;",
            "charge_sound": "chargeSound.at(shootX, shootY, Mathf.random(soundPitchMin, soundPitchMax));",
            "charge_effect": "bullet.chargeEffect.at(shootX, shootY, rotation, bullet.keepVelocity || parentizeEffects ? unit : null);",
            "shoot_loop_reserved": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
            "weapon_parentize": "public boolean parentizeEffects;",
            "weapon_charge_sound": "public Sound chargeSound = Sounds.none;",
            "weapon_shoot_status": "public StatusEffect shootStatus = StatusEffects.none;",
            "weapon_shoot_status_duration": "public float shootStatusDuration = 60f * 5f;",
            "pattern_first_shot_delay": "public float firstShotDelay = 0;",
            "bullet_charge_effect": "public Effect chargeEffect = Fx.none;",
            "bullet_keep_velocity": "public boolean keepVelocity = true;",
            "status_apply_guard": "if(effect == StatusEffects.none || effect == null || isImmune(effect)) return;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_shoot_default_pattern_dispatch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_shoot_default_pattern_dispatch_source"))
        report = source_parity.verify_weapon_shoot_default_pattern_dispatch_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["shoot_pattern_source"], "core/src/mindustry/entities/pattern/ShootPattern.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["time_source"], "arc-core/src/arc/util/Time.java")
        self.assertEqual(report["checked"], {
            "shoot_dispatch": "shoot.shoot(mount.barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {",
            "total_shots_increment": "mount.totalShots ++;",
            "barrel_capture": "int barrel = mount.barrelCounter;",
            "delay_gate": "if(delay > 0f){",
            "time_run": "Time.run(delay, () -> {",
            "prev_barrel": "int prev = mount.barrelCounter;",
            "set_barrel": "mount.barrelCounter = barrel;",
            "delayed_bullet_call": "bullet(unit, mount, xOffset, yOffset, angle, mover);",
            "restore_barrel": "mount.barrelCounter = prev;",
            "direct_bullet_call": "}else{\n                bullet(unit, mount, xOffset, yOffset, angle, mover);",
            "barrel_incrementer": "}, () -> mount.barrelCounter++);",
            "pattern_shots": "public int shots = 1;",
            "pattern_first_shot_delay": "public float firstShotDelay = 0;",
            "pattern_shot_delay": "public float shotDelay = 0;",
            "pattern_dispatch_compat": "shoot(totalShots, handler);",
            "pattern_loop": "for(int i = 0; i < shots; i++){",
            "pattern_handler": "handler.shoot(0, 0, 0, firstShotDelay + shotDelay * i);",
            "mount_total_shots": "public int totalShots;",
            "mount_barrel_counter": "public int barrelCounter;",
            "time_run_method": "public static void run(float delay, Runnable r){",
            "time_run_delay": "run.delay = delay;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_initial_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_initial_guard_source"))
        report = source_parity.verify_weapon_bullet_initial_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["entity_source"], "core/src/mindustry/entities/comp/EntityComp.java")
        self.assertEqual(report["checked"], {
            "bullet_method": "protected void bullet(Unit unit, WeaponMount mount, float xOffset, float yOffset, float angleOffset, Mover mover){",
            "unit_added_guard": "if(!unit.isAdded()) return;",
            "charging_reset": "mount.charging = false;",
            "geometry_reserved": "float\n        xSpread = Mathf.range(xRand),",
            "mount_charging_field": "public boolean charging;",
            "entity_added_field": "private transient boolean added;",
            "entity_is_added": "boolean isAdded(){\n        return added;\n    }",
            "entity_add": "void add(){\n        added = true;\n    }",
            "entity_remove": "void remove(){\n        added = false;\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_geometry_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_geometry_source"))
        report = source_parity.verify_weapon_bullet_geometry_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "x_spread": "xSpread = Mathf.range(xRand),",
            "y_spread": "ySpread = Mathf.range(yRand),",
            "weapon_rotation": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
            "mount_x": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),",
            "mount_y": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y),",
            "bullet_x": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread),",
            "bullet_y": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread),",
            "shoot_angle_reserved": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset,",
            "weapon_rotate": "public boolean rotate = false;",
            "weapon_base_rotation": "public float baseRotation = 0f;",
            "weapon_shoot_offsets": "public float shootX = 0f, shootY = 3f;",
            "weapon_rand_offsets": "public float xRand = 0f, yRand = 0f;",
            "angles_trnsx": "return rv.set(x, y).rotate(angle).x;",
            "angles_trnsy": "return rv.set(x, y).rotate(angle).y;",
            "mathf_range": "public static float range(float range){\n        return random(-range, range);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_angle_life_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_angle_life_source"))
        report = source_parity.verify_weapon_bullet_angle_life_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["arc_position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["checked"], {
            "bullet_rotation_method": "protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){",
            "bullet_rotation_return": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;",
            "shoot_angle": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset,",
            "life_scl": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f,",
            "angle": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy);",
            "weapon_inaccuracy": "public float inaccuracy = 0f;",
            "bullet_scale_life": "public boolean scaleLife;",
            "bullet_range": "public float range = 0f;",
            "bullet_inaccuracy": "public float inaccuracy = 0f;",
            "angles_angle": "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;",
            "position_angle_to": "return Angles.angle(getX(), getY(), x, y);",
            "mathf_clamp_unit": "public static float clamp(float value){\n        return Math.max(Math.min(value, 1f), 0f);\n    }",
            "mathf_dst": "public static float dst(float x1, float y1, float x2, float y2){",
            "mathf_range": "public static float range(float range){\n        return random(-range, range);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_shooter_selection_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_shooter_selection_source"))
        report = source_parity.verify_weapon_bullet_shooter_selection_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["unit_comp_source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["missile_ai_source"], "core/src/mindustry/ai/types/MissileAI.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "shooter_selection": "Entityc shooter = unit.controller() instanceof MissileAI ai ? ai.shooter : unit; //Pass the missile's shooter down to its bullets",
            "bullet_create_reserved": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target);",
            "unit_controller_field": "private UnitController controller;",
            "unit_controller_getter": "public UnitController controller(){\n        return controller;\n    }",
            "missile_ai_class": "public class MissileAI extends AIController{",
            "missile_ai_shooter": "public @Nullable Unit shooter;",
            "bullet_create_shooter_param": "@Nullable Entityc owner, @Nullable Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl,",
            "bullet_shooter_assignment": "bullet.shooter = (shooter == null ? owner : shooter);",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_create_call_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_create_call_source"))
        report = source_parity.verify_weapon_bullet_create_call_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "bullet_create_call": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target);",
            "handle_bullet_reserved": "handleBullet(unit, mount, mount.bullet);",
            "weapon_velocity_rnd": "public float velocityRnd = 0f;",
            "weapon_extra_velocity": "public float extraVelocity = 0f;",
            "mount_bullet_field": "public @Nullable Bullet bullet;",
            "mount_aim_fields": "public float aimX, aimY;",
            "mount_target_field": "public @Nullable Teamc target;",
            "bullet_create_signature": "public @Nullable Bullet create(\n        @Nullable Entityc owner, @Nullable Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl,\n        float lifetimeScl, Object data, @Nullable Mover mover, float aimX, float aimY, @Nullable Teamc target\n    ){",
            "mathf_random_float": "public static float random(float range){\n        return rand.nextFloat() * range;\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_handle_call_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_handle_call_source"))
        report = source_parity.verify_weapon_bullet_handle_call_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "handle_bullet_call": "handleBullet(unit, mount, mount.bullet);",
            "sound_reserved": "if(!continuous){",
            "handle_bullet_comment": "//override to do special things to a bullet after spawning",
            "handle_bullet_method": "protected void handleBullet(Unit unit, WeaponMount mount, Bullet bullet){",
            "handle_bullet_continuous_reserved": "if(continuous){",
            "mount_bullet_field": "public @Nullable Bullet bullet;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_handle_bullet_continuous_geometry_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_handle_bullet_continuous_geometry_source"))
        report = source_parity.verify_weapon_handle_bullet_continuous_geometry_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["arc_angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "handle_bullet_method": "protected void handleBullet(Unit unit, WeaponMount mount, Bullet bullet){",
            "continuous_gate": "if(continuous){",
            "weapon_rotation": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
            "mount_x": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),",
            "mount_y": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y),",
            "bullet_x": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
            "bullet_y": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY);",
            "aim_update_reserved": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
            "weapon_continuous": "public boolean continuous;",
            "weapon_rotate": "public boolean rotate = false;",
            "weapon_base_rotation": "public float baseRotation = 0f;",
            "weapon_shoot_offsets": "public float shootX = 0f, shootY = 3f;",
            "weapon_mount_offsets": "public float x = 5f, y = 0f;",
            "mount_rotation": "public float rotation;",
            "mount_last_length": "public float lastLength;",
            "angles_trnsx": "return rv.set(x, y).rotate(angle).x;",
            "angles_trnsy": "return rv.set(x, y).rotate(angle).y;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_handle_bullet_aim_update_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_handle_bullet_aim_update_source"))
        report = source_parity.verify_weapon_handle_bullet_aim_update_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "handle_bullet_method": "protected void handleBullet(Unit unit, WeaponMount mount, Bullet bullet){",
            "continuous_gate": "if(continuous){",
            "aim_update": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
            "bullet_aim_x_assignment": "bullet.aimX = Tmp.v1.x;",
            "bullet_aim_y_assignment": "bullet.aimY = Tmp.v1.y;",
            "bullet_rotation_method": "protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){",
            "bullet_rotation_return": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;",
            "weapon_shoot_y": "public float shootX = 0f, shootY = 3f;",
            "mount_last_length": "public float lastLength;",
            "bullet_aim_fields": "transient float aimX, aimY;",
            "vec2_trns_amount": "return set(amount, 0).rotate(angle);",
            "vec2_add_method": "public Vec2 add(float x, float y){",
            "vec2_add_x": "this.x += x;",
            "vec2_add_y": "this.y += y;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_sound_branch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_sound_branch_source"))
        report = source_parity.verify_weapon_bullet_sound_branch_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "handle_bullet_call": "handleBullet(unit, mount, mount.bullet);",
            "non_continuous_branch": "if(!continuous){",
            "shoot_sound_call": "shootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);",
            "continuous_else_branch": "}else{",
            "initial_shoot_sound_call": "initialShootSound.at(bulletX, bulletY, Mathf.random(soundPitchMin, soundPitchMax), shootSoundVolume);",
            "effects_reserved": "if(mount.allowShootEffects){",
            "shoot_sound_field": "public Sound shootSound = Sounds.shoot;",
            "shoot_sound_volume": "public float shootSoundVolume = 1f;",
            "initial_shoot_sound_field": "public Sound initialShootSound = Sounds.none;",
            "sound_pitch_range": "public float soundPitchMin = 0.8f, soundPitchMax = 1f;",
            "mathf_random_start_end": "return start + rand.nextFloat() * (end - start);",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_effects_branch_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_effects_branch_source"))
        report = source_parity.verify_weapon_bullet_effects_branch_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "effects_gate": "if(mount.allowShootEffects){",
            "eject_effect_call": "ejectEffect.at(mountX, mountY, angle * Mathf.sign(this.x));",
            "shoot_effect_call": "bullet.shootEffect.at(bulletX, bulletY, angle, bullet.hitColor, unit);",
            "smoke_effect_call": "bullet.smokeEffect.at(bulletX, bulletY, angle, bullet.hitColor, unit);",
            "recoil_reserved": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil));",
            "weapon_eject_effect": "public Effect ejectEffect = Fx.none;",
            "weapon_x_default": "public float x = 5f, y = 0f;",
            "mount_allow_shoot_effects": "public boolean allowShootEffects = true;",
            "bullet_shoot_effect": "public Effect shootEffect = Fx.shootSmall;",
            "bullet_smoke_effect": "public Effect smokeEffect = Fx.shootSmallSmoke;",
            "bullet_hit_color": "public Color hitColor = Color.white;",
            "mathf_sign": "return (f < 0 ? -1 : 1);",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_recoil_velocity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_recoil_velocity_source"))
        report = source_parity.verify_weapon_bullet_recoil_velocity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["bullet_type_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["unit_comp_source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "recoil_velocity": "unit.vel.add(Tmp.v1.trns(shootAngle + 180f, bullet.recoil));",
            "shake_reserved": "Effect.shake(shake, shake, bulletX, bulletY);",
            "bullet_recoil": "public float recoil;",
            "unit_vel_import": "@Import Vec2 vel;",
            "vec2_trns_amount": "return set(amount, 0).rotate(angle);",
            "vec2_add_vec": "public Vec2 add(Vec2 v){",
            "vec2_add_x": "x += v.x;",
            "vec2_add_y": "y += v.y;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_shake_effect_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_shake_effect_source"))
        report = source_parity.verify_weapon_bullet_shake_effect_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["checked"], {
            "shake_call": "Effect.shake(shake, shake, bulletX, bulletY);",
            "mount_recoil_reserved": "mount.recoil = 1f;",
            "weapon_shake": "public float shake = 0f;",
            "effect_shake_xy": "public static void shake(float intensity, float duration, float x, float y){",
            "effect_camera_guard": "if(Core.camera == null) return;",
            "effect_distance": "float distance = Core.camera.position.dst(x, y);",
            "effect_distance_floor": "if(distance < 1) distance = 1;",
            "effect_falloff": "shake(Mathf.clamp(1f / (distance * distance / shakeFalloff)) * intensity, duration);",
            "effect_private_shake": "private static void shake(float intensity, float duration){",
            "renderer_shake": "Vars.renderer.shake(intensity, duration);",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_mount_recoil_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_mount_recoil_source"))
        report = source_parity.verify_weapon_bullet_mount_recoil_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "mount_recoil_assignment": "mount.recoil = 1f;",
            "recoil_slots_reserved": "if(recoils > 0){",
            "recoil_slot_assignment_reserved": "mount.recoils[mount.barrelCounter % recoils] = 1f;",
            "heat_reserved": "mount.heat = 1f;",
            "weapon_mount_recoil": "public float recoil;",
            "weapon_mount_recoils": "public @Nullable float[] recoils;",
            "weapon_recoils_default": "public int recoils = -1;",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_recoil_slots_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_recoil_slots_source"))
        report = source_parity.verify_weapon_bullet_recoil_slots_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "recoil_slots_gate": "if(recoils > 0){",
            "recoil_slot_assignment": "mount.recoils[mount.barrelCounter % recoils] = 1f;",
            "heat_reserved": "mount.heat = 1f;",
            "weapon_recoils_default": "public int recoils = -1;",
            "weapon_mount_recoils": "public @Nullable float[] recoils;",
            "weapon_mount_barrel_counter": "public int barrelCounter;",
            "update_recoils_init": "if(mount.recoils == null) mount.recoils = new float[recoils];",
        })
        self.assertEqual(report["missing"], [])

    def test_weapon_bullet_heat_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_weapon_bullet_heat_source"))
        report = source_parity.verify_weapon_bullet_heat_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/type/Weapon.java")
        self.assertEqual(report["weapon_mount_source"], "core/src/mindustry/entities/units/WeaponMount.java")
        self.assertEqual(report["checked"], {
            "heat_assignment": "mount.heat = 1f;",
            "weapon_mount_heat": "public float heat;",
            "bullet_method_close_reserved": "    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_initial_gate_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_initial_gate_source"))
        report = source_parity.verify_bullet_type_create_initial_gate_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "create_signature": "public @Nullable Bullet create(\n        @Nullable Entityc owner, @Nullable Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl,\n        float lifetimeScl, Object data, @Nullable Mover mover, float aimX, float aimY, @Nullable Teamc target\n    ){",
            "angle_offset_line": "angle += angleOffset + Mathf.range(randomAngleOffset);",
            "create_chance_gate": "if(!Mathf.chance(createChance)) return null;",
            "ignore_spawn_angle": "if(ignoreSpawnAngle) angle = 0;",
            "spawn_unit_reserved": "if(spawnUnit != null){",
            "angle_offset_field": "public float angleOffset = 0f, randomAngleOffset = 0f;",
            "ignore_spawn_angle_field": "public boolean ignoreSpawnAngle = false;",
            "create_chance_field": "public float createChance = 1;",
            "mathf_range": "return random(-range, range);",
            "mathf_chance": "return d >= 1f || rand.nextFloat() < d;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_spawn_unit_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_spawn_unit_source"))
        report = source_parity.verify_bullet_type_create_spawn_unit_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "spawn_unit_gate": "if(spawnUnit != null){",
            "client_comment": "//don't spawn units clientside!",
            "client_guard": "if(!net.client()){",
            "spawn_create": "Unit spawned = spawnUnit.create(team);",
            "spawn_set": "spawned.set(x, y);",
            "spawn_rotation": "spawned.rotation = angle;",
            "missile_speed_guard": "if(spawnUnit.missileAccelTime <= 0f){",
            "spawn_vel": "spawned.vel.trns(angle, spawnUnit.speed);",
            "missile_ai_guard": "if(spawned.controller() instanceof MissileAI ai){",
            "unit_shooter_guard": "if(shooter instanceof Unit unit){",
            "unit_ai_assignment": "ai.shooter = unit;",
            "control_shooter_guard": "if(shooter instanceof ControlBlock control){",
            "control_ai_assignment": "ai.shooter = control.unit();",
            "spawn_add": "spawned.add();",
            "notify_spawn": "Units.notifyUnitSpawn(spawned);",
            "kill_shooter": "if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill();",
            "return_null": "return null;",
            "spawn_unit_field": "public @Nullable UnitType spawnUnit;",
            "kill_shooter_field": "public boolean killShooter;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_bullet_identity_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_bullet_identity_source"))
        report = source_parity.verify_bullet_type_create_bullet_identity_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "bullet_create": "Bullet bullet = Bullet.create();",
            "type_assignment": "bullet.type = this;",
            "owner_assignment": "bullet.owner = owner;",
            "shooter_assignment": "bullet.shooter = (shooter == null ? owner : shooter);",
            "team_assignment": "bullet.team = team;",
            "time_assignment": "bullet.time = 0f;",
            "origin_x_assignment": "bullet.originX = x;",
            "origin_y_assignment": "bullet.originY = y;",
            "aim_tile_reserved": "if(!(aimX == -1f && aimY == -1f)){",
            "bullet_comp_imports": "@Import Team team;\n    @Import Entityc owner;\n    @Import float x, y, damage, lastX, lastY, time, lifetime;",
            "bullet_comp_type": "BulletType type;",
            "bullet_comp_shooter": "transient Entityc shooter;",
            "bullet_comp_origin": "transient float originX, originY;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_aim_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_aim_state_source"))
        report = source_parity.verify_bullet_type_create_aim_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["building_comp_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(report["world_source"], "core/src/mindustry/core/World.java")
        self.assertEqual(report["checked"], {
            "aim_gate": "if(!(aimX == -1f && aimY == -1f)){",
            "aim_tile_assignment": "bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY);",
            "aim_x_assignment": "bullet.aimX = aimX;",
            "aim_y_assignment": "bullet.aimY = aimY;",
            "init_vel_reserved": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));",
            "bullet_comp_aim_tile": "transient @Nullable Tile aimTile;",
            "bullet_comp_aim_xy": "transient float aimX, aimY;",
            "building_comp_tile": "transient Tile tile;",
            "world_tile_world": "public @Nullable Tile tileWorld(float x, float y){\n        return tile(Math.round(x / tilesize), Math.round(y / tilesize));\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_velocity_position_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_velocity_position_state_source"))
        report = source_parity.verify_bullet_type_create_velocity_position_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "init_vel_call": "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));",
            "set_call": "bullet.set(x, y);",
            "last_x_assignment": "bullet.lastX = x;",
            "last_y_assignment": "bullet.lastY = y;",
            "lifetime_reserved": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);",
            "bullet_comp_init_vel": "public void initVel(float angle, float amount){\n        vel.trns(angle, amount);\n        rotation = angle;\n    }",
            "bullet_comp_last_xy_imports": "@Import float x, y, damage, lastX, lastY, time, lifetime;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_lifetime_payload_damage_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_lifetime_payload_damage_state_source"))
        report = source_parity.verify_bullet_type_create_lifetime_payload_damage_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "lifetime_assignment": "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);",
            "data_assignment": "bullet.data = data;",
            "hit_size_assignment": "bullet.hitSize = hitSize;",
            "mover_assignment": "bullet.mover = mover;",
            "damage_assignment": "bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();",
            "building_damage_multiplier_assignment": "bullet.buildingDamageMultiplier = buildingDamageMultiplier;",
            "trail_clear_reserved": "if(bullet.trail != null){",
            "bullet_add_reserved": "bullet.add();",
            "bullet_comp_data": "Object data;",
            "bullet_comp_building_damage_multiplier": "transient float buildingDamageMultiplier;",
            "bullet_comp_mover": "transient @Nullable Mover mover;",
            "bullet_comp_damage_multiplier": "public float damageMultiplier(){\n        return type.damageMultiplier(self());\n    }",
            "bullet_type_damage_multiplier": "public float damageMultiplier(Bullet b){\n        if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team);\n        if(b.owner instanceof Building) return state.rules.blockDamage(b.team);\n\n        return 1f;\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_trail_add_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_trail_add_state_source"))
        report = source_parity.verify_bullet_type_create_trail_add_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["trail_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(report["checked"], {
            "trail_reset_comment": "//reset trail",
            "trail_null_guard": "if(bullet.trail != null){",
            "trail_clear_call": "bullet.trail.clear();",
            "bullet_add_call": "bullet.add();",
            "keep_velocity_reserved": "if(keepVelocity && owner instanceof Velc v){",
            "bullet_comp_trail": "transient @Nullable Trail trail;",
            "bullet_comp_add": "public void add(){\n        type.init(self());\n    }",
            "trail_clear": "public void clear(){\n        points.clear();\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_keep_velocity_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_keep_velocity_state_source"))
        report = source_parity.verify_bullet_type_create_keep_velocity_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["vel_comp_source"], "core/src/mindustry/entities/comp/VelComp.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "keep_velocity_field": "public boolean keepVelocity = true;",
            "scale_keep_velocity_field": "public boolean scaleKeepVelocity = false;",
            "keep_velocity_gate": "if(keepVelocity && owner instanceof Velc v){",
            "len_before": "float len = bullet.vel.len();",
            "add_owner_velocity": "bullet.vel.add(v.vel());",
            "scale_gate": "if(scaleKeepVelocity){",
            "len_after": "float newLen = bullet.vel.len();",
            "lifetime_scale": "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen);",
            "return_bullet": "return bullet;",
            "vel_comp_vel": "@SyncLocal Vec2 vel = new Vec2();",
            "vec2_len": "public float len(){\n        return (float)Math.sqrt(x * x + y * y);\n    }",
            "vec2_add": "public Vec2 add(Vec2 v){\n        x += v.x;\n        y += v.y;\n        return this;\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_initial_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_initial_state_source"))
        report = source_parity.verify_bullet_type_init_initial_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["health_comp_source"], "core/src/mindustry/entities/comp/HealthComp.java")
        self.assertEqual(report["checked"], {
            "kill_shooter_field": "public boolean killShooter;",
            "instant_disappear_field": "public boolean instantDisappear;",
            "lifetime_field": "public float lifetime = 40f;",
            "init_method": "public void init(Bullet b){",
            "kill_shooter_gate": "if(killShooter && b.owner() instanceof Healthc h && !h.dead()){",
            "kill_call": "h.kill();",
            "instant_disappear_gate": "if(instantDisappear){",
            "time_assignment": "b.time = lifetime + 1f;",
            "spawn_bullets_reserved": "if(spawnBullets.size > 0){",
            "bullet_comp_owner": "@Import Entityc owner;",
            "bullet_comp_time_lifetime": "@Import float x, y, damage, lastX, lastY, time, lifetime;",
            "health_comp_dead": "transient boolean dead;",
            "health_comp_kill": "void kill(){\n        if(dead) return;\n\n        health = Math.min(health, 0);\n        dead = true;\n        killed();\n        remove();\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_spawn_bullets_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_spawn_bullets_state_source"))
        report = source_parity.verify_bullet_type_init_spawn_bullets_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "spawn_bullets_field": "public Seq<BulletType> spawnBullets = new Seq<>();",
            "spawn_bullet_random_spread_field": "public float spawnBulletRandomSpread = 0f;",
            "spawn_bullets_gate": "if(spawnBullets.size > 0){",
            "spawn_bullets_loop": "for(var bullet : spawnBullets){",
            "spawn_bullet_create_call": "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread));",
            "bullet_comp_xy_import": "@Import float x, y, damage, lastX, lastY, time, lifetime;",
            "bullet_comp_rotation": "public float rotation(){\n        return vel.isZero(0.001f) ? rotation : vel.angle();\n    }",
            "mathf_range": "public static float range(float range){\n        return random(-range, range);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_dispatch_state_source"))
        report = source_parity.verify_bullet_type_update_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "update_method": "public void update(Bullet b){",
            "update_trail_call": "updateTrail(b);",
            "update_homing_call": "updateHoming(b);",
            "update_weaving_call": "updateWeaving(b);",
            "update_trail_effects_call": "updateTrailEffects(b);",
            "update_bullet_interval_call": "updateBulletInterval(b);",
            "next_method_reserved": "public void updateBulletInterval(Bullet b){",
        })
        self.assertEqual(report["missing"], [])
        self.assertEqual(report["call_order"], [
            "updateTrail(b);",
            "updateHoming(b);",
            "updateWeaving(b);",
            "updateTrailEffects(b);",
            "updateBulletInterval(b);",
        ])

    def test_bullet_type_update_bullet_interval_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_bullet_interval_state_source"))
        report = source_parity.verify_bullet_type_update_bullet_interval_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["timer_comp_source"], "core/src/mindustry/entities/comp/TimerComp.java")
        self.assertEqual(report["interval_source"], "arc-core/src/arc/util/Interval.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "interval_bullet_field": "public @Nullable BulletType intervalBullet;",
            "bullet_interval_field": "public float bulletInterval = 20f;",
            "interval_bullets_field": "public int intervalBullets = 1;",
            "interval_random_spread_field": "public float intervalRandomSpread = 360f;",
            "interval_spread_field": "public float intervalSpread = 0f;",
            "interval_angle_field": "public float intervalAngle = 0f;",
            "interval_delay_field": "public float intervalDelay = -1f;",
            "method": "public void updateBulletInterval(Bullet b){",
            "gate": "if(intervalBullet != null && b.time >= intervalDelay && b.timer.get(2, bulletInterval)){",
            "angle_base": "float ang = b.rotation();",
            "loop": "for(int i = 0; i < intervalBullets; i++){",
            "create_call": "intervalBullet.create(b, b.x, b.y, ang + Mathf.range(intervalRandomSpread) + intervalAngle + ((i - (intervalBullets - 1f)/2f) * intervalSpread));",
            "timer_field": "transient Interval timer = new Interval(6);",
            "interval_get": "public boolean get(int id, float time){",
            "interval_get_check": "boolean got = check(id, time);",
            "mathf_range": "public static float range(float range){\n        return random(-range, range);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_trail_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_trail_state_source"))
        report = source_parity.verify_bullet_type_update_trail_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["trail_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(report["timed_comp_source"], "core/src/mindustry/entities/comp/TimedComp.java")
        self.assertEqual(report["vars_source"], "core/src/mindustry/Vars.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "trail_interp_field": "public Interp trailInterp = Interp.one;",
            "trail_length_field": "public int trailLength = -1;",
            "trail_sin_fields": "public float trailSinMag = 0f, trailSinScl = 3f;",
            "method": "public void updateTrail(Bullet b){",
            "gate": "if(!headless && trailLength > 0){",
            "trail_null_guard": "if(b.trail == null){",
            "new_trail": "b.trail = new Trail(trailLength);",
            "trail_length_assignment": "b.trail.length = trailLength;",
            "trail_update_call": "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)));",
            "trail_update_method": "public void update(float x, float y, float width){",
            "trail_update_counter": "int count = (int)(counter += Time.delta);",
            "timed_fin": "public float fin(){\n        return time / lifetime;\n    }",
            "vars_headless": "public static boolean headless;",
            "mathf_absin": "public static float absin(float in, float scl, float mag){\n        return (sin(in, scl * 2f, mag) + mag) / 2f;\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_homing_initial_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_homing_initial_state_source"))
        report = source_parity.verify_bullet_type_update_homing_initial_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "homing_power_field": "public float homingPower = 0f;",
            "homing_range_field": "public float homingRange = 50f;",
            "homing_delay_field": "public float homingDelay = -1f;",
            "follow_aim_speed_field": "public float followAimSpeed = 0f;",
            "method": "public void updateHoming(Bullet b){",
            "gate": "if(homingPower > 0.0001f && b.time >= homingDelay){",
            "real_aim_x": "float realAimX = b.aimX < 0 ? b.x : b.aimX;",
            "real_aim_y": "float realAimY = b.aimY < 0 ? b.y : b.aimY;",
            "target_reserved": "Teamc target;",
            "follow_aim_reserved": "if(followAimSpeed > 0f && b.shooter instanceof Unit u){",
            "bullet_comp_xy_time": "@Import float x, y, damage, lastX, lastY, time, lifetime;",
            "bullet_comp_aim": "transient float aimX, aimY;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_homing_target_velocity_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_homing_target_velocity_state_source"))
        report = source_parity.verify_bullet_type_update_homing_target_velocity_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "target_gate": "if(target != null){",
            "homing_set_angle": "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f));",
            "bullet_rotation": "public float rotation(){\n        return vel.isZero(0.001f) ? rotation : vel.angle();\n    }",
            "position_angle_to": "default float angleTo(Position other){\n        return Angles.angle(getX(), getY(), other.getX(), other.getY());\n    }",
            "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
            "angles_angle": "public static float angle(float x, float y, float x2, float y2){",
            "vec2_set_angle": "public Vec2 setAngle(float degrees){",
            "vec2_set_angle_rad": "this.set(len(), 0f);\n        this.rotateRad(radians);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_homing_follow_aim_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_homing_follow_aim_state_source"))
        report = source_parity.verify_bullet_type_update_homing_follow_aim_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["angles_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["position_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "follow_aim_gate": "if(followAimSpeed > 0f && b.shooter instanceof Unit u){",
            "follow_aim_angle": "float angle = b.angleTo(u.aimX, u.aimY);",
            "follow_aim_set_angle": "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta));",
            "bullet_comp_shooter": "transient Entityc shooter;",
            "position_angle_to_xy": "default float angleTo(float x, float y){\n        return Angles.angle(getX(), getY(), x, y);\n    }",
            "vec2_angle": "public float angle(){\n        float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees;\n        if(angle < 0) angle += 360;\n        return angle;\n    }",
            "angles_move_toward": "public static float moveToward(float angle, float to, float speed){",
            "vec2_set_angle": "public Vec2 setAngle(float degrees){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_weaving_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_weaving_state_source"))
        report = source_parity.verify_bullet_type_update_weaving_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "weave_scale_field": "public float weaveScale = 1f;",
            "weave_mag_field": "public float weaveMag = 0f;",
            "weave_random_field": "public boolean weaveRandom = true;",
            "method": "public void updateWeaving(Bullet b){",
            "gate": "if(weaveMag != 0){",
            "rotate_call": "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad);",
            "mathf_deg_rad": "public static final float degRad = degreesToRadians;",
            "mathf_random_seed": "public static int randomSeed(long seed, int min, int max){",
            "vec2_rotate_rad_exact": "public Vec2 rotateRadExact(float radians){",
            "vec2_rotate_math": "float newX = this.x * cos - this.y * sin;\n        float newY = this.x * sin + this.y * cos;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_weaving_rotate_speed_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_weaving_rotate_speed_state_source"))
        report = source_parity.verify_bullet_type_update_weaving_rotate_speed_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "rotate_speed_field": "public float rotateSpeed = 0f;",
            "method": "public void updateWeaving(Bullet b){",
            "rotate_speed_gate": "if(rotateSpeed != 0){",
            "rotate_speed_call": "b.vel.rotate(rotateSpeed * Time.delta);",
            "vec2_rotate": "public Vec2 rotate(float degrees){\n        return rotateRad(degrees * Mathf.degreesToRadians);\n    }",
            "mathf_degrees_to_radians": "public static final float degreesToRadians = PI / 180;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_weaving_circle_shooter_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_weaving_circle_shooter_state_source"))
        report = source_parity.verify_bullet_type_update_weaving_circle_shooter_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "circle_shooter_field": "public boolean circleShooter = false;",
            "circle_shooter_radius_field": "public float circleShooterRadius = 13f;",
            "circle_shooter_radius_smooth_field": "public float circleShooterRadiusSmooth = 10f;",
            "circle_shooter_rotate_speed_field": "public float circleShooterRotateSpeed = 0.3f;",
            "speed_field": "public float speed = 1f;",
            "gate": "if(circleShooter && b.owner instanceof Healthc h && h.isValid()){",
            "tmp_set_sub": "Tmp.v1.set(h).sub(b);",
            "tmp_rotate": "Tmp.v1.rotate(90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth)));",
            "vel_add_limit": "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed);",
            "mathf_lerp": "public static float lerp(float fromValue, float toValue, float progress){\n        return fromValue + (toValue - fromValue) * progress;\n    }",
            "mathf_clamp": "public static float clamp(float value){\n        return Math.max(Math.min(value, 1f), 0f);\n    }",
            "vec2_set_position": "public Vec2 set(Position v){\n        x = v.getX();\n        y = v.getY();\n        return this;\n    }",
            "vec2_sub_position": "public Vec2 sub(Position v){\n        return sub(v.getX(), v.getY());\n    }",
            "vec2_rotate": "public Vec2 rotate(float degrees){\n        return rotateRad(degrees * Mathf.degreesToRadians);\n    }",
            "vec2_add": "public Vec2 add(Vec2 v){\n        x += v.x;\n        y += v.y;\n        return this;\n    }",
            "vec2_limit": "public Vec2 limit(float limit){\n        return limit2(limit * limit);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_trail_effects_chance_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_trail_effects_chance_state_source"))
        report = source_parity.verify_bullet_type_update_trail_effects_chance_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "trail_chance_field": "public float trailChance = -0.0001f;",
            "trail_min_velocity_field": "public float trailMinVelocity = 0f;",
            "trail_effect_field": "public Effect trailEffect = Fx.missileTrail;",
            "trail_spread_field": "public float trailSpread = 0f;",
            "trail_param_field": "public float trailParam = 2f;",
            "trail_rotation_field": "public boolean trailRotation = false;",
            "method": "public void updateTrailEffects(Bullet b){",
            "can_spawn": "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity;",
            "chance_gate": "if(trailChance > 0 && canSpawn){",
            "chance_delta": "if(Mathf.chanceDelta(trailChance)){",
            "spread_random": "Tmp.v1.rnd(Mathf.random(trailSpread));",
            "spread_zero": "Tmp.v1.setZero();",
            "effect_at": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);",
            "mathf_chance_delta": "public static boolean chanceDelta(double d){\n        return rand.nextFloat() < d * Time.delta;\n    }",
            "mathf_random_float": "public static float random(float range){\n        return rand.nextFloat() * range;\n    }",
            "vec2_len2": "public float len2(){\n        return x * x + y * y;\n    }",
            "vec2_rnd": "public Vec2 rnd(float length){\n        setToRandomDirection().scl(length);\n        return this;\n    }",
            "vec2_set_zero": "public Vec2 setZero(){\n        this.x = 0;\n        this.y = 0;\n        return this;\n    }",
            "bullet_rotation": "public float rotation(){\n        return vel.isZero(0.001f) ? rotation : vel.angle();\n    }",
            "effect_at_color": "public void at(float x, float y, float rotation, Color color){\n        create(x, y, rotation, color, null);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_update_trail_effects_interval_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_update_trail_effects_interval_state_source"))
        report = source_parity.verify_bullet_type_update_trail_effects_interval_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["timer_comp_source"], "core/src/mindustry/entities/comp/TimerComp.java")
        self.assertEqual(report["interval_source"], "arc-core/src/arc/util/Interval.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "trail_interval_field": "public float trailInterval = 0f;",
            "trail_spread_field": "public float trailSpread = 0f;",
            "trail_param_field": "public float trailParam = 2f;",
            "trail_rotation_field": "public boolean trailRotation = false;",
            "method": "public void updateTrailEffects(Bullet b){",
            "can_spawn": "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity;",
            "interval_gate": "if(trailInterval > 0f && canSpawn){",
            "timer_call": "if(b.timer(0, trailInterval)){",
            "spread_random": "Tmp.v1.rnd(Mathf.random(trailSpread));",
            "spread_zero": "Tmp.v1.setZero();",
            "effect_at": "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);",
            "timer_comp_field": "transient Interval timer = new Interval(6);",
            "timer_comp_method": "public boolean timer(int index, float time){\n        if(Float.isInfinite(time)) return false;\n        return timer.get(index, time);\n    }",
            "interval_get": "public boolean get(int id, float time){\n        if(id >= times.length) throw new RuntimeException(\"Out of bounds! Max timer size is \" + times.length + \"!\");\n\n        boolean got = check(id, time);\n        if(got) times[id] = Time.time;\n        return got;\n    }",
            "interval_check": "public boolean check(int id, float time){\n        return Time.time - times[id] >= time || Time.time < times[id];\n    }",
            "mathf_random_float": "public static float random(float range){\n        return rand.nextFloat() * range;\n    }",
            "vec2_rnd": "public Vec2 rnd(float length){\n        setToRandomDirection().scl(length);\n        return this;\n    }",
            "vec2_set_zero": "public Vec2 setZero(){\n        this.x = 0;\n        this.y = 0;\n        return this;\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_type_defaults_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_type_defaults_state_source"))
        report = source_parity.verify_bullet_type_init_type_defaults_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["status_effects_source"], "core/src/mindustry/content/StatusEffects.java")
        self.assertEqual(report["checked"], {
            "pierce_field": "public boolean pierce;",
            "pierce_cap_field": "public int pierceCap = -1;",
            "status_field": "public StatusEffect status = StatusEffects.none;",
            "despawn_hit_field": "public boolean despawnHit = false;",
            "set_defaults_field": "public boolean setDefaults = true;",
            "method": "public void init(){",
            "pierce_gate": "if(pierceCap >= 1){",
            "pierce_assign": "pierce = true;",
            "set_defaults_gate": "if(setDefaults){",
            "lightning_gate": "if(lightning > 0){",
            "status_none_gate": "if(status == StatusEffects.none){",
            "status_shocked_assign": "status = StatusEffects.shocked;",
            "despawn_hit_gate": "if(fragBullet != null || splashDamageRadius > 0 || lightning > 0){",
            "despawn_hit_assign": "despawnHit = true;",
            "status_none_load": "none = new StatusEffect(\"none\");",
            "status_shocked_load": "shocked = new StatusEffect(\"shocked\"){{",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_frag_velocity_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_frag_velocity_state_source"))
        report = source_parity.verify_bullet_type_init_frag_velocity_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "keep_velocity_field": "public boolean keepVelocity = true;",
            "scale_keep_velocity_field": "public boolean scaleKeepVelocity = false;",
            "frag_bullet_field": "public @Nullable BulletType fragBullet = null;",
            "method": "public void init(){",
            "frag_gate": "if(fragBullet != null){",
            "frag_keep_velocity_assign": "fragBullet.keepVelocity = false;",
            "frag_scale_keep_velocity_assign": "fragBullet.scaleKeepVelocity = false;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_lightning_type_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_lightning_type_state_source"))
        report = source_parity.verify_bullet_type_init_lightning_type_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullets_source"], "core/src/mindustry/content/Bullets.java")
        self.assertEqual(report["checked"], {
            "collides_air_ground_field": "public boolean collidesAir = true, collidesGround = true;",
            "lightning_type_field": "public @Nullable BulletType lightningType = null;",
            "method": "public void init(){",
            "lightning_type_gate": "if(lightningType == null){",
            "lightning_type_assign": "lightningType =",
            "ground_choice": "!collidesAir ? Bullets.damageLightningGround :",
            "air_choice": "!collidesGround ? Bullets.damageLightningAir :",
            "default_choice": "Bullets.damageLightning;",
            "bullets_fields": "placeholder, spaceLiquid, damageLightning, damageLightningGround, damageLightningAir, fireball;",
            "damage_lightning_init": "damageLightning = new BulletType(0.0001f, 0f){{",
            "damage_lightning_ground_copy": "damageLightningGround = damageLightning.copy();",
            "damage_lightning_ground_collides_air": "damageLightningGround.collidesAir = false;",
            "damage_lightning_air_copy": "damageLightningAir = damageLightning.copy();",
            "damage_lightning_air_collides_ground": "damageLightningAir.collidesGround = false;",
            "damage_lightning_air_collides_tiles": "damageLightningAir.collidesTiles = false;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_light_radius_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_light_radius_state_source"))
        report = source_parity.verify_bullet_type_init_light_radius_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_size_field": "public float hitSize = 4;",
            "light_radius_field": "public float lightRadius = -1f;",
            "method": "public void init(){",
            "light_radius_gate": "if(lightRadius <= -1){",
            "light_radius_assign": "lightRadius = Math.max(18, hitSize * 5f);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_draw_size_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_draw_size_state_source"))
        report = source_parity.verify_bullet_type_init_draw_size_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "speed_field": "public float speed = 1f;",
            "draw_size_field": "public float drawSize = 40f;",
            "trail_length_field": "public int trailLength = -1;",
            "method": "public void init(){",
            "draw_size_assign": "drawSize = Math.max(drawSize, trailLength * speed * 2f);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_init_range_assignment_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_init_range_assignment_state_source"))
        report = source_parity.verify_bullet_type_init_range_assignment_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "range_field": "public float range = 0f;",
            "method": "public void init(){",
            "draw_then_range_assign": "drawSize = Math.max(drawSize, trailLength * speed * 2f);\n        range = calculateRange();",
            "calculate_range_method": "protected float calculateRange(){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_calculate_range_override_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_calculate_range_override_state_source"))
        report = source_parity.verify_bullet_type_calculate_range_override_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "range_override_field": "public float rangeOverride = -1f;",
            "method": "protected float calculateRange(){",
            "range_override_return": "if(rangeOverride > 0) return rangeOverride;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_calculate_range_spawn_unit_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_calculate_range_spawn_unit_state_source"))
        report = source_parity.verify_bullet_type_calculate_range_spawn_unit_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "spawn_unit_field": "public @Nullable UnitType spawnUnit;",
            "method": "protected float calculateRange(){",
            "range_override_return": "if(rangeOverride > 0) return rangeOverride;",
            "spawn_unit_return": "if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;",
            "unit_lifetime_field": "public float lifetime = 60f * 5f;",
            "unit_speed_field": "public float speed = 1.1f,",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_calculate_range_despawn_unit_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_calculate_range_despawn_unit_state_source"))
        report = source_parity.verify_bullet_type_calculate_range_despawn_unit_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "despawn_unit_field": "public @Nullable UnitType despawnUnit;",
            "method": "protected float calculateRange(){",
            "spawn_unit_return": "if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;",
            "despawn_unit_return": "if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;",
            "unit_lifetime_field": "public float lifetime = 60f * 5f;",
            "unit_speed_field": "public float speed = 1.1f,",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_calculate_range_fallback_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_calculate_range_fallback_state_source"))
        report = source_parity.verify_bullet_type_calculate_range_fallback_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "speed_field": "public float speed = 1f;",
            "lifetime_field": "public float lifetime = 40f;",
            "drag_field": "public float drag = 0f;",
            "max_range_field": "public float maxRange = -1f;",
            "method": "protected float calculateRange(){",
            "despawn_unit_return": "if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;",
            "fallback_return": "return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);",
            "float_rounding_error": "public static final float FLOAT_ROUNDING_ERROR = 0.000001f;",
            "mathf_zero_float": "public static boolean zero(float value){\n        return Math.abs(value) <= FLOAT_ROUNDING_ERROR;\n    }",
            "mathf_pow_float": "public static float pow(float a, float b){\n        return (float)Math.pow(a, b);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_continuous_damage_default_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_continuous_damage_default_state_source"))
        report = source_parity.verify_bullet_type_continuous_damage_default_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "continuous_damage_doc": "/** @return continuous damage in damage/sec, or -1 if not continuous. */",
            "method": "public float continuousDamage(){",
            "return_default": "return -1f;",
            "heals_next_method": "public boolean heals(){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_heals_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_heals_state_source"))
        report = source_parity.verify_bullet_type_heals_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "heal_percent_field": "public float healPercent = 0f;",
            "heal_amount_field": "public float healAmount = 0f;",
            "method": "public boolean heals(){",
            "return_heals": "return healPercent > 0 || healAmount > 0;",
            "test_collision_uses_heals": "return !heals() || tile.team != bullet.team || tile.healthf() < 1f;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_test_collision_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_test_collision_state_source"))
        report = source_parity.verify_bullet_type_test_collision_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "previous_method": "public boolean heals(){",
            "method": "public boolean testCollision(Bullet bullet, Building tile){",
            "return_test_collision": "return !heals() || tile.team != bullet.team || tile.healthf() < 1f;",
            "next_method": "public void hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_tile_heal_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_tile_heal_state_source"))
        report = source_parity.verify_bullet_type_hit_tile_heal_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct){",
            "heal_gate": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock)){",
            "heal_effect_call": "healEffect.at(build.x, build.y, 0f, healColor, build.block);",
            "build_heal_call": "build.heal(healPercent / 100f * build.maxHealth + healAmount);",
            "heal_sound_call": "healSound.at(build, 1f + Mathf.range(0.1f), healSoundVolume);",
            "hit_call": "hit(b);",
            "enemy_direct_branch": "}else if(build.team != b.team && direct){",
            "pierce_call": "handlePierce(b, initialHealth, x, y);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_tile_fire_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_tile_fire_state_source"))
        report = source_parity.verify_bullet_type_hit_tile_fire_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct){",
            "fire_gate": "if(makeFire && build.team != b.team){",
            "fires_create_call": "Fires.create(build.tile);",
            "heal_gate_boundary": "if(heals() && build.team == b.team && !(build.block instanceof ConstructBlock)){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_tile_enemy_direct_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_tile_enemy_direct_state_source"))
        report = source_parity.verify_bullet_type_hit_tile_enemy_direct_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct){",
            "enemy_direct_gate": "}else if(build.team != b.team && direct){",
            "hit_call": "hit(b);",
            "lifesteal_boundary": "if(lifesteal > 0f && b.owner instanceof Healthc o){",
            "pierce_boundary": "handlePierce(b, initialHealth, x, y);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_tile_lifesteal_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_tile_lifesteal_state_source"))
        report = source_parity.verify_bullet_type_hit_tile_lifesteal_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct){",
            "enemy_direct_gate": "}else if(build.team != b.team && direct){",
            "lifesteal_gate": "if(lifesteal > 0f && b.owner instanceof Healthc o){",
            "lifesteal_result": "float result = Math.max(Math.min(build.health, damage), 0);",
            "owner_heal": "o.heal(result * lifesteal);",
            "pierce_boundary": "handlePierce(b, initialHealth, x, y);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_handle_pierce_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_handle_pierce_state_source"))
        report = source_parity.verify_bullet_type_handle_pierce_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void handlePierce(Bullet b, float initialHealth, float x, float y){",
            "sub_assignment": "float sub = Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0);",
            "subtract_comment": "//subtract health from each consecutive pierce",
            "damage_subtract": "b.damage -= Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub);",
            "remove_gate": "if(removeAfterPierce && b.damage <= 0){",
            "hit_assignment": "b.hit = true;",
            "remove_call": "b.remove();",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_entity_damage_cap_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_entity_damage_cap_state_source"))
        report = source_parity.verify_bullet_type_hit_entity_damage_cap_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_entity_method": "public void hitEntity(Bullet b, Hitboxc entity, float health){",
            "was_dead": "boolean wasDead = entity instanceof Unit u && u.dead;",
            "healthc_gate": "if(entity instanceof Healthc h){",
            "damage_assignment": "float damage = b.damage;",
            "shield_assignment": "float shield = entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f;",
            "max_damage_fraction_gate": "if(maxDamageFraction > 0){",
            "cap_assignment": "float cap = h.maxHealth() * maxDamageFraction + shield;",
            "damage_cap_assignment": "damage = Math.min(damage, cap);",
            "health_cap_comment": "//cap health to effective health for handlePierce to handle it properly",
            "health_cap_assignment": "health = Math.min(health, cap);",
            "health_shield_else": "}else{\n                health += shield;",
            "lifesteal_boundary": "if(lifesteal > 0f && b.owner instanceof Healthc o){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_entity_lifesteal_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_entity_lifesteal_state_source"))
        report = source_parity.verify_bullet_type_hit_entity_lifesteal_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_entity_method": "public void hitEntity(Bullet b, Hitboxc entity, float health){",
            "healthc_gate": "if(entity instanceof Healthc h){",
            "damage_assignment": "float damage = b.damage;",
            "lifesteal_gate": "if(lifesteal > 0f && b.owner instanceof Healthc o){",
            "lifesteal_result": "float result = Math.max(Math.min(h.health(), damage), 0);",
            "owner_heal": "o.heal(result * lifesteal);",
            "pierce_armor_boundary": "if(pierceArmor){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_entity_armor_damage_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_entity_armor_damage_state_source"))
        report = source_parity.verify_bullet_type_hit_entity_armor_damage_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_entity_method": "public void hitEntity(Bullet b, Hitboxc entity, float health){",
            "healthc_gate": "if(entity instanceof Healthc h){",
            "damage_assignment": "float damage = b.damage;",
            "pierce_armor_gate": "if(pierceArmor){",
            "damage_pierce_call": "h.damagePierce(damage);",
            "armor_multiplier_gate": "}else if(armorMultiplier != 1){",
            "damage_armor_mult_call": "h.damageArmorMult(damage, armorMultiplier);",
            "damage_call_else": "}else{\n                h.damage(damage);",
            "unit_boundary": "if(entity instanceof Unit unit){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_entity_unit_effects_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_entity_unit_effects_state_source"))
        report = source_parity.verify_bullet_type_hit_entity_unit_effects_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_entity_method": "public void hitEntity(Bullet b, Hitboxc entity, float health){",
            "unit_gate": "if(entity instanceof Unit unit){",
            "impulse_vector": "Tmp.v3.set(unit).sub(b).nor().scl(knockback * 80f);",
            "impact_angle": "if(impact) Tmp.v3.setAngle(b.rotation() + (knockback < 0 ? 180f : 0f));",
            "unit_impulse": "unit.impulse(Tmp.v3);",
            "unit_apply": "unit.apply(status, statusDuration);",
            "bullet_damage_event": "Events.fire(bulletDamageEvent.set(unit, b));",
            "destroy_event_boundary": "if(!wasDead && entity instanceof Unit unit && unit.dead){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_entity_unit_destroy_event_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_entity_unit_destroy_event_state_source"))
        report = source_parity.verify_bullet_type_hit_entity_unit_destroy_event_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_entity_method": "public void hitEntity(Bullet b, Hitboxc entity, float health){",
            "was_dead_local": "boolean wasDead = entity instanceof Unit u && u.dead;",
            "destroy_event_gate": "if(!wasDead && entity instanceof Unit unit && unit.dead){",
            "unit_destroy_event": "Events.fire(new UnitBulletDestroyEvent(unit, b));",
            "handle_pierce_boundary": "handlePierce(b, health, entity.x(), entity.y());",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_entity_handle_pierce_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_entity_handle_pierce_state_source"))
        report = source_parity.verify_bullet_type_hit_entity_handle_pierce_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_entity_method": "public void hitEntity(Bullet b, Hitboxc entity, float health){",
            "handle_pierce_call": "handlePierce(b, health, entity.x(), entity.y());",
            "handle_pierce_method": "public void handlePierce(Bullet b, float initialHealth, float x, float y){",
            "handle_pierce_sub": "float sub = Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_damage_multiplier_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_damage_multiplier_state_source"))
        report = source_parity.verify_bullet_type_damage_multiplier_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public float damageMultiplier(Bullet b){",
            "unit_branch": "if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team);",
            "building_branch": "if(b.owner instanceof Building) return state.rules.blockDamage(b.team);",
            "fallback": "return 1f;",
            "hit_method_boundary": "public void hit(Bullet b){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_default_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_default_state_source"))
        report = source_parity.verify_bullet_type_hit_default_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hit(Bullet b){",
            "delegate": "hit(b, b.x, b.y, true);",
            "xy_overload_boundary": "public void hit(Bullet b, float x, float y){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_xy_default_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_xy_default_state_source"))
        report = source_parity.verify_bullet_type_hit_xy_default_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hit(Bullet b, float x, float y){",
            "delegate": "hit(b, x, y, true);",
            "create_frags_overload_boundary": "public void hit(Bullet b, float x, float y, boolean createFrags){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_effects_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_effects_state_source"))
        report = source_parity.verify_bullet_type_hit_effects_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "hit_effect_field": "public Effect hitEffect = Fx.hitBulletSmall;",
            "hit_sound_field": "public Sound hitSound = Sounds.none;",
            "hit_sound_pitch_field": "public float hitSoundPitch = 1, hitSoundPitchRange = 0.1f;",
            "hit_sound_volume_field": "public float hitSoundVolume = 1;",
            "hit_shake_field": "public float hitShake = 0f, despawnShake = 0f;",
            "hit_color_field": "public Color hitColor = Color.white;",
            "method": "public void hit(Bullet b, float x, float y, boolean createFrags){",
            "hit_effect_call": "hitEffect.at(x, y, b.rotation(), hitColor);",
            "hit_sound_call": "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume);",
            "shake_call": "Effect.shake(hitShake, hitShake, b);",
            "frag_boundary": "if(createFrags && fragOnHit){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_frag_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_frag_dispatch_state_source"))
        report = source_parity.verify_bullet_type_hit_frag_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "frag_on_hit_field": "public boolean fragOnHit = true;",
            "frag_bullet_field": "public @Nullable BulletType fragBullet = null;",
            "delay_frags_field": "public boolean delayFrags = false;",
            "method": "public void hit(Bullet b, float x, float y, boolean createFrags){",
            "frag_gate": "if(createFrags && fragOnHit){",
            "delay_gate": "if(delayFrags && fragBullet != null && fragBullet.delayFrags){",
            "time_run_call": "Time.run(0f, () -> createFrags(b, x, y));",
            "create_frags_call": "createFrags(b, x, y);",
            "post_frag_boundary": "createPuddles(b, x, y);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_post_frag_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_post_frag_dispatch_state_source"))
        report = source_parity.verify_bullet_type_hit_post_frag_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hit(Bullet b, float x, float y, boolean createFrags){",
            "create_puddles_call": "createPuddles(b, x, y);",
            "create_incend_call": "createIncend(b, x, y);",
            "create_units_call": "createUnits(b, x, y);",
            "suppression_boundary": "if(suppressionRange > 0){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_suppression_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_suppression_state_source"))
        report = source_parity.verify_bullet_type_hit_suppression_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["damage_source"], "core/src/mindustry/entities/Damage.java")
        self.assertEqual(report["checked"], {
            "suppression_range_field": "public float suppressionRange = -1f;",
            "suppression_duration_field": "public float suppressionDuration = 60f * 8f;",
            "suppression_effect_chance_field": "public float suppressionEffectChance = 50f;",
            "suppress_color_field": "public Color suppressColor = Pal.sapBullet;",
            "method": "public void hit(Bullet b, float x, float y, boolean createFrags){",
            "suppression_gate": "if(suppressionRange > 0){",
            "pooled_vec2_comment": "//bullets are pooled, require separate Vec2 instance",
            "apply_suppression_call": "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor);",
            "damage_signature": "public static void applySuppression(Team team, float x, float y, float range, float reload, float maxDelay, float applyParticleChance, @Nullable Position source, Color effectColor){",
            "splash_damage_boundary": "createSplashDamage(b, x, y);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_hit_splash_damage_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_hit_splash_damage_dispatch_state_source"))
        report = source_parity.verify_bullet_type_hit_splash_damage_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void hit(Bullet b, float x, float y, boolean createFrags){",
            "create_splash_damage_call": "createSplashDamage(b, x, y);",
            "lightning_boundary": "for(int i = 0; i < lightning; i++){",
            "create_splash_damage_method_boundary": "public void createSplashDamage(Bullet b, float x, float y){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_splash_damage_damage_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_splash_damage_damage_dispatch_state_source"))
        report = source_parity.verify_bullet_type_create_splash_damage_damage_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["damage_source"], "core/src/mindustry/entities/Damage.java")
        self.assertEqual(report["checked"], {
            "splash_damage_field": "public float splashDamage = 0f;",
            "scaled_splash_damage_field": "public boolean scaledSplashDamage = false;",
            "collides_air_ground_field": "public boolean collidesAir = true, collidesGround = true;",
            "armor_multiplier_field": "public float armorMultiplier = 1f;",
            "splash_damage_radius_field": "public float splashDamageRadius = -1f;",
            "splash_damage_pierce_field": "public boolean splashDamagePierce = false;",
            "method": "public void createSplashDamage(Bullet b, float x, float y){",
            "damage_gate": "if(splashDamageRadius > 0 && !b.absorbed){",
            "damage_call": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier);",
            "damage_signature": "public static void damage(Team team, float x, float y, float radius, float damage, boolean complete, boolean air, boolean ground, boolean scaled, @Nullable Bullet source, float armorMult){",
            "status_boundary": "if(status != StatusEffects.none){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_splash_damage_status_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_splash_damage_status_dispatch_state_source"))
        report = source_parity.verify_bullet_type_create_splash_damage_status_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["damage_source"], "core/src/mindustry/entities/Damage.java")
        self.assertEqual(report["checked"], {
            "status_field": "public StatusEffect status = StatusEffects.none;",
            "status_duration_field": "public float statusDuration = 60 * 8f;",
            "method": "public void createSplashDamage(Bullet b, float x, float y){",
            "damage_gate": "if(splashDamageRadius > 0 && !b.absorbed){",
            "damage_call_boundary": "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier);",
            "status_gate": "if(status != StatusEffects.none){",
            "status_call": "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround);",
            "damage_status_signature": "public static void status(Team team, float x, float y, float radius, StatusEffect effect, float duration, boolean air, boolean ground){",
            "heals_boundary": "if(heals()){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_splash_damage_heal_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_splash_damage_heal_dispatch_state_source"))
        report = source_parity.verify_bullet_type_create_splash_damage_heal_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "heal_percent_field": "public float healPercent = 0f;",
            "heal_amount_field": "public float healAmount = 0f;",
            "heal_color_field": "public Color healColor = Pal.heal;",
            "heal_effect_field": "public Effect healEffect = Fx.healBlockFull;",
            "heals_method": "public boolean heals(){",
            "heals_return": "return healPercent > 0 || healAmount > 0;",
            "method": "public void createSplashDamage(Bullet b, float x, float y){",
            "damage_gate": "if(splashDamageRadius > 0 && !b.absorbed){",
            "heals_gate": "if(heals()){",
            "each_block_call": "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {",
            "heal_effect_call": "healEffect.at(other.x, other.y, 0f, healColor, other.block);",
            "other_heal_call": "other.heal(healPercent / 100f * other.maxHealth() + healAmount);",
            "make_fire_boundary": "if(makeFire){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_splash_damage_make_fire_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_splash_damage_make_fire_dispatch_state_source"))
        report = source_parity.verify_bullet_type_create_splash_damage_make_fire_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "make_fire_field": "public boolean makeFire = false;",
            "method": "public void createSplashDamage(Bullet b, float x, float y){",
            "damage_gate": "if(splashDamageRadius > 0 && !b.absorbed){",
            "make_fire_gate": "if(makeFire){",
            "each_block_call": "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile));",
            "enemy_team_predicate": "other -> other.team != b.team",
            "fires_create_call": "Fires.create(other.tile)",
            "create_frags_boundary": "public void createFrags(Bullet b, float x, float y){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_frags_initial_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_frags_initial_state_source"))
        report = source_parity.verify_bullet_type_create_frags_initial_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "frag_on_absorb_field": "public boolean fragOnAbsorb = true;",
            "frag_bullet_field": "public @Nullable BulletType fragBullet = null;",
            "frag_bullets_field": "public int fragBullets = 9;",
            "pierce_frag_cap_field": "public int pierceFragCap = -1;",
            "bullet_frags_field": "transient int frags;",
            "method": "public void createFrags(Bullet b, float x, float y){",
            "initial_gate": "if(fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap)){",
            "loop_boundary": "for(int i = 0; i < fragBullets; i++){",
            "random_len_boundary": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_frags_random_geometry_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_frags_random_geometry_state_source"))
        report = source_parity.verify_bullet_type_create_frags_random_geometry_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "frag_offset_fields": "public float fragOffsetMin = 1f, fragOffsetMax = 7f;",
            "frag_random_spread_field": "public float fragRandomSpread = 360f;",
            "frag_angle_field": "public float fragAngle = 0f;",
            "frag_spread_field": "public float fragSpread = 0f;",
            "method": "public void createFrags(Bullet b, float x, float y){",
            "random_len": "float len = Mathf.random(fragOffsetMin, fragOffsetMax);",
            "angle_formula": "float a = b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f;",
            "create_call_boundary": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_frags_create_call_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_frags_create_call_state_source"))
        report = source_parity.verify_bullet_type_create_frags_create_call_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["arc_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(report["checked"], {
            "frag_velocity_fields": "public float fragVelocityMin = 0.2f, fragVelocityMax = 1f;",
            "frag_life_fields": "public float fragLifeMin = 1f, fragLifeMax = 1f;",
            "method": "public void createFrags(Bullet b, float x, float y){",
            "create_call": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
            "trnsx_len": "public static float trnsx(float angle, float len){",
            "trnsx_return": "return len * Mathf.cosDeg(angle);",
            "trnsy_len": "public static float trnsy(float angle, float len){",
            "trnsy_return": "return len * Mathf.sinDeg(angle);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_frags_increment_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_frags_increment_state_source"))
        report = source_parity.verify_bullet_type_create_frags_increment_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void createFrags(Bullet b, float x, float y){",
            "initial_gate": "if(fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap)){",
            "loop_boundary": "for(int i = 0; i < fragBullets; i++){",
            "create_call": "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax));",
            "frags_increment": "b.frags++;",
            "bullet_frags_field": "transient int frags;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_puddles_initial_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_puddles_initial_state_source"))
        report = source_parity.verify_bullet_type_create_puddles_initial_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "puddles_field": "public int puddles;",
            "puddle_range_field": "public float puddleRange;",
            "puddle_amount_field": "public float puddleAmount = 5f;",
            "puddle_liquid_field": "public Liquid puddleLiquid = Liquids.water;",
            "method": "public void createPuddles(Bullet b, float x, float y){",
            "initial_gate": "if(puddleLiquid != null && puddles > 0){",
            "loop_boundary": "for(int i = 0; i < puddles; i++){",
            "tile_boundary": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
            "deposit_boundary": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_puddles_tile_world_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_puddles_tile_world_state_source"))
        report = source_parity.verify_bullet_type_create_puddles_tile_world_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "puddle_range_field": "public float puddleRange;",
            "method": "public void createPuddles(Bullet b, float x, float y){",
            "initial_gate": "if(puddleLiquid != null && puddles > 0){",
            "loop_boundary": "for(int i = 0; i < puddles; i++){",
            "tile_world_call": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
            "deposit_boundary": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_puddles_deposit_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_puddles_deposit_state_source"))
        report = source_parity.verify_bullet_type_create_puddles_deposit_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "puddle_amount_field": "public float puddleAmount = 5f;",
            "puddle_liquid_field": "public Liquid puddleLiquid = Liquids.water;",
            "method": "public void createPuddles(Bullet b, float x, float y){",
            "initial_gate": "if(puddleLiquid != null && puddles > 0){",
            "loop_boundary": "for(int i = 0; i < puddles; i++){",
            "tile_world_call": "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));",
            "deposit_call": "Puddles.deposit(tile, puddleLiquid, puddleAmount);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_incend_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_incend_state_source"))
        report = source_parity.verify_bullet_type_create_incend_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "incend_amount_field": "public int incendAmount = 0;",
            "incend_spread_field": "public float incendSpread = 8f;",
            "incend_chance_field": "public float incendChance = 1f;",
            "method": "public void createIncend(Bullet b, float x, float y){",
            "gate": "if(incendChance > 0 && Mathf.chance(incendChance)){",
            "create_incend_call": "Damage.createIncend(x, y, incendSpread, incendAmount);",
            "create_puddles_boundary": "public void createPuddles(Bullet b, float x, float y){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_units_initial_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_units_initial_state_source"))
        report = source_parity.verify_bullet_type_create_units_initial_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "despawn_unit_field": "public @Nullable UnitType despawnUnit;",
            "despawn_unit_chance_field": "public float despawnUnitChance = 1;",
            "despawn_unit_count_field": "public int despawnUnitCount = 1;",
            "despawn_unit_radius_field": "public float despawnUnitRadius = 0.1f;",
            "face_outwards_field": "public boolean faceOutwards = false;",
            "method": "public void createUnits(Bullet b, float x, float y){",
            "initial_gate": "if(!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)){",
            "loop_boundary": "for(int i = 0; i < despawnUnitCount; i++){",
            "random_offset_boundary": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
            "spawn_boundary": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
            "rotation_boundary": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
            "notify_boundary": "Units.notifyUnitSpawn(u);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_units_random_offset_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_units_random_offset_state_source"))
        report = source_parity.verify_bullet_type_create_units_random_offset_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["checked"], {
            "despawn_unit_radius_field": "public float despawnUnitRadius = 0.1f;",
            "method": "public void createUnits(Bullet b, float x, float y){",
            "initial_gate": "if(!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)){",
            "loop_boundary": "for(int i = 0; i < despawnUnitCount; i++){",
            "random_offset": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
            "spawn_boundary": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
            "mathf_random_float": "public static float random(float range){\n        return rand.nextFloat() * range;\n    }",
            "vec2_rnd": "public Vec2 rnd(float length){\n        setToRandomDirection().scl(length);\n        return this;\n    }",
            "vec2_random_direction": "public Vec2 setToRandomDirection(){\n        float theta = Mathf.random(0f, Mathf.PI2);\n        return this.set(Mathf.cos(theta), Mathf.sin(theta));\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_units_spawn_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_units_spawn_state_source"))
        report = source_parity.verify_bullet_type_create_units_spawn_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void createUnits(Bullet b, float x, float y){",
            "initial_gate": "if(!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)){",
            "loop_boundary": "for(int i = 0; i < despawnUnitCount; i++){",
            "random_offset": "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));",
            "spawn_call": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
            "rotation_boundary": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
            "notify_boundary": "Units.notifyUnitSpawn(u);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_units_rotation_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_units_rotation_state_source"))
        report = source_parity.verify_bullet_type_create_units_rotation_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["vec2_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void createUnits(Bullet b, float x, float y){",
            "spawn_call": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
            "rotation_assignment": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
            "notify_boundary": "Units.notifyUnitSpawn(u);",
            "vec2_angle": "public float angle(){\n        float angle = Mathf.atan2(x, y) * Mathf.radiansToDegrees;\n        if(angle < 0) angle += 360;\n        return angle;\n    }",
            "bullet_rotation": "public float rotation(){\n        return vel.isZero(0.001f) ? rotation : vel.angle();\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_create_units_notify_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_create_units_notify_state_source"))
        report = source_parity.verify_bullet_type_create_units_notify_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void createUnits(Bullet b, float x, float y){",
            "spawn_call": "var u = despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y);",
            "rotation_assignment": "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();",
            "notify_call": "Units.notifyUnitSpawn(u);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_despawned_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_despawned_dispatch_state_source"))
        report = source_parity.verify_bullet_type_despawned_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void despawned(Bullet b){",
            "despawn_hit_gate": "if(despawnHit){",
            "hit_call": "hit(b, b.x, b.y, false);",
            "create_units_call": "createUnits(b, b.x, b.y);",
            "despawn_effect_boundary": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
            "despawn_sound_boundary": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
            "shake_boundary": "Effect.shake(despawnShake, despawnShake, b);",
            "removed_boundary": "public void removed(Bullet b){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_despawned_effect_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_despawned_effect_state_source"))
        report = source_parity.verify_bullet_type_despawned_effect_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "despawn_effect_field": "public Effect despawnEffect = Fx.hitBulletSmall;",
            "hit_color_field": "public Color hitColor = Color.white;",
            "method": "public void despawned(Bullet b){",
            "dispatch_gate": "if(despawnHit){",
            "despawn_effect_call": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
            "despawn_sound_boundary": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
            "shake_boundary": "Effect.shake(despawnShake, despawnShake, b);",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_despawned_sound_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_despawned_sound_state_source"))
        report = source_parity.verify_bullet_type_despawned_sound_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "despawn_sound_field": "public Sound despawnSound = Sounds.none;",
            "hit_sound_pitch_range_field": "public float hitSoundPitch = 1, hitSoundPitchRange = 0.1f;",
            "method": "public void despawned(Bullet b){",
            "despawn_effect_call": "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);",
            "despawn_sound_call": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
            "shake_boundary": "Effect.shake(despawnShake, despawnShake, b);",
            "mathf_range": "public static float range(float range){\n        return random(-range, range);\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_despawned_shake_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_despawned_shake_state_source"))
        report = source_parity.verify_bullet_type_despawned_shake_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["effect_source"], "core/src/mindustry/entities/Effect.java")
        self.assertEqual(report["checked"], {
            "despawn_shake_field": "public float hitShake = 0f, despawnShake = 0f;",
            "method": "public void despawned(Bullet b){",
            "despawn_sound_call": "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));",
            "shake_call": "Effect.shake(despawnShake, despawnShake, b);",
            "effect_shake_position": "public static void shake(float intensity, float duration, Position loc){\n        shake(intensity, duration, loc.getX(), loc.getY());\n    }",
            "removed_boundary": "public void removed(Bullet b){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_removed_trail_fade_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_removed_trail_fade_state_source"))
        report = source_parity.verify_bullet_type_removed_trail_fade_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["trail_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(report["checked"], {
            "trail_length_field": "public int trailLength = -1;",
            "trail_width_field": "public float trailWidth = 2f;",
            "trail_color_field": "public Color trailColor = Pal.missileYellowBack;",
            "method": "public void removed(Bullet b){",
            "trail_gate": "if(trailLength > 0 && b.trail != null && b.trail.size() > 0){",
            "trail_fade_call": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy());",
            "trail_copy": "public Trail copy(){",
            "trail_size": "public int size(){\n        return points.size/3;\n    }",
            "frag_boundary": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_removed_frag_dispatch_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_removed_frag_dispatch_state_source"))
        report = source_parity.verify_bullet_type_removed_frag_dispatch_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "frag_on_despawn_field": "public boolean fragOnDespawn = true;",
            "frag_bullet_field": "public @Nullable BulletType fragBullet = null;",
            "bullet_frags_field": "transient int frags;",
            "method": "public void removed(Bullet b){",
            "trail_fade_call": "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy());",
            "frag_gate": "if(b.frags == 0 && fragOnDespawn && fragBullet != null){",
            "create_frags_call": "createFrags(b, b.x, b.y);",
            "building_damage_boundary": "public float buildingDamage(Bullet b){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_building_damage_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_building_damage_state_source"))
        report = source_parity.verify_bullet_type_building_damage_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["checked"], {
            "building_damage_multiplier_field": "public float buildingDamageMultiplier = 1f;",
            "method": "public float buildingDamage(Bullet b){",
            "return_building_damage": "return b.damage() * b.buildingDamageMultiplier;",
            "create_assigns_building_damage_multiplier": "bullet.buildingDamageMultiplier = buildingDamageMultiplier;",
            "bullet_comp_field": "transient float buildingDamageMultiplier;",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_shield_damage_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_shield_damage_state_source"))
        report = source_parity.verify_bullet_type_shield_damage_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "shield_damage_multiplier_field": "public float shieldDamageMultiplier = 1f;",
            "method": "public float shieldDamage(Bullet b){",
            "return_shield_damage": "return b.damage() * shieldDamageMultiplier;",
            "building_damage_previous_method": "public float buildingDamage(Bullet b){",
            "draw_next_method": "public void draw(Bullet b){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_draw_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_draw_state_source"))
        report = source_parity.verify_bullet_type_draw_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["checked"], {
            "method": "public void draw(Bullet b){",
            "draw_trail_call": "drawTrail(b);",
            "draw_parts_call": "drawParts(b);",
            "draw_trail_next_method": "public void drawTrail(Bullet b){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_draw_trail_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_draw_trail_state_source"))
        report = source_parity.verify_bullet_type_draw_trail_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["bullet_comp_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(report["trail_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(report["checked"], {
            "trail_color_field": "public Color trailColor = Pal.missileYellowBack;",
            "trail_length_field": "public int trailLength = -1;",
            "trail_width_field": "public float trailWidth = 2f;",
            "bullet_comp_trail_field": "transient @Nullable Trail trail;",
            "method": "public void drawTrail(Bullet b){",
            "gate": "if(trailLength > 0 && b.trail != null){",
            "draw_z_capture": "float z = Draw.z();",
            "draw_z_below": "Draw.z(z - 0.0001f);",
            "trail_draw_call": "b.trail.draw(trailColor, trailWidth);",
            "draw_z_restore": "Draw.z(z);",
            "trail_draw_method": "public void draw(Color color, float width){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_draw_parts_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_draw_parts_state_source"))
        report = source_parity.verify_bullet_type_draw_parts_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["draw_part_source"], "core/src/mindustry/entities/part/DrawPart.java")
        self.assertEqual(report["checked"], {
            "method": "public void drawParts(Bullet b){",
            "parts_gate": "if(parts.size > 0){",
            "params_set": "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation());",
            "params_life": "DrawPart.params.life = b.fin();",
            "parts_loop": "for(int i = 0; i < parts.size; i++){",
            "part_draw": "parts.get(i).draw(DrawPart.params);",
            "draw_part_params_field": "public static final PartParams params = new PartParams();",
            "draw_part_draw_method": "public abstract void draw(PartParams params);",
            "part_params_fields": "public float warmup, reload, smoothReload, heat, recoil, life, charge;",
            "part_params_position_fields": "public float x, y, rotation;",
            "part_params_set_method": "public PartParams set(float warmup, float reload, float smoothReload, float heat, float recoil, float charge, float x, float y, float rotation){",
        })
        self.assertEqual(report["missing"], [])

    def test_bullet_type_draw_light_state_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_bullet_type_draw_light_state_source"))
        report = source_parity.verify_bullet_type_draw_light_state_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(report["drawf_source"], "core/src/mindustry/graphics/Drawf.java")
        self.assertEqual(report["checked"], {
            "light_radius_field": "public float lightRadius = -1f;",
            "light_opacity_field": "public float lightOpacity = 0.3f;",
            "light_color_field": "public Color lightColor = Pal.powerLight;",
            "method": "public void drawLight(Bullet b){",
            "early_return": "if(lightOpacity <= 0f || lightRadius <= 0f) return;",
            "drawf_light_call": "Drawf.light(b, lightRadius, lightColor, lightOpacity);",
            "drawf_position_method": "public static void light(Position pos, float radius, Color color, float opacity){",
            "drawf_position_delegate": "light(pos.getX(), pos.getY(), radius, color, opacity);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_move_pref_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_move_pref_source"))
        report = source_parity.verify_unit_move_pref_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "move_pref_comment": "Move based on preferred unit movement type.",
            "move_pref_method": "public void movePref(Vec2 movement){",
            "omni_gate": "if(type.omniMovement){",
            "omni_call": "moveAt(movement);",
            "rotate_call": "rotateMove(movement);",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_floor_speed_multiplier_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_floor_speed_multiplier_source"))
        report = source_parity.verify_unit_floor_speed_multiplier_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["floor_source"], "core/src/mindustry/world/blocks/environment/Floor.java")
        self.assertEqual(report["unit_type_source"], "core/src/mindustry/type/UnitType.java")
        self.assertEqual(report["checked"], {
            "floor_speed_method": "public float floorSpeedMultiplier(){",
            "floor_speed_floor": "Floor on = isFlying() || type.hovering ? Blocks.air.asFloor() : floorOn();",
            "floor_speed_return": "return (float)Math.pow(on.speedMultiplier, type.floorMultiplier) * speedMultiplier;",
            "floor_speed_default": "public float speedMultiplier = 1f;",
            "unit_floor_multiplier_default": "floorMultiplier = 1f,",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_unloaded_noop_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_unloaded_noop_source"))
        report = source_parity.verify_unit_unloaded_noop_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "unloaded_comment": "Called when this unit was unloaded from a factory or spawn point.",
            "unloaded_method": "public void unloaded(){",
            "unloaded_empty_body": "public void unloaded(){\n\n    }",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_boosting_default_event_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_boosting_default_event_source"))
        report = source_parity.verify_unit_update_boosting_default_event_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "update_boosting_default_method": "public void updateBoosting(boolean boost){",
            "update_boosting_default_call": "updateBoosting(boost, false);",
            "update_boosting_overload_method": "public void updateBoosting(boolean boost, boolean event){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_boosting_guard_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_boosting_guard_source"))
        report = source_parity.verify_unit_update_boosting_guard_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "update_boosting_overload_method": "public void updateBoosting(boolean boost, boolean event){",
            "update_boosting_guard": "if(!type.canBoost || dead) return;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_boosting_should_boost_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_boosting_should_boost_source"))
        report = source_parity.verify_unit_update_boosting_should_boost_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["checked"], {
            "should_boost_line": "boolean shouldBoost = boost || onSolid() || (isFlying() && !canLand());",
            "is_flying_return": "return elevation >= 0.09f;",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_boosting_elevation_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_boosting_elevation_source"))
        report = source_parity.verify_unit_update_boosting_elevation_source(ROOT / "mindustry-upstream", ROOT / "arc-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["arc_mathf_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(report["checked"], {
            "elevation_line": "elevation = Mathf.approachDelta(elevation, type.canBoost ? Mathf.num(shouldBoost) : 0f, shouldBoost ? type.riseSpeed : type.descentSpeed);",
            "mathf_num_method": "public static int num(boolean b){",
            "mathf_num_return": "return b ? 1 : 0;",
            "mathf_approach_delta": "return approach(from, to, Time.delta * speed);",
            "mathf_approach": "return from + Mathf.clamp(to - from, -speed, speed);",
            "mathf_clamp_float": "public static float clamp(float value, float min, float max){",
        })
        self.assertEqual(report["missing"], [])

    def test_unit_update_boosting_event_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_unit_update_boosting_event_source"))
        report = source_parity.verify_unit_update_boosting_event_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/UnitComp.java")
        self.assertEqual(report["event_source"], "core/src/mindustry/game/EventType.java")
        self.assertEqual(report["checked"], {
            "event_gate": "if(event){",
            "fire_trigger": "Events.fire(Trigger.unitCommandBoost);",
            "trigger_enum": "public enum Trigger{",
            "unit_command_boost": "unitCommandBoost,",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_actively_building_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_actively_building_source"))
        report = source_parity.verify_builder_actively_building_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "method": "boolean activelyBuilding(){",
            "comment": "//not actively building when not near the build plan",
            "guard": "if(isBuilding()){",
            "plan_assignment": "var plan = buildPlan();",
            "range_guard": "if(!state.isEditor() && plan != null && !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){",
            "range_return_false": "return false;",
            "return_expr": "return isBuilding() && updateBuilding;",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_remove_build_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_remove_build_source"))
        report = source_parity.verify_builder_remove_build_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "method": "void removeBuild(int x, int y, boolean breaking){",
            "comment": "//remove matching plan",
            "index_expr": "int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);",
            "guard": "if(idx != -1){",
            "remove_index": "plans.removeIndex(idx);",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_add_build_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_add_build_source"))
        report = source_parity.verify_builder_add_build_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Add another build plans to the queue, if it doesn't exist there yet. */",
            "method": "void addBuild(BuildPlan place, boolean tail){",
            "can_build_guard": "if(!canBuild()) return;",
            "replace_init": "BuildPlan replace = null;",
            "plans_loop": "for(BuildPlan plan : plans){",
            "replace_match": "if(plan.x == place.x && plan.y == place.y){",
            "replace_assign": "replace = plan;",
            "replace_break": "break;",
            "replace_guard": "if(replace != null){",
            "remove_replace": "plans.remove(replace);",
            "tile_lookup": "Tile tile = world.tile(place.x, place.y);",
            "construct_guard": "if(tile != null && tile.build instanceof ConstructBuild cons){",
            "progress_assign": "place.progress = cons.progress;",
            "tail_guard": "if(tail){",
            "add_last": "plans.addLast(place);",
            "add_first": "plans.addFirst(place);",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_should_skip_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_should_skip_source"))
        report = source_parity.verify_builder_should_skip_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "comment": "/** @return whether this plan should be skipped, in favor of the next one. */",
            "method": "boolean shouldSkip(BuildPlan plan, @Nullable Building core){",
            "guard": "if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;",
            "return_expr": "return (plan.stuck && !core.items.has(plan.block.requirements)) ||\n            (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_draw_plan_top_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_draw_plan_top_source"))
        report = source_parity.verify_builder_draw_plan_top_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "method": "void drawPlanTop(BuildPlan plan, float alpha){",
            "guard": "if(!plan.breaking){",
            "draw_reset": "Draw.reset();",
            "mixcol": "Draw.mixcol(Color.white, 0.24f + Mathf.absin(Time.globalTime, 6f, 0.28f));",
            "draw_alpha": "Draw.alpha(alpha);",
            "draw_plan_config_top": "plan.block.drawPlanConfigTop(plan, plans);",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_draw_plan_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_draw_plan_source"))
        report = source_parity.verify_builder_draw_plan_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "method": "void drawPlan(BuildPlan plan, float alpha){",
            "anim_scale": "plan.animScale = 1f;",
            "breaking_guard": "if(plan.breaking){",
            "draw_breaking": "control.input.drawBreaking(plan);",
            "else_guard": "}else{",
            "draw_plan_start": "plan.block.drawPlan(plan, control.input.allPlans(),",
            "draw_plan_valid": "Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan),",
            "draw_plan_alpha": "alpha);",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_draw_building_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_draw_building_source"))
        report = source_parity.verify_builder_draw_building_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void drawBuilding(){",
            "todo_comment": "//TODO make this more generic so it works with builder \"weapons\"",
            "active_expr": "boolean active = activelyBuilding();",
            "inactive_guard": "if(!active && lastActive == null) return;",
            "z_flying": "Draw.z(Layer.flyingUnit);",
            "plan_expr": "BuildPlan plan = active ? buildPlan() : lastActive;",
            "tile_expr": "Tile tile = plan.tile();",
            "core_expr": "var core = team.core();",
            "range_guard": "if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){",
            "remote_comment": "//draw remote plans.",
            "remote_guard": "if(core != null && active && !isLocal() && !(tile.block() instanceof ConstructBlock) && !state.isPaused()){",
            "z_plans": "Draw.z(Layer.plans - 1f);",
            "draw_plan": "drawPlan(plan, 0.5f);",
            "draw_plan_top": "drawPlanTop(plan, 0.5f);",
            "beam_guard": "if(type.drawBuildBeam){",
            "focus_len": "float focusLen = type.buildBeamOffset + Mathf.absin(Time.time, 3f, 0.6f);",
            "px_expr": "float px = x + Angles.trnsx(rotation, focusLen);",
            "py_expr": "float py = y + Angles.trnsy(rotation, focusLen);",
            "draw_beam": "drawBuildingBeam(px, py);",
        })
        self.assertEqual(report["missing"], [])

    def test_builder_draw_building_beam_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_builder_draw_building_beam_source"))
        report = source_parity.verify_builder_draw_building_beam_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/entities/comp/BuilderComp.java")
        self.assertEqual(report["checked"], {
            "method": "public void drawBuildingBeam(float px, float py){",
            "active_expr": "boolean active = activelyBuilding();",
            "inactive_guard": "if(!active && lastActive == null) return;",
            "z_flying": "Draw.z(Layer.flyingUnit);",
            "plan_expr": "BuildPlan plan = active ? buildPlan() : lastActive;",
            "tile_expr": "Tile tile = world.tile(plan.x, plan.y);",
            "range_guard": "if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){",
            "size_expr": "int size = plan.breaking ? active ? tile.block().size : lastSize : plan.block.size;",
            "draw_xy": "float tx = plan.drawx(), ty = plan.drawy();",
            "stroke": "Lines.stroke(1f, plan.breaking ? Pal.remove : Pal.accent);",
            "z_build_beam": "Draw.z(Layer.buildBeam);",
            "alpha": "Draw.alpha(buildAlpha);",
            "fill_last_active": "if(!active && !(tile.build instanceof ConstructBuild)){",
            "fill_last_active_square": "Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);",
            "build_beam": "Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);",
            "focus_square": "Fill.square(px, py, 1.8f + Mathf.absin(Time.time, 2.2f, 1.1f), rotation + 45);",
            "draw_reset": "Draw.reset();",
            "z_restore": "Draw.z(Layer.flyingUnit);",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_outputs_items_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_outputs_items_source"))
        report = source_parity.verify_turret_outputs_items_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public boolean outputsItems(){",
            "return_false": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_init_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_init_source"))
        report = source_parity.verify_turret_init_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void init(){",
            "shoot_y_default": "if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;",
            "elevation_default": "if(elevation < 0) elevation = size / 2f;",
            "recoil_time_default": "if(recoilTime < 0f) recoilTime = reload;",
            "cooldown_time_default": "if(cooldownTime < 0f) cooldownTime = reload;",
            "new_target_interval_default": "if(newTargetInterval <= 0f) newTargetInterval = targetInterval;",
            "target_ground_guard": "if(!targetGround){",
            "disable_overlap_check": "disableOverlapCheck = true;",
            "super_init": "super.init();",
            "tracking_range": "trackingRange = Math.max(range, trackingRange);",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_load_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_load_source"))
        report = source_parity.verify_turret_load_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void load(){",
            "super_load": "super.load();",
            "drawer_load": "drawer.load(this);",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_draw_plan_region_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_draw_plan_region_source"))
        report = source_parity.verify_turret_draw_plan_region_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){",
            "drawer_draw_plan": "drawer.drawPlan(this, plan, list);",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_icons_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_icons_source"))
        report = source_parity.verify_turret_icons_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public TextureRegion[] icons(){",
            "drawer_final_icons": "return drawer.finalIcons(this);",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_get_regions_to_outline_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_get_regions_to_outline_source"))
        report = source_parity.verify_turret_get_regions_to_outline_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void getRegionsToOutline(Seq<TextureRegion> out){",
            "drawer_get_regions_to_outline": "drawer.getRegionsToOutline(this, out);",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_limit_range_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_limit_range_source"))
        report = source_parity.verify_turret_limit_range_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "method": "public void limitRange(BulletType bullet, float margin){",
            "real_range": "float realRange = bullet.rangeChange + range;",
            "drag_comment": "//doesn't handle drag",
            "lifetime": "bullet.lifetime = (realRange + margin + bullet.extraRangeMargin + 10f) / bullet.speed;",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_draw_place_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_draw_place_source"))
        report = source_parity.verify_turret_draw_place_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void drawPlace(int x, int y, int rotation, boolean valid){",
            "super_draw_place": "super.drawPlace(x, y, rotation, valid);",
            "draw_min_range_gate": "if(drawMinRange){",
            "dash_circle": "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, minRange, Pal.placing);",
            "draw_min_range_field": "public boolean drawMinRange;",
            "min_range_field": "public float minRange = 0f;",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_rotated_output_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_rotated_output_source"))
        report = source_parity.verify_turret_rotated_output_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public boolean rotatedOutput(int x, int y){",
            "return_false": "return false;",
        })
        self.assertEqual(report["missing"], [])

    def test_turret_place_ended_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_turret_place_ended_source"))
        report = source_parity.verify_turret_place_ended_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/Turret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void placeEnded(Tile tile, @Nullable Unit builder, int rotation, @Nullable Object config){",
            "super_place_ended": "super.placeEnded(tile, builder, rotation, config);",
            "place_ended_gate": "if(rotate && tile.build instanceof TurretBuild turret){",
            "rotation_assign": "turret.rotation = tile.build.rotdeg();",
        })
        self.assertEqual(report["missing"], [])

    def test_reload_turret_set_stats_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_reload_turret_set_stats_source"))
        report = source_parity.verify_reload_turret_set_stats_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void setStats(){",
            "super_set_stats": "super.setStats();",
            "coolant_gate": "if(coolant != null){",
            "booster_replace": "stats.replace(Stat.booster, StatValues.boosters(reload, coolant.amount, coolantMultiplier, true, coolant::consumes));",
            "reload_field": "public float reload = 10f;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_set_stats_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_set_stats_source"))
        report = source_parity.verify_power_turret_set_stats_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void setStats(){",
            "super_set_stats": "super.setStats();",
            "stats_add": "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));",
            "shoot_type_field": "public BulletType shootType;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_limit_range_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_limit_range_source"))
        report = source_parity.verify_power_turret_limit_range_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "method": "public void limitRange(float margin){",
            "dispatch": "limitRange(shootType, margin);",
            "shoot_type_field": "public BulletType shootType;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_build_get_ammo_fraction_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_build_get_ammo_fraction_source"))
        report = source_parity.verify_power_turret_build_get_ammo_fraction_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class PowerTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public float getAmmoFraction(){",
            "return_expr": "return power == null ? 0f : power.status;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_build_sense_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_build_sense_source"))
        report = source_parity.verify_power_turret_build_sense_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class PowerTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public double sense(LAccess sensor){",
            "switch_return": "return switch(sensor){",
            "ammo_case": "case ammo -> power == null ? 0f : power.status;",
            "ammo_capacity_case": "case ammoCapacity -> 1;",
            "default_case": "default -> super.sense(sensor);",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_build_use_ammo_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_build_use_ammo_source"))
        report = source_parity.verify_power_turret_build_use_ammo_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class PowerTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public BulletType useAmmo(){",
            "comment": "//nothing used directly",
            "return_expr": "return shootType;",
            "shoot_type_field": "public BulletType shootType;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_build_has_ammo_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_build_has_ammo_source"))
        report = source_parity.verify_power_turret_build_has_ammo_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class PowerTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public boolean hasAmmo(){",
            "comment": "//you can always rotate, but never shoot if there's no power",
            "return_expr": "return true;",
        })
        self.assertEqual(report["missing"], [])

    def test_power_turret_build_peek_ammo_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_power_turret_build_peek_ammo_source"))
        report = source_parity.verify_power_turret_build_peek_ammo_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/PowerTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class PowerTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public BulletType peekAmmo(){",
            "return_expr": "return shootType;",
            "shoot_type_field": "public BulletType shootType;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_limit_range_default_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_limit_range_default_source"))
        report = source_parity.verify_item_turret_limit_range_default_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Limits bullet range to this turret's range value. */",
            "method": "public void limitRange(){",
            "dispatch_expr": "limitRange(9f);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_limit_range_entries_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_limit_range_entries_source"))
        report = source_parity.verify_item_turret_limit_range_entries_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "comment": "/** Limits bullet range to this turret's range value. */",
            "method": "public void limitRange(float margin){",
            "loop_expr": "for(var entry : ammoTypes.entries()){",
            "dispatch_expr": "limitRange(entry.value, margin);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_set_stats_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_set_stats_source"))
        report = source_parity.verify_item_turret_set_stats_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void setStats(){",
            "super_set_stats": "super.setStats();",
            "stats_remove": "stats.remove(Stat.itemCapacity);",
            "stats_ammo_add": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));",
            "stats_ammo_capacity_add": "stats.add(Stat.ammoCapacity, maxAmmo / Math.max(ammoPerShot, 1), StatUnit.shots);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_set_bars_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_set_bars_source"))
        report = source_parity.verify_item_turret_set_bars_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void setBars(){",
            "super_set_bars": "super.setBars();",
            "add_bar": "addBar(\"ammo\", (ItemTurretBuild entity) ->",
            "bar_text": "\"stat.ammo\",",
            "bar_color": "Pal.ammo,",
            "bar_fraction": "() -> (float)entity.totalAmmo / maxAmmo",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_init_ground_overlap_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_init_ground_overlap_source"))
        report = source_parity.verify_item_turret_init_ground_overlap_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void init(){",
            "consume_filter": "consume(new ConsumeItemFilter(i -> ammoTypes.containsKey(i)){",
            "target_ground_guard": "if(targetGround){",
            "overlap_update": "ammoTypes.each((item, type) -> placeOverlapRange = Math.max(placeOverlapRange, range + type.rangeChange + placeOverlapMargin));",
            "super_init": "super.init();",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_on_proximity_added_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_on_proximity_added_source"))
        report = source_parity.verify_item_turret_build_on_proximity_added_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public void onProximityAdded(){",
            "super_on_proximity_added": "super.onProximityAdded();",
            "comment": "//add first ammo item to cheaty blocks so they can shoot properly",
            "guard": "if(!hasAmmo() && cheating() && ammoTypes.size > 0){",
            "handle_item": "handleItem(this, ammoTypes.keys().next());",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_sense_object_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_sense_object_source"))
        report = source_parity.verify_item_turret_build_sense_object_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public Object senseObject(LAccess sensor){",
            "switch_return": "return switch(sensor){",
            "current_ammo_type_case": "case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;",
            "default_case": "default -> super.senseObject(sensor);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_get_ammo_content_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_get_ammo_content_source"))
        report = source_parity.verify_item_turret_build_get_ammo_content_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public UnlockableContent getAmmoContent(){",
            "return_expr": "return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_get_ammo_fraction_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_get_ammo_fraction_source"))
        report = source_parity.verify_item_turret_build_get_ammo_fraction_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public float getAmmoFraction(){",
            "return_expr": "return (float)totalAmmo / maxAmmo;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_accept_stack_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_accept_stack_source"))
        report = source_parity.verify_item_turret_build_accept_stack_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public int acceptStack(Item item, int amount, Teamc source){",
            "type_lookup": "BulletType type = ammoTypes.get(item);",
            "null_guard": "if(type == null) return 0;",
            "return_expr": "return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_handle_stack_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_handle_stack_source"))
        report = source_parity.verify_item_turret_build_handle_stack_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public void handleStack(Item item, int amount, Teamc source){",
            "loop_expr": "for(int i = 0; i < amount; i++){",
            "handle_item_expr": "handleItem(null, item);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_remove_stack_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_remove_stack_source"))
        report = source_parity.verify_item_turret_build_remove_stack_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "comment": "//currently can't remove items from turrets.",
            "override": "@Override",
            "method": "public int removeStack(Item item, int amount){",
            "return_expr": "return 0;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_handle_item_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_handle_item_source"))
        report = source_parity.verify_item_turret_build_handle_item_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public void handleItem(Building source, Item item){",
            "todo_comment": "//TODO instead of all this \"entry\" crap, turrets could just accept only one type of ammo at a time - simpler for both users and the code",
            "pyratite_guard": "if(item == Items.pyratite){",
            "flame_event": "Events.fire(Trigger.flameAmmo);",
            "resupply_guard": "if(totalAmmo == 0){",
            "resupply_event": "Events.fire(Trigger.resupplyTurret);",
            "type_lookup": "BulletType type = ammoTypes.get(item);",
            "type_null_guard": "if(type == null) return;",
            "total_ammo_update": "totalAmmo += type.ammoMultiplier;",
            "loop_expr": "for(int i = 0; i < ammo.size; i++){",
            "entry_cast": "ItemEntry entry = (ItemEntry)ammo.get(i);",
            "found_guard": "if(entry.item == item){",
            "entry_update": "entry.amount += type.ammoMultiplier;",
            "swap_expr": "ammo.swap(i, ammo.size - 1);",
            "add_expr": "ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_accept_item_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_accept_item_source"))
        report = source_parity.verify_item_turret_build_accept_item_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public boolean acceptItem(Building source, Item item){",
            "return_expr": "return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_version_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_version_source"))
        report = source_parity.verify_item_turret_build_version_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public byte version(){",
            "return_expr": "return 2;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_write_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_write_source"))
        report = source_parity.verify_item_turret_build_write_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public void write(Writes write){",
            "super_write": "super.write(write);",
            "write_size": "write.b(ammo.size);",
            "loop_expr": "for(AmmoEntry entry : ammo){",
            "entry_cast": "ItemEntry i = (ItemEntry)entry;",
            "write_item_id": "write.s(i.item.id);",
            "write_amount": "write.s(i.amount);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_turret_build_read_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_turret_build_read_source"))
        report = source_parity.verify_item_turret_build_read_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemTurretBuild extends TurretBuild{",
            "override": "@Override",
            "method": "public void read(Reads read, byte revision){",
            "super_read": "super.read(read, revision);",
            "clear_expr": "ammo.clear();",
            "total_reset": "totalAmmo = 0;",
            "amount_expr": "int amount = read.ub();",
            "loop_expr": "for(int i = 0; i < amount; i++){",
            "item_lookup": "Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());",
            "item_amount": "int itemAmount = Math.min(read.s(), maxAmmo);",
            "valid_comment": "//only add ammo if this is a valid ammo type",
            "valid_guard": "if(item != null && ammoTypes.containsKey(item)){",
            "total_add": "totalAmmo += itemAmount;",
            "ammo_add": "ammo.add(new ItemEntry(item, itemAmount));",
        })
        self.assertEqual(report["missing"], [])

    def test_item_entry_constructor_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_entry_constructor_source"))
        report = source_parity.verify_item_entry_constructor_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemEntry extends AmmoEntry{",
            "field": "public Item item;",
            "constructor": "ItemEntry(Item item, int amount){",
            "item_assign": "this.item = item;",
            "amount_assign": "this.amount = amount;",
        })
        self.assertEqual(report["missing"], [])

    def test_item_entry_type_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_entry_type_source"))
        report = source_parity.verify_item_entry_type_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemEntry extends AmmoEntry{",
            "override": "@Override",
            "method": "public BulletType type(){",
            "return_expr": "return ammoTypes.get(item);",
        })
        self.assertEqual(report["missing"], [])

    def test_item_entry_to_string_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_item_entry_to_string_source"))
        report = source_parity.verify_item_entry_to_string_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/ItemTurret.java")
        self.assertEqual(report["checked"], {
            "inner_class": "public class ItemEntry extends AmmoEntry{",
            "override": "@Override",
            "method": "public String toString(){",
            "return_start": "return \"ItemEntry{\" +",
            "item_concat": "\"item=\" + item +",
            "amount_concat": "\", amount=\" + amount +",
            "return_end": "'}';",
        })
        self.assertEqual(report["missing"], [])

    def test_liquid_turret_ammo_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_liquid_turret_ammo_source"))
        report = source_parity.verify_liquid_turret_ammo_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java")
        self.assertEqual(report["checked"], {
            "field": "public ObjectMap<Liquid, BulletType> ammoTypes = new ObjectMap<>();",
            "comment": "/** Initializes accepted ammo map. Format: [liquid1, bullet1, liquid2, bullet2...] */",
            "method": "public void ammo(Object... objects){",
            "assignment": "ammoTypes = ObjectMap.of(objects);",
        })
        self.assertEqual(report["missing"], [])

    def test_liquid_turret_set_stats_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_liquid_turret_set_stats_source"))
        report = source_parity.verify_liquid_turret_set_stats_source(ROOT / "mindustry-upstream")

        self.assertEqual(report["source"], "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java")
        self.assertEqual(report["checked"], {
            "override": "@Override",
            "method": "public void setStats(){",
            "super_set_stats": "super.setStats();",
            "stats_add": "stats.add(Stat.ammo, StatValues.ammo(ammoTypes, name));",
        })
        self.assertEqual(report["missing"], [])

if __name__ == "__main__":
    unittest.main()
