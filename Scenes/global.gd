class_name GlobalManager extends Node2D

var player:Player

#static managers
static var viewport_manager_instance:ViewportManager
static var task_manager_intsance:PlayerTaskManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")
	
	viewport_manager_instance = ViewportManager.new([player.clickable_area])
	task_manager_intsance = PlayerTaskManager.new(player)
	
	add_child(viewport_manager_instance)
	add_child(task_manager_intsance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(player.get_current_state()==player.State.WAITING_FOR_NEW_TASK):
		print("creating new task")
		task_manager_intsance.give_random_task_to_player()
		
	pass
