import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class TileSliceTests(unittest.TestCase):
    def test_tile_coordinate_cluster_is_emitted_as_source_backed_bridge(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "world" / "Tile.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.world;
public class Tile{
    public int pos(){ return Point2.pack(x, y); }
    public int array(){ return x + y * world.tiles.width; }
    public byte relativeTo(Tile tile){ return relativeTo(tile.x, tile.y); }
    public byte relativeTo(int cx, int cy){ return -1; }
    public static byte relativeTo(int x, int y, int cx, int cy){ return -1; }
    public static int relativeTo(float x, float y, float cx, float cy){ return -1; }
    public byte absoluteRelativeTo(int cx, int cy){ return -1; }
    public float getFlammability(){ return 0f; }
    public boolean inMapArea(){ return true; }
    public boolean isCenter(){ return true; }
    public int centerX(){ return x; }
    public int centerY(){ return y; }
    public int getTeamID(){ return team().id; }
    public Floor floor(){ return floor; }
    public Block block(){ return block; }
    public Floor overlay(){ return overlay; }
        public <T extends Block> T cblock(){ return (T)block; }
        public Team team(){ return build == null ? Team.derelict : build.team; }
        public void setTeam(Team team){ if(build != null){ build.team(team); } }
        public static void setTeam(Building build, Team team){ if(build != null){ build.changeTeam(team); } }
        public static void setTeams(int[] positions, Team team){ if(positions == null) return; staleGraphs.clear(); for(int pos : positions){ var build = world.build(pos); if(build != null){ build.changeTeam(team, false); } } }
        public static void buildDestroyed(Building build){ if(build == null) return; build.killed(); }
        public static void buildHealthUpdate(IntSeq buildings){ for(int i = 0; i < buildings.size; i += 2){ int pos = buildings.items[i]; float health = Float.intBitsToFloat(buildings.items[i + 1]); var build = world.build(pos); if(build != null && build.health != health){ build.health = health; indexer.notifyHealthChanged(build); } } }
        public short overlayID(){ return overlay.id; }
        public short blockID(){ return block.id; }
        public short floorID(){ return floor.id; }
        public boolean passable(){ return !((floor.solid && (block == Blocks.air || block.solidifes)) || (block.solid && (!block.destructible && !block.update))); }
        public boolean synthetic(){ return block.update || block.destructible; }
        public boolean solid(){ return block.solid || floor.solid || (build != null && build.checkSolid()); }
        public boolean breakable(){ return block.destructible || block.breakable || block.update; }
        public boolean dangerous(){ return !block.solid && (floor.isDeep() || floor.damages()); }
        public boolean isDarkened(){ return block.isDarkened(this); }
    public void getLinkedTiles(Cons<Tile> cons){ if(block.isMultiblock()){ int size = block.size, o = block.sizeOffset; for(int dx = 0; dx < size; dx++){ for(int dy = 0; dy < size; dy++){ Tile other = world.tile(x + dx + o, y + dy + o); if(other != null) cons.get(other); } } }else{ cons.get(this); } }
    public Seq<Tile> getLinkedTiles(Seq<Tile> tmpArray){ tmpArray.clear(); getLinkedTiles(tmpArray::add); return tmpArray; }
    public Seq<Tile> getLinkedTilesAs(Block block, Seq<Tile> tmpArray){ tmpArray.clear(); getLinkedTilesAs(block, tmpArray::add); return tmpArray; }
    public void getLinkedTilesAs(Block block, Cons<Tile> tmpArray){ if(block.isMultiblock()){ int size = block.size, o = block.sizeOffset; for(int dx = 0; dx < size; dx++){ for(int dy = 0; dy < size; dy++){ Tile other = world.tile(x + dx + o, y + dy + o); if(other != null) tmpArray.get(other); } } }else{ tmpArray.get(this); } }
    public Rect getHitbox(Rect rect){ return rect.setCentered(drawx(), drawy(), block.size * tilesize, block.size * tilesize); }
    public Rect getBounds(Rect rect){ return rect.set(x * tilesize - tilesize/2f, y * tilesize - tilesize/2f, tilesize, tilesize); }
    public void hitbox(Rect rect){ getHitbox(rect); }
    public Tile nearby(Point2 relative){ return world.tile(x + relative.x, y + relative.y); }
    public Tile nearby(int dx, int dy){ return world.tile(x + dx, y + dy); }
    public Tile nearby(int rotation){ return switch(rotation){ case 0 -> world.tile(x + 1, y); case 1 -> world.tile(x, y + 1); case 2 -> world.tile(x - 1, y); case 3 -> world.tile(x, y - 1); default -> null; }; }
        public Building nearbyBuild(int rotation){ return switch(rotation){ case 0 -> world.build(x + 1, y); case 1 -> world.build(x, y + 1); case 2 -> world.build(x - 1, y); case 3 -> world.build(x, y - 1); default -> null; }; }
        public boolean interactable(Team team){ return state.teams.canInteract(team, team()); }
        public @Nullable Item drop(){ return overlay == Blocks.air || overlay.itemDrop == null ? floor.itemDrop : overlay.itemDrop; }
        public @Nullable Item wallDrop(){ return block.solid ? block.itemDrop != null ? block.itemDrop : overlay.wallOre && !block.synthetic() ? overlay.itemDrop : null : null; }
        public boolean shouldSaveData(){ return floor.saveData || overlay.saveData || block.saveData; }
        public int staticDarkness(){ return block.solid && block.fillsTile && !block.synthetic() ? data : 0; }
        public boolean legSolid(){ return staticDarkness() >= 2 || (floor.solid && block == Blocks.air); }
        public boolean adjacentTo(Tile tile){ return relativeTo(tile) != -1; }
        protected void preChanged(){ firePreChanged(); if(build != null){ build.onRemoved(); build.removeFromProximity(); if(build.block.isMultiblock()){ for(Tile other : world.tiles()){ if(other != this){ other.firePreChanged(); other.build = null; other.block = Blocks.air; other.fireChanged(); } } } } }
        public long getPackedData(){ return PackedTileData.get(extraData, data, floorData, overlayData); }
        public void setPackedData(long packed){ extraData = PackedTileData.extraData(packed); data = PackedTileData.data(packed); floorData = PackedTileData.floorData(packed); overlayData = PackedTileData.overlayData(packed); }
        public float getX(){ return drawx(); }
        public float getY(){ return drawy(); }
        public String toString(){ return floor.name + ":" + block.name + ":" + overlay + "[" + x + "," + y + "] " + "entity=" + (build == null ? "null" : (build.getClass().getSimpleName())) + ":" + team(); }
        protected void fireChanged(){ if(!world.isGenerating()){ Events.fire(tileChange.set(this)); } }
        protected void firePreChanged(){ if(!world.isGenerating()){ Events.fire(preChange.set(this)); } }
        protected void changed(){ if(!world.isGenerating()){ if(build != null){ build.updateProximity(); } else { for(Point2 p : Geometry.d4){ Building tile = world.build(x + p.x, y + p.y); if(tile != null && !tile.tile.changing){ tile.onProximityUpdate(); } } } } fireChanged(); if(block.isStatic()){ recache(); } }
        public float worldx(){ return x * tilesize; }
    public float worldy(){ return y * tilesize; }
    public float drawx(){ return block().offset + worldx(); }
    public float drawy(){ return block().offset + worldy(); }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = (output_root / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
            self.assertIn("return source_block_geometry.tile_pos_state(x, y)", emitted)
            self.assertIn("return source_block_geometry.tile_array_state(x, y, world_width)", emitted)
            self.assertIn("return source_block_geometry.tile_relative_cardinal_state(x, y, cx, cy)", emitted)
            self.assertIn("return source_block_geometry.tile_relative_float_state(x, y, cx, cy)", emitted)
            self.assertIn("return source_block_geometry.tile_absolute_relative_state(x, y, cx, cy, block_size)", emitted)
            self.assertIn("return source_block_geometry.tile_flammability_state(block_is_air, floor_liquid_drop_present, floor_liquid_flammability, build_present, block_has_items, build_items_total, item_flammability_sum, block_item_capacity, block_has_liquids, liquid_flammability_sum, block_liquid_capacity)", emitted)
            self.assertIn("return source_block_geometry.tile_in_map_area_state(x, y, limit_map_area, limit_x, limit_y, limit_width, limit_height)", emitted)
            self.assertIn("return source_block_geometry.tile_is_center_state(build_present, build_tile_is_self)", emitted)
            self.assertIn("return source_block_geometry.tile_center_x_state(x, build_present, build_tile_x)", emitted)
            self.assertIn("return source_block_geometry.tile_center_y_state(y, build_present, build_tile_y)", emitted)
            self.assertIn("return source_block_geometry.tile_team_id_state(build_present, build_team_id, derelict_team_id)", emitted)
            self.assertIn("return source_block_geometry.tile_reference_state(value)", emitted)
            self.assertIn("return source_block_geometry.tile_team_state(build_present, build_team, derelict_team)", emitted)
            self.assertIn("return source_block_geometry.tile_set_team_state(build_present, team)", emitted)
            self.assertIn('return source_block_geometry.tile_static_callback_state("set_team", build != null, build, team, [], [], [], [], [])', emitted)
            self.assertIn('return source_block_geometry.tile_static_callback_state("set_teams", false, null, team, positions, first_pass, second_pass, [], [], positions_present)', emitted)
            self.assertIn('return source_block_geometry.tile_static_callback_state("build_destroyed", build != null, build, null, [], [], [], [], [])', emitted)
            self.assertIn('return source_block_geometry.tile_static_callback_state("build_health_update", false, null, null, [], [], [], [], health_updates)', emitted)

            self.assertIn('return source_block_geometry.tile_id_state("overlay", overlay)', emitted)
            self.assertIn('return source_block_geometry.tile_id_state("block", block)', emitted)
            self.assertIn('return source_block_geometry.tile_id_state("floor", floor)', emitted)
            self.assertIn("return source_block_geometry.tile_passable_state(floor_solid, block_is_air, block_solidifies, block_solid, block_destructible, block_update)", emitted)
            self.assertIn("return source_block_geometry.tile_synthetic_state(block_update, block_destructible)", emitted)
            self.assertIn("return source_block_geometry.tile_solid_state(block_solid, floor_solid, build_present, build_check_solid)", emitted)
            self.assertIn("return source_block_geometry.tile_breakable_state(block_destructible, block_breakable, block_update)", emitted)
            self.assertIn("return source_block_geometry.tile_dangerous_state(block_solid, floor_is_deep, floor_damages)", emitted)
            self.assertIn("return source_block_geometry.tile_get_linked_tiles_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, consumer)", emitted)
            self.assertIn("return source_block_geometry.tile_get_linked_tiles_array_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, tmp_array)", emitted)
            self.assertIn("return source_block_geometry.tile_get_linked_tiles_as_array_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, tmp_array)", emitted)
            self.assertIn("return source_block_geometry.tile_get_linked_tiles_as_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, consumer)", emitted)
            self.assertIn("return source_block_geometry.tile_get_hitbox_state(x, y, block_size, source_tilesize, block_offset, rect_value)", emitted)
            self.assertIn("return source_block_geometry.tile_get_bounds_state(x, y, source_tilesize, rect_value)", emitted)
            self.assertIn("return source_block_geometry.tile_hitbox_state(x, y, block_size, source_tilesize, block_offset, rect_value)", emitted)
            self.assertIn("return source_block_geometry.tile_nearby_relative_state(x, y, relative_x, relative_y, world_tile_lookup)", emitted)
            self.assertIn("return source_block_geometry.tile_nearby_delta_state(x, y, delta_x, delta_y, world_tile_lookup)", emitted)
            self.assertIn("return source_block_geometry.tile_nearby_rotation_state(x, y, rotation, world_tile_lookup)", emitted)
            self.assertIn("return source_block_geometry.tile_nearby_build_rotation_state(x, y, rotation, world_build_lookup)", emitted)
            self.assertIn("return source_block_geometry.tile_interactable_state(can_interact)", emitted)
            self.assertIn("return source_block_geometry.tile_drop_state(overlay_is_air, overlay_item_drop, floor_item_drop)", emitted)
            self.assertIn("return source_block_geometry.tile_wall_drop_state(block_solid, block_item_drop, overlay_wall_ore, block_synthetic, overlay_item_drop)", emitted)
            self.assertIn("return source_block_geometry.tile_should_save_data_state(floor_save_data, overlay_save_data, block_save_data)", emitted)
            self.assertIn("return source_block_geometry.tile_static_darkness_state(block_solid, block_fills_tile, block_synthetic, data)", emitted)
            self.assertIn("return source_block_geometry.tile_leg_solid_state(static_darkness, floor_solid, block_is_air)", emitted)
            self.assertIn("return source_block_geometry.tile_adjacent_state(relative_result)", emitted)
            self.assertIn("return source_block_geometry.tile_packed_data_state(extra_data, data, floor_data, overlay_data)", emitted)
            self.assertIn("return source_block_geometry.tile_unpack_data_state(packed)", emitted)
            self.assertIn("return source_block_geometry.tile_coordinate_display_state(draw_x)", emitted)
            self.assertIn("return source_block_geometry.tile_coordinate_display_state(draw_y)", emitted)
            self.assertIn("return source_block_geometry.tile_to_string_state(floor_name, block_name, overlay_text, x, y, build_present, build_class_name, team_text)", emitted)
            self.assertIn("return source_block_geometry.tile_fire_change_state(world_generating, event_call)", emitted)
            self.assertIn("return source_block_geometry.tile_changed_state(world_generating, build_present, nearby_buildings, block_static, event_call)", emitted)
            self.assertIn("return source_block_geometry.tile_pre_changed_state(world_generating, build_present, block_is_multiblock, multiblock_tiles, self_tile, pre_event_call, changed_event_call)", emitted)
            self.assertIn("return source_block_geometry.tile_coordinate_display_state(draw_x)", emitted)
            self.assertIn("return source_block_geometry.tile_coordinate_display_state(draw_y)", emitted)
            self.assertIn("return source_block_geometry.tile_to_string_state(floor_name, block_name, overlay_text, x, y, build_present, build_class_name, team_text)", emitted)
            self.assertIn("return source_block_geometry.tile_is_darkened_state(block_is_darkened)", emitted)
            self.assertIn("return source_block_geometry.tile_set_team_state(build_present, team)", emitted)
            self.assertIn("return source_block_geometry.tile_worldx_state(x, source_tilesize)", emitted)
            self.assertIn("return source_block_geometry.tile_worldy_state(y, source_tilesize)", emitted)
            self.assertIn("return source_block_geometry.tile_drawx_state(x, source_tilesize, block_offset)", emitted)
            self.assertIn("return source_block_geometry.tile_drawy_state(y, source_tilesize, block_offset)", emitted)
            self.assertNotIn("func java_method_pos_0(_args: Array = []) -> Variant:\n\treturn null", emitted)

    def test_tile_static_callbacks_are_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for method_name in ("setTeam", "setTeams", "buildDestroyed", "buildHealthUpdate"):
            self.assertIn("func java_method_%s_" % method_name, source)
        for symbol_name in ("tile.set_team_callback", "tile.set_teams", "tile.build_destroyed", "tile.build_health_update"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1822")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_static_callback_state")
        self.assertEqual(ledger["slices"]["N1822"]["status"], "done")

    def test_tile_set_block_slice_is_emitted_and_source_backed(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for method_name in ("setBlock",):
            self.assertIn("func java_method_%s_" % method_name, source)
        self.assertIn('tile_set_block_delegate_state("type_team_rotation"', source)
        self.assertIn("tile_set_block_state(world_generating, type_value, team_value", source)
        for symbol_name in ("tile.set_block_default", "tile.set_block", "tile.set_block_team", "tile.set_block_type"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1823")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_set_block_state")
        self.assertEqual(ledger["slices"]["N1823"]["status"], "done")

    def test_tile_set_block_slice_has_source_text_ssot(self):
        source_text = ROOT / "godot-mindustry" / "src" / "game" / "SourceTileSetBlockSourceTextState.gd"
        source = source_text.read_text(encoding="utf-8")
        self.assertIn("class_name SourceTileSetBlockSourceTextState", source)
        self.assertIn('const SOURCE_TILE_SET_BLOCK_METHOD := "public void setBlock(Block type, Team team, int rotation, Prov<Building> entityprov){"', source)

    def test_tile_set_floor_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("func java_method_setFloor_28(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_set_floor_state(type_value, previous_floor", source)
        self.assertNotIn("func java_method_setFloor_28(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertEqual(registry["symbols"]["tile.set_floor_instance"]["source_slice"], "N1824")
        self.assertEqual(registry["symbols"]["tile.set_floor_instance"]["godot_owner"], "SourceBlockGeometry.tile_set_floor_state")
        self.assertEqual(ledger["slices"]["N1824"]["status"], "done")

    def test_tile_set_floor_slice_has_source_text_ssot(self):
        source_text = ROOT / "godot-mindustry" / "src" / "game" / "SourceTileSetFloorSourceTextState.gd"
        source = source_text.read_text(encoding="utf-8")
        self.assertIn("class_name SourceTileSetFloorSourceTextState", source)
        self.assertIn('const SOURCE_TILE_SET_FLOOR_METHOD := "public void setFloor(Floor type){"', source)

    def test_tile_set_air_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("func java_method_setAir_30(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_set_air_state(air_block)", source)
        self.assertNotIn("func java_method_setAir_30(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertEqual(registry["symbols"]["tile.set_air"]["source_slice"], "N1825")
        self.assertEqual(registry["symbols"]["tile.set_air"]["godot_owner"], "SourceBlockGeometry.tile_set_air_state")
        self.assertEqual(ledger["slices"]["N1825"]["status"], "done")

    def test_tile_remove_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("func java_method_remove_36(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_remove_state(air_block)", source)
        self.assertNotIn("func java_method_remove_36(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertEqual(registry["symbols"]["tile.remove"]["source_slice"], "N1829")
        self.assertEqual(registry["symbols"]["tile.remove"]["godot_owner"], "SourceBlockGeometry.tile_remove_state")
        self.assertEqual(ledger["slices"]["N1829"]["status"], "done")

    def test_tile_network_mutation_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for method_name in ("removeNet", "setNet", "setFloorNet", "setOverlayNet"):
            self.assertIn("func java_method_%s_" % method_name, source)
        self.assertIn('tile_network_mutation_state("remove_net"', source)
        self.assertIn('tile_network_mutation_state("set_net_default"', source)
        self.assertIn('tile_network_mutation_state("set_net"', source)
        self.assertIn('tile_network_mutation_state("set_floor_net"', source)
        self.assertIn('tile_network_mutation_state("set_floor_net_default"', source)
        self.assertIn('tile_network_mutation_state("set_overlay_net"', source)
        for symbol_name in ("tile.remove_net", "tile.set_net_default", "tile.set_net", "tile.set_floor_net", "tile.set_floor_net_default", "tile.set_overlay_net"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1830")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_network_mutation_state")
        self.assertEqual(ledger["slices"]["N1830"]["status"], "done")

    def test_tile_overlay_mutation_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("tile_overlay_mutation_state(\"set_overlay\"", source)
        self.assertIn("tile_overlay_mutation_state(\"set_overlay_quiet\"", source)
        self.assertIn("tile_overlay_mutation_state(\"clear_overlay\"", source)
        for symbol_name in ("tile.set_overlay_instance", "tile.set_overlay_quiet", "tile.clear_overlay"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1831")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_overlay_mutation_state")
        self.assertEqual(ledger["slices"]["N1831"]["status"], "done")

    def test_tile_circle_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn('tile_circle_state("int"', source)
        self.assertIn('tile_circle_state("tile"', source)
        for symbol_name in ("tile.circle_int", "tile.circle_tile"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1832")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_circle_state")
        self.assertEqual(ledger["slices"]["N1832"]["status"], "done")

    def test_tile_editor_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("func java_method_isEditorTile_29(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_editor_state()", source)
        self.assertNotIn("func java_method_isEditorTile_29(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertEqual(registry["symbols"]["tile.is_editor_tile"]["source_slice"], "N1826")
        self.assertEqual(registry["symbols"]["tile.is_editor_tile"]["godot_owner"], "SourceBlockGeometry.tile_editor_state")
        self.assertEqual(ledger["slices"]["N1826"]["status"], "done")

    def test_tile_floor_color_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("func java_method_getFloorColor_33(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_floor_color_state(floor_color, tile_value)", source)
        self.assertNotIn("func java_method_getFloorColor_33(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertEqual(registry["symbols"]["tile.get_floor_color"]["source_slice"], "N1827")
        self.assertEqual(registry["symbols"]["tile.get_floor_color"]["godot_owner"], "SourceBlockGeometry.tile_floor_color_state")
        self.assertEqual(ledger["slices"]["N1827"]["status"], "done")

    def test_tile_recache_slice_is_emitted_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("func java_method_recacheWall_34(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_recache_wall_state(headless, world_generating, tile_value)", source)
        self.assertIn("func java_method_recache_35(_args: Array = []) -> Variant:", source)
        self.assertIn("tile_recache_state(headless, world_generating, tile_value, neighbor_tiles)", source)
        self.assertNotIn("func java_method_recacheWall_34(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertNotIn("func java_method_recache_35(_args: Array = []) -> Variant:\n\treturn null", source)
        self.assertEqual(registry["symbols"]["tile.recache_wall"]["source_slice"], "N1828")
        self.assertEqual(registry["symbols"]["tile.recache"]["source_slice"], "N1828")
        self.assertEqual(ledger["slices"]["N1828"]["status"], "done")

    def test_tile_runtime_proof_covers_generated_coordinate_cluster(self):
        proof = (ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "TileModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("java_method_pos_0", proof)
        self.assertIn("java_method_relativeTo_5", proof)
        self.assertIn("source_geometry.tile_pos_state", proof)
        self.assertIn('runtime_proof_state.write_proof("TileModuleProof", proof)', proof)
        self.assertIn("[2, 4, 3, 4]", proof)
        self.assertIn("java_method_absoluteRelativeTo_6", proof)
        self.assertIn("java_method_getFlammability_7", proof)
        self.assertIn("absolute_relative", proof)
        self.assertIn("flammability", proof)
        self.assertIn("java_method_inMapArea_8", proof)
        self.assertIn("in_map_area", proof)
        self.assertIn("java_method_isCenter_20", proof)
        self.assertIn("is_center", proof)
        self.assertIn("java_method_centerX_21", proof)
        self.assertIn("java_method_centerY_22", proof)
        self.assertIn("java_method_getTeamID_23", proof)
        self.assertIn("center_coordinates", proof)
        self.assertIn("team_id", proof)
        self.assertIn("java_method_floor_14", proof)
        self.assertIn("java_method_block_15", proof)
        self.assertIn("java_method_overlay_16", proof)
        self.assertIn("java_method_cblock_17", proof)
        self.assertIn("java_method_team_18", proof)
        self.assertIn("java_method_isDarkened_13", proof)
        self.assertIn("is_darkened", proof)
        self.assertIn("java_method_getLinkedTiles_54", proof)
        self.assertIn("java_method_getLinkedTiles_55", proof)
        self.assertIn("java_method_getLinkedTilesAs_56", proof)
        self.assertIn("java_method_getLinkedTilesAs_57", proof)
        self.assertIn("linked_callback_tiles", proof)
        self.assertIn("java_method_getHitbox_58", proof)
        self.assertIn("java_method_getBounds_59", proof)
        self.assertIn("java_method_hitbox_60", proof)
        self.assertIn("hitbox_state", proof)
        self.assertIn("bounds_state", proof)
        self.assertNotIn("tile.free()", proof)
        self.assertIn("java_method_shouldSaveData_68", proof)
        self.assertIn("java_method_staticDarkness_69", proof)
        self.assertIn("java_method_legSolid_70", proof)
        self.assertIn("java_method_adjacentTo_71", proof)
        self.assertIn("java_method_getPackedData_77", proof)
        self.assertIn("java_method_setPackedData_78", proof)
        self.assertIn("java_method_getX_80", proof)
        self.assertIn("java_method_getY_81", proof)
        self.assertIn("java_method_toString_82", proof)
        self.assertIn("java_method_fireChanged_75", proof)
        self.assertIn("java_method_firePreChanged_76", proof)
        self.assertIn("java_method_changed_74", proof)
        self.assertIn("java_method_preChanged_72", proof)
        self.assertIn("java_method_changeBuild_73", proof)
        self.assertIn("change_build_with_old", proof)
        self.assertIn("change_build_no_old", proof)
        self.assertIn("java_method_display_79", proof)
        self.assertIn("display_block", proof)
        self.assertIn("display_floor", proof)
        self.assertIn("java_method_setTileBlocks_83", proof)
        self.assertIn("bulk_blocks", proof)
        self.assertIn("bulk_overlays", proof)
        self.assertIn("java_method_setFloor_86", proof)
        self.assertIn("java_method_setFloor_28", proof)
        self.assertIn("java_method_setAir_30", proof)
        self.assertIn("java_method_isEditorTile_29", proof)
        self.assertIn("java_method_getFloorColor_33", proof)
        self.assertIn("java_method_recacheWall_34", proof)
        self.assertIn("java_method_recache_35", proof)
        self.assertIn("java_method_remove_36", proof)
        self.assertIn("java_method_removeNet_37", proof)
        self.assertIn("java_method_setNet_38", proof)
        self.assertIn("java_method_setNet_39", proof)
        self.assertIn("java_method_setFloorNet_40", proof)
        self.assertIn("java_method_setFloorNet_41", proof)
        self.assertIn("java_method_setOverlayNet_42", proof)
        self.assertIn("single_set_tile_null", proof)
        self.assertIn("java_method_getX_80", proof)
        self.assertIn("java_method_getY_81", proof)
        self.assertIn("java_method_toString_82", proof)

    def test_tile_state_predicates_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.should_save_data", "tile.static_darkness", "tile.leg_solid", "tile.adjacent_to"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1812")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1812"]["status"], "done")
        self.assertIn("return floor.saveData || overlay.saveData || block.saveData;", ledger["slices"]["N1812"]["exact_exprs"])
        self.assertIn("return block.solid && block.fillsTile && !block.synthetic() ? data : 0;", ledger["slices"]["N1812"]["exact_exprs"])
        self.assertIn("return staticDarkness() >= 2 || (floor.solid && block == Blocks.air);", ledger["slices"]["N1812"]["exact_exprs"])
        self.assertIn("return relativeTo(tile) != -1;", ledger["slices"]["N1812"]["exact_exprs"])

    def test_tile_packed_data_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.packed_data", "tile.unpack_packed_data"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1813")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1813"]["status"], "done")
        self.assertIn("return PackedTileData.get(extraData, data, floorData, overlayData);", ledger["slices"]["N1813"]["exact_exprs"])
        self.assertIn("overlayData = PackedTileData.overlayData(packed);", ledger["slices"]["N1813"]["exact_exprs"])

    def test_tile_display_identity_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.get_x", "tile.get_y", "tile.to_string"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1814")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1814"]["status"], "done")
        self.assertIn("return drawx();", ledger["slices"]["N1814"]["exact_exprs"])
        self.assertIn("return drawy();", ledger["slices"]["N1814"]["exact_exprs"])

    def test_tile_change_events_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.fire_changed", "tile.fire_pre_changed"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1815")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_fire_change_state")
        self.assertEqual(ledger["slices"]["N1815"]["status"], "done")
        self.assertIn("if(!world.isGenerating()){", ledger["slices"]["N1815"]["exact_exprs"])
        self.assertIn("Events.fire(tileChange.set(this));", ledger["slices"]["N1815"]["exact_exprs"])
        self.assertIn("Events.fire(preChange.set(this));", ledger["slices"]["N1815"]["exact_exprs"])

    def test_tile_changed_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.changed"]
        self.assertEqual(symbol["source_slice"], "N1816")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_changed_state")
        self.assertEqual(ledger["slices"]["N1816"]["status"], "done")
        self.assertIn("build.updateProximity();", ledger["slices"]["N1816"]["exact_exprs"])
        self.assertIn("fireChanged();", ledger["slices"]["N1816"]["exact_exprs"])
        self.assertIn("if(block.isStatic()){", ledger["slices"]["N1816"]["exact_exprs"])

    def test_tile_pre_changed_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.pre_changed"]
        self.assertEqual(symbol["source_slice"], "N1817")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_pre_changed_state")
        self.assertEqual(ledger["slices"]["N1817"]["status"], "done")
        for expr in ("firePreChanged();", "build.onRemoved();", "build.removeFromProximity();", "if(build.block.isMultiblock()){", "other.build = null;", "other.block = Blocks.air;", "other.fireChanged();"):
            self.assertIn(expr, ledger["slices"]["N1817"]["exact_exprs"])

    def test_tile_change_build_slice_is_emitted_and_source_backed(self):
        source = (ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_changeBuild_73(_args: Array = []) -> Variant:", source)
        self.assertIn("return source_block_geometry.tile_change_build_state(build_present, existing_build_size, old_build_remove_call, edge_buildings, block_has_building, team, rotation, editor_state, block_update, entity_init_result)", source)

    def test_tile_change_build_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.change_build"]
        self.assertEqual(symbol["source_slice"], "N1818")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_change_build_state")
        self.assertEqual(ledger["slices"]["N1818"]["status"], "done")
        for expr in ("build.remove();", "tileSet.clear();", "for(Point2 edge : Edges.getEdges(size)){", "Building other = world.build(x + edge.x, y + edge.y);", "t.updateProximity();", "if(block.hasBuilding()){"):
            self.assertIn(expr, ledger["slices"]["N1818"]["exact_exprs"])

    def test_tile_display_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        self.assertIn("return source_block_geometry.tile_display_state(block_item_drop_present, overlay_item_drop_present, wall_drop_present, block_value, overlay_value, floor_value, display_icon, display_name)", source)
        symbol = registry["symbols"]["tile.display"]
        self.assertEqual(symbol["source_slice"], "N1819")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_display_state")
        self.assertEqual(ledger["slices"]["N1819"]["status"], "done")
        for expr in ("block.itemDrop != null ? block :", "overlay.itemDrop != null || wallDrop() != null ? overlay :", "table.table(t -> {", "t.add(new Image(toDisplay.getDisplayIcon(this))).scaling(Scaling.fit).size(8 * 4);", "t.labelWrap(toDisplay.getDisplayName(this)).left().width(190f).padLeft(5);"):
            self.assertIn(expr, ledger["slices"]["N1819"]["exact_exprs"])

    def test_tile_bulk_mutation_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for operation in ("set_block", "set_floor", "set_overlay"):
            self.assertIn('tile_bulk_mutation_state("%s"' % operation, source)
        for symbol_name in ("tile.set_tile_blocks", "tile.set_tile_floors", "tile.set_tile_overlays"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1820")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_bulk_mutation_state")
        self.assertEqual(ledger["slices"]["N1820"]["status"], "done")

    def test_tile_single_mutation_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        source = (generated / "classes" / "mindustry" / "world" / "Tile.gd").read_text(encoding="utf-8")
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for method_name in ("setFloor", "setOverlay", "removeTile", "setTile"):
            self.assertIn("func java_method_%s_" % method_name, source)
        for symbol_name in ("tile.set_floor", "tile.set_overlay", "tile.remove_tile", "tile.set_tile"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1821")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_single_mutation_state")
        self.assertEqual(ledger["slices"]["N1821"]["status"], "done")

    def test_tile_absolute_relative_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.absolute_relative"]

        self.assertEqual(symbol["source_slice"], "N1797")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_absolute_relative_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1797"]["status"], "done")
        self.assertIn("if(block.size % 2 == 1){", ledger["slices"]["N1797"]["exact_exprs"])

    def test_tile_in_map_area_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.in_map_area"]

        self.assertEqual(symbol["source_slice"], "N1798")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_in_map_area_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1798"]["status"], "done")
        self.assertIn("return !state.rules.limitMapArea || Rect.contains(state.rules.limitX , state.rules.limitY , state.rules.limitWidth, state.rules.limitHeight, x, y);", ledger["slices"]["N1798"]["exact_exprs"])

    def test_tile_is_center_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.is_center"]

        self.assertEqual(symbol["source_slice"], "N1799")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_is_center_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1799"]["status"], "done")
        self.assertIn("return build == null || build.tile == this;", ledger["slices"]["N1799"]["exact_exprs"])

    def test_tile_center_coordinates_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.center_x", "tile.center_y"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1800")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(registry["symbols"]["tile.center_x"]["godot_owner"], "SourceBlockGeometry.tile_center_x_state")
        self.assertEqual(registry["symbols"]["tile.center_y"]["godot_owner"], "SourceBlockGeometry.tile_center_y_state")
        self.assertEqual(ledger["slices"]["N1800"]["status"], "done")
        self.assertIn("return build == null ? x : build.tile.x;", ledger["slices"]["N1800"]["exact_exprs"])
        self.assertIn("return build == null ? y : build.tile.y;", ledger["slices"]["N1800"]["exact_exprs"])

    def test_tile_get_team_id_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.get_team_id"]

        self.assertEqual(symbol["source_slice"], "N1801")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_team_id_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1801"]["status"], "done")
        self.assertIn("return team().id;", ledger["slices"]["N1801"]["exact_exprs"])

    def test_tile_flammability_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.flammability"]

        self.assertEqual(symbol["source_slice"], "N1802")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_flammability_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1802"]["status"], "done")
        self.assertIn("if(floor.liquidDrop != null) return floor.liquidDrop.flammability;", ledger["slices"]["N1802"]["exact_exprs"])
        self.assertIn("return result;", ledger["slices"]["N1802"]["exact_exprs"])

    def test_tile_getter_reference_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.floor", "tile.block", "tile.overlay", "tile.cblock", "tile.team"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1803")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        for symbol_name in ("tile.floor", "tile.block", "tile.overlay", "tile.cblock"):
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_reference_state")
        self.assertEqual(registry["symbols"]["tile.team"]["godot_owner"], "SourceBlockGeometry.tile_team_state")
        self.assertEqual(ledger["slices"]["N1803"]["status"], "done")
        self.assertIn("return floor;", ledger["slices"]["N1803"]["exact_exprs"])
        self.assertIn("return block;", ledger["slices"]["N1803"]["exact_exprs"])
        self.assertIn("return overlay;", ledger["slices"]["N1803"]["exact_exprs"])
        self.assertIn("return build == null ? Team.derelict : build.team;", ledger["slices"]["N1803"]["exact_exprs"])

    def test_tile_is_darkened_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.is_darkened"]
        self.assertEqual(symbol["source_slice"], "N1804")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_is_darkened_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1804"]["status"], "done")
        self.assertIn("return block.isDarkened(this);", ledger["slices"]["N1804"]["exact_exprs"])

    def test_tile_set_team_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        symbol = registry["symbols"]["tile.set_team"]
        self.assertEqual(symbol["source_slice"], "N1805")
        self.assertEqual(symbol["godot_owner"], "SourceBlockGeometry.tile_set_team_state")
        self.assertEqual(symbol["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1805"]["status"], "done")
        self.assertIn("if(build != null){", ledger["slices"]["N1805"]["exact_exprs"])
        self.assertIn("build.team(team);", ledger["slices"]["N1805"]["exact_exprs"])

    def test_tile_id_getters_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.overlay_id", "tile.block_id", "tile.floor_id"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1806")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_id_state")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1806"]["status"], "done")
        for expr in ("return overlay.id;", "return block.id;", "return floor.id;"):
            self.assertIn(expr, ledger["slices"]["N1806"]["exact_exprs"])

    def test_tile_boolean_getters_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.passable", "tile.synthetic", "tile.solid", "tile.breakable", "tile.dangerous"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1807")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_%s_state" % symbol_name.split(".")[1])
        self.assertEqual(ledger["slices"]["N1807"]["status"], "done")
        for expr in ("return !((floor.solid && (block == Blocks.air || block.solidifes)) || (block.solid && (!block.destructible && !block.update)));", "return block.update || block.destructible;", "return block.solid || floor.solid || (build != null && build.checkSolid());", "return block.destructible || block.breakable || block.update;", "return !block.solid && (floor.isDeep() || floor.damages());"):
            self.assertIn(expr, ledger["slices"]["N1807"]["exact_exprs"])

    def test_tile_linked_tiles_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.get_linked_tiles", "tile.get_linked_tiles_as"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1808")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
            self.assertEqual(registry["symbols"][symbol_name]["godot_owner"], "SourceBlockGeometry.tile_get_linked_tiles_state")
        self.assertEqual(ledger["slices"]["N1808"]["status"], "done")
        self.assertIn("Tile other = world.tile(x + dx + o, y + dy + o);", ledger["slices"]["N1808"]["exact_exprs"])
        self.assertIn("if(other != null) cons.get(other);", ledger["slices"]["N1808"]["exact_exprs"])

    def test_tile_rect_geometry_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.get_hitbox", "tile.get_bounds", "tile.hitbox"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1809")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1809"]["status"], "done")
        self.assertIn("return rect.setCentered(drawx(), drawy(), block.size * tilesize, block.size * tilesize);", ledger["slices"]["N1809"]["exact_exprs"])
        self.assertIn("return rect.set(x * tilesize - tilesize/2f, y * tilesize - tilesize/2f, tilesize, tilesize);", ledger["slices"]["N1809"]["exact_exprs"])

    def test_tile_nearby_queries_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.nearby_relative", "tile.nearby_delta", "tile.nearby_rotation", "tile.nearby_build"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1810")
        self.assertEqual(ledger["slices"]["N1810"]["status"], "done")
        self.assertIn("case 0 -> world.tile(x + 1, y);", ledger["slices"]["N1810"]["exact_exprs"])

    def test_tile_interaction_and_drops_slice_is_source_backed_and_registered(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol_name in ("tile.interactable", "tile.drop", "tile.wall_drop"):
            self.assertEqual(registry["symbols"][symbol_name]["source_slice"], "N1811")
            self.assertEqual(registry["symbols"][symbol_name]["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(ledger["slices"]["N1811"]["status"], "done")
        self.assertIn("return state.teams.canInteract(team, team());", ledger["slices"]["N1811"]["exact_exprs"])
        self.assertIn("return overlay == Blocks.air || overlay.itemDrop == null ? floor.itemDrop : overlay.itemDrop;", ledger["slices"]["N1811"]["exact_exprs"])
        self.assertIn("return block.solid ?", ledger["slices"]["N1811"]["exact_exprs"])
        self.assertIn("block.itemDrop != null ? block.itemDrop :", ledger["slices"]["N1811"]["exact_exprs"])
        self.assertIn("overlay.wallOre && !block.synthetic() ? overlay.itemDrop :", ledger["slices"]["N1811"]["exact_exprs"])


if __name__ == "__main__":
    unittest.main()
