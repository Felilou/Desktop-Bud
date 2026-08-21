class_name ViewportManager extends Node2D

var clickable_areas:Array[ClickableArea]
@onready var screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for area:ClickableArea in clickable_areas:
		DisplayServer.window_set_mouse_passthrough(area.get_polygons_in_screen_transform())

func _init(_clickable_areas: Array[ClickableArea]):
	clickable_areas = _clickable_areas
