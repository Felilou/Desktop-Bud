extends Node2D

var player_manager:PlayerManager
var sprite_rect:Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_manager = get_node("Player manager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	DisplayServer.window_set_mouse_passthrough(player_manager.hitbox._get_clickable_area_polygons())
