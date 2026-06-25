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

if __name__ == "__main__":
    unittest.main()
