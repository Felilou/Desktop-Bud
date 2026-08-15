extends Node2D

var player_manager:PlayerManager
var sprite_rect:Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_manager = get_node("Player manager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var pos = player_manager.hitbox.global_position
	sprite_rect = player_manager.hitbox.shape.get_rect()

	var screen_transform := get_viewport().get_screen_transform()
	var polygon = PackedVector2Array([
		screen_transform * (pos + sprite_rect.position),
		screen_transform * (pos + Vector2(sprite_rect.end.x, sprite_rect.position.y)),
		screen_transform * (pos + sprite_rect.end),
		screen_transform * (pos + Vector2(sprite_rect.position.x, sprite_rect.end.y)),
	])

	DisplayServer.window_set_mouse_passthrough(polygon)
