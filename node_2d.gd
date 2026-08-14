extends Area2D

@export var speed = 400
var screen_size
@export var target = Vector2.ZERO

enum Direction {NORTH, EAST, SOUTH, WEST}

func _ready():
	screen_size = get_viewport_rect().size
	

func _process(delta: float):
	var vel = calculate_velocity_normalized_based_on_target_and_current_pos(target) * speed
	var dir = calc_direction_based_on_velocity(vel)
	play_animation_based_on_dir_and_vel(dir, vel)
	position += vel * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func calc_direction_based_on_velocity(velocity:Vector2):
	if(velocity.x>0):
		return Direction.EAST
	elif(velocity.x<0):
		return Direction.WEST
	elif(velocity.y>0):
		return Direction.NORTH
	elif(velocity.y<0):
		return Direction.SOUTH
	return Direction.EAST
	
func calculate_velocity_normalized_based_on_target_and_current_pos(target:Vector2):
	var velocity = Vector2.ZERO
	var crnt_pos = position
	if crnt_pos.distance_to(target) < 1.0:
		return velocity
	if crnt_pos.x < target.x:
		velocity.x += 1
	if crnt_pos.x > target.x:
		velocity.x -= 1
	if crnt_pos.y < target.y:
		velocity.y += 1
	if crnt_pos.y > target.y:
		velocity.y -= 1
	return velocity.normalized()
	
func play_animation_based_on_dir_and_vel(direction:Direction, velocity:Vector2):
	var animated_sprite = $AnimatedSprite2D
	var anim;
	if(velocity==Vector2.ZERO):
		anim = "idle_"
	else:
		anim="walk_"
	
	match direction:
		Direction.NORTH:
			anim+="n"
		Direction.EAST:
			anim+="e"
		Direction.SOUTH:
			anim+="s"
		Direction.WEST:
			anim+="w"
	
	animated_sprite.play(anim)
