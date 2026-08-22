class_name ViewportManager extends Node2D

var screen_regions:Array[Node2D]
@onready var screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	DisplayServer.window_set_mouse_passthrough(_combined_region_polygon())

# DisplayServer.window_set_mouse_passthrough only accepts a single polygon, but
# each screen region (the clickable area, the speech bubble, ...) is its own
# separate quad that must NOT be merged into one bounding shape - that would
# make the empty space between them (e.g. above the character, below a
# floating speech bubble) intercept clicks too, breaking click-through there.
#
# Instead, chain every region's loop onto a shared hub point with an
# out-and-back "bridge" edge. Each bridge edge is immediately retraced in the
# opposite direction, so it contributes zero area to the filled region and the
# regions stay effectively disjoint within a single polygon path.
func _combined_region_polygon() -> PackedVector2Array:
	var loops: Array[PackedVector2Array] = []
	for region in screen_regions:
		var poly: PackedVector2Array = region.get_polygons_in_screen_transform()
		if not poly.is_empty():
			loops.append(poly)

	if loops.is_empty():
		# An empty array here would disable mouse-passthrough entirely
		# (the whole fullscreen window would start intercepting every
		# click). Use a degenerate zero-area polygon instead so passthrough
		# stays enabled and simply has nothing to capture.
		return PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

	var hub := loops[0][0]
	var combined := PackedVector2Array()
	combined.append_array(loops[0])
	combined.append(hub)

	for i in range(1, loops.size()):
		var loop := loops[i]
		combined.append(loop[0])
		combined.append_array(loop)
		combined.append(loop[0])
		combined.append(hub)

	return combined

func _init(_screen_regions: Array[Node2D]):
	screen_regions = _screen_regions
