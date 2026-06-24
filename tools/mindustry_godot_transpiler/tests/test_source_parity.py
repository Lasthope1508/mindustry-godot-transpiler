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

if __name__ == "__main__":
    unittest.main()
