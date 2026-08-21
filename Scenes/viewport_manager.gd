class_name ViewportManager extends Node2D

var screen_regions:Array[Node2D]
@onready var screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var points := PackedVector2Array()
	for region in screen_regions:
		points.append_array(region.get_polygons_in_screen_transform())

	if points.is_empty():
		DisplayServer.window_set_mouse_passthrough(points)
		return

	var bounds := Rect2(points[0], Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)

	DisplayServer.window_set_mouse_passthrough(PackedVector2Array([
		bounds.position,
		Vector2(bounds.end.x, bounds.position.y),
		bounds.end,
		Vector2(bounds.position.x, bounds.end.y),
	]))

func _init(_screen_regions: Array[Node2D]):
	screen_regions = _screen_regions
