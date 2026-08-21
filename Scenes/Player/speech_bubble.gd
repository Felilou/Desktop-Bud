class_name SpeechBubble extends Node2D

const PADDING := Vector2(6, 5)
const BORDER := 2.0
const TAIL_HEIGHT := 6.0

@onready var label: Label = $Label

var _content_size := Vector2.ZERO

func _ready() -> void:
	hide()

func show_message(message: String) -> void:
	label.text = message
	label.reset_size()
	_content_size = label.size + PADDING * 2.0
	label.position = -_content_size / 2.0 + PADDING
	show()
	queue_redraw()

func hide_message() -> void:
	hide()

func get_polygons_in_screen_transform() -> PackedVector2Array:
	if not visible or _content_size == Vector2.ZERO:
		return PackedVector2Array()

	var screen_transform = get_viewport().get_screen_transform()
	var half := _content_size / 2.0 + Vector2(BORDER, BORDER)
	var corners := [
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	]

	var res := PackedVector2Array()
	for corner in corners:
		res.append(screen_transform * (corner + global_position))
	return res

func _draw() -> void:
	if _content_size == Vector2.ZERO:
		return

	var rect := Rect2(-_content_size / 2.0, _content_size)
	draw_rect(rect.grow(BORDER), Color.BLACK)
	draw_rect(rect, Color.WHITE)

	var tail_base_y := rect.position.y + rect.size.y
	var outer_tip := Vector2(0, tail_base_y + BORDER + TAIL_HEIGHT)
	var outer_left := Vector2(-TAIL_HEIGHT, tail_base_y + BORDER)
	var outer_right := Vector2(TAIL_HEIGHT, tail_base_y + BORDER)
	draw_colored_polygon(PackedVector2Array([outer_left, outer_right, outer_tip]), Color.BLACK)

	var inner_tip := Vector2(0, tail_base_y + TAIL_HEIGHT - BORDER)
	var inner_left := Vector2(-TAIL_HEIGHT + BORDER, tail_base_y)
	var inner_right := Vector2(TAIL_HEIGHT - BORDER, tail_base_y)
	draw_colored_polygon(PackedVector2Array([inner_left, inner_right, inner_tip]), Color.WHITE)
