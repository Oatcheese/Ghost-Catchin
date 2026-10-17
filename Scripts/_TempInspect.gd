extends SceneTree

func _initialize() -> void:
	var scene = load("res://Scenes/Room2.tscn")
	if scene == null:
		print("FAILED to load scene")
		quit()
		return

	var inst = scene.instantiate()
	var tilemap = inst.get_node_or_null("FloorTiles")
	if tilemap == null:
		print("NO FloorTiles node found")
		quit()
		return

	var ts = tilemap.tile_set
	print("source_count:", ts.get_source_count())
	var bad = 0
	for s in range(ts.get_source_count()):
		var st = ts.get_source_type(s)
		var atlas = ts.get_source(s)
		if atlas is TileSetAtlasSource:
			var tex = atlas.texture
			print(" source", s, "ATLAS tex:", tex.get_name() if tex else "null", "size:", tex.get_size() if tex else "null", "region:", atlas.texture_region_size)
			# enumerate coords this atlas actually provides
			var coords = []
			for x in range(0, 4):
				for y in range(0, 4):
					var d = atlas.get_tile_data(0, Vector2i(x, y))
					if not d.is_empty():
						coords.append(Vector2i(x, y))
			print("   valid atlas coords:", coords)

	print("=== TileMapLayer used cells ===")
	var cells = tilemap.get_used_cells()
	print("used cell count:", cells.size())
	for cell in cells:
		var src = tilemap.get_cell_source_id(cell)
		var ac = tilemap.get_cell_atlas_coord(cell)
		var alt = tilemap.get_cell_alternative_tile(cell)
		var atlas = ts.get_source(src)
		var ok = false
		if atlas is TileSetAtlasSource:
			var d = atlas.get_tile_data(alt, ac)
			ok = not d.is_empty()
		if not ok:
			bad += 1
			print("  INVALID cell", cell, "source:", src, "atlas_coord:", ac, "alt:", alt)
	print("invalid cells:", bad)
	if bad == 0:
		print("ALL cells reference valid tiles. FIX CONFIRMED.")
	quit()
