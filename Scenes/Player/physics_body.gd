class_name PhysicsBody extends CharacterBody2D

var hitbox:Hitbox

func _ready():
	hitbox = get_node("Hitbox")
	pass

func _physics_process(_delta: float):
	pass

func _calculate_velocity_to(target:Vector2, speed:float):
	return calculate_direction_to_target(target) * get_process_delta_time() * speed

func calculate_direction_to_target(target:Vector2):
	return position.direction_to(target).normalized()

func has_reached_target(target:Vector2, target_offset:float):
	return _calculate_distance_to_target(target) < target_offset 

func _calculate_distance_to_target(target:Vector2):
	return position.distance_to(target)

func move_towards_target(target:Vector2, speed:float):
	velocity = _calculate_velocity_to(target, speed)
	move_and_slide()
