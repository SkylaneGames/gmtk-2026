extends WorldManagerBase

@export var start_time_seconds: float = 60.0
@export var doors: Array[Door]
@export_range(0.0, 100.0, 1.0, "The % of time left in the level which will trigger the door to close.") var door_times: Array[float]
@export var exit: Node3D
@export var nav_check_interval: float = 2.0
@export var memories: Array[MemoryPickup]

var nav_agent: NavigationAgent3D

var time_remaining: float
var time_since_last_nav_update: float = 0.0

func _initialize_world() -> void:
	if ui != null:
		ui.memory_popup_state = UnifiedMenuUI.MemoryPopupState.COLLECTING

	game_manager.get_player().light_enabled = true

	# Create Nav Agent on the Player
	nav_agent = NavigationAgent3D.new()
	game_manager.get_player().add_child(nav_agent)

	time_remaining = start_time_seconds
	nav_agent.target_position = exit.global_position

	for memory in memories:
		memory.reset()		
		ui.clear_memory_thumbnails()

	# reset all doors
	for i in doors.size():
		doors[i].open()

func _play() -> void:
	for i in doors.size():
		doors[i].close_after((100 - door_times[i]) * start_time_seconds / 100)

func _dispose() -> void:
	nav_agent.queue_free()

func _process(delta: float) -> void:
	if !running:
		return

	time_since_last_nav_update += delta

	if (time_since_last_nav_update > nav_check_interval):
		time_since_last_nav_update = 0.0
		check_player_can_complete()

func _on_exit_player_exited() -> void:
	_notify_level_completed()

func check_player_can_complete() -> void:
	if (!nav_agent.is_target_reachable()):
		_notify_level_failed()
