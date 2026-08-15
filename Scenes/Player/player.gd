extends CharacterBody2D

@export var speed:float = 400
@export var target:Vector2 = Vector2.ZERO

var is_clamped_to_screen:bool = false
const target_offset:float = 2
var screen_size:Vector2

func _ready():
	_set_screen_size()
	pass

func _physics_process(delta: float):

	if  ! _has_reached_target():
		velocity = _calculate_velocity_to_target(delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if(clamp):
		position.clamp(Vector2.ZERO, screen_size)

func _calculate_velocity_to_target(delta_time:float):
	return _calculate_direction_to_target() * delta_time * speed
	
func _calculate_direction_to_target():
	return position.direction_to(target).normalized()

func _has_reached_target():
	return _calculate_distance_to_target() < target_offset 
	
func _set_target_pos(new_target:Vector2):
	target = new_target

func _calculate_distance_to_target():
	return position.distance_to(target)

func _set_screen_size():
	screen_size = get_viewport_rect().size
