class_name GlobalManager extends Node2D

static var player:Player

#static managers
static var viewport_manager_instance:ViewportManager
static var task_manager_instance:PlayerTaskManager
static var exit_manager_instance:ExitManager

const OFFSCREEN_MARGIN := 40.0

var _is_quitting:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	player = preload("res://Scenes/Player/player.tscn").instantiate()
	player.hide()
	add_child(player)


	viewport_manager_instance = ViewportManager.new([player.clickable_area])
	add_child(viewport_manager_instance)

	task_manager_instance = PlayerTaskManager.new(player)
	add_child(task_manager_instance)

	exit_manager_instance = ExitManager.new()
	add_child(exit_manager_instance)
	exit_manager_instance.exit_requested.connect(_start_exit_sequence)

	var saved_position = SaveData.load_last_position()
	var target_position:Vector2 = saved_position if saved_position != null else viewport_manager_instance.screen_size / 2
	player.body.position = _offscreen_point_below(target_position)

	print("spawning in player")

	player.show()
	player.go_to_target(target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_quitting:
		if player.get_current_state() == player.State.WAITING_FOR_NEW_TASK:
			get_tree().quit()
		return

	if(player.get_current_state()==player.State.WAITING_FOR_NEW_TASK):
		print("creating new task")
		task_manager_instance.give_random_task_to_player()

	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_start_exit_sequence()

func _start_exit_sequence() -> void:
	if _is_quitting:
		return
	_is_quitting = true
	SaveData.save_last_position(player.body.position)
	player.go_to_target(_offscreen_point_below(player.body.position))

func _offscreen_point_below(pos:Vector2) -> Vector2:
	return Vector2(pos.x, viewport_manager_instance.screen_size.y + OFFSCREEN_MARGIN)
