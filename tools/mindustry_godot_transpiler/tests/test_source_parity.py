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
if __name__ == "__main__":
    unittest.main()
