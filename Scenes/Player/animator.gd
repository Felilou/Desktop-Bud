class_name AnimatedPlayerSprite
extends AnimatedSprite2D

enum Animations {WALK, IDLE}

const animation_dict = {
	Animations.WALK: "walk",
	Animations.IDLE: "idle"
}

var space_char = "_"
var force_dir
var force_anim
var _on_timer:bool
var _bubble_visible:bool

@onready var speech_bubble:SpeechBubble = get_parent().get_node("SpeechBubble")

func _calculate_direction_by_direction_to_target(direction_to_target:Vector2) -> Util.Direction:
	if (abs(direction_to_target).x > abs(direction_to_target).y):
		if(direction_to_target.x>0):
			return Util.Direction.EAST
		else:
			return Util.Direction.WEST
	elif(abs(direction_to_target).x < abs(direction_to_target).y):
		if(direction_to_target.y>0):
			return Util.Direction.SOUTH
		else:
			return Util.Direction.NORTH
	
	printerr(error_string(Error.ERR_BUG))
	return Util.Direction.NORTH

func animate_walking(direction_to_target:Vector2) -> void:
	play(animation_dict[Animations.WALK]+space_char+Util.translate_direction_to_char(_calculate_direction_by_direction_to_target(direction_to_target)))

func animate_talking():
	play("idle_s")

func animate_waiting():
	play("idle_s")

func say_something(message:String, seconds:float):
	force_dir = Util.Direction.SOUTH
	force_anim = Animations.IDLE
	var timer = _timer_that_frees_animation_and_direction_on_timeout()
	add_child(timer)
	timer.start(seconds)
	_bubble_visible = true
	speech_bubble.show_message(message)

func wait_x_seconds(seconds:float):
	var timer = _timer_that_frees_animation_and_direction_on_timeout()
	add_child(timer)
	timer.start(seconds)

func _free_animation_and_direction_and_timer(timer: Timer):
	force_dir = null
	force_anim = null
	_on_timer = false
	if _bubble_visible:
		_bubble_visible = false
		speech_bubble.hide_message()
	remove_child(timer)
	timer.queue_free()

func timer_ellapsed():
	return !_on_timer

func cancel_active_timer() -> void:
	for child in get_children():
		if child is Timer:
			_free_animation_and_direction_and_timer(child)

func _timer_that_frees_animation_and_direction_on_timeout() -> Timer:
	var _timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_free_animation_and_direction_and_timer.bind(_timer))
	_on_timer = true
	return _timer
