extends Node

enum State {SITTING, WALKING, TALKING, WAKING_UP, LEAVING, ENTERING, IDLING}

var current_process:Process

var timer:Timer #will be removed later
var player:CharacterBody2D
var animator:AnimatedSprite2D

var rng = RandomNumberGenerator.new() # will be removed later

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	player = get_node("Player")
	animator = get_node("Player/Animation")
	current_process = GoTo.new(player, animator, Vector2(300, 300))
	current_process._start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(current_process._check_end()):
		current_process._end()
		current_process = _determine_next_process()
		current_process._start()

# will be handeled from a more global instance later - processes to.
func _determine_next_process():
	print("setting new process")
	var proc = GoTo.new(player, animator, Vector2(rng.randf_range(0, player.screen_size.x), rng.randf_range(0, player.screen_size.y)))
	print("new process: ", proc)
	return proc

@abstract class Process:
	var player
	var animator
	@abstract func _start()
	@abstract func _check_end()
	@abstract func _end()
	@abstract func _to_string() -> String
	func _init(player_param, animator_param) -> void:
		player = player_param
		animator = animator_param

class GoTo extends Process:
	var target:Vector2
	
	func _start():
		animator._force_direction(-1)
		animator._force_animation(-1)
		player._set_target_pos(target)

	func _check_end():
		return player._has_reached_target()

	func _end():
		pass

	func _init(player_param, animator_param, target_param:Vector2):
		super(player_param, animator_param)
		target = target_param

	func _to_string() -> String:
		return "Go to pos: " + str(target)
