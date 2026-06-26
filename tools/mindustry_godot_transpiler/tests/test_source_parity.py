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

if __name__ == "__main__":
    unittest.main()
