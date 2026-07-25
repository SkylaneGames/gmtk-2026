extends WorldManagerBase

@export var start_time_seconds: float = 60.0
@export var doors: Array[Door]
@export_range(0.0, 100.0, 1.0, "The % of time left in the level which will trigger the door to close.") var door_times: Array[float]
@export var nav_agent: NavigationAgent3D
@export var exit: Node3D
@export var nav_check_interval: float = 2.0

var time_remaining: float
var time_since_last_nav_update: float = 0.0

func _initialize_world() -> void:
	time_remaining = start_time_seconds
	nav_agent.target_position = exit.global_position

	# reset all doors
	for door in doors:
		door.open()

	# TODO: Respawn memories
	# TODO: Reset player's memories to 0

func _process(delta: float) -> void:
	if !running:
		pass

	time_remaining -= delta
	time_since_last_nav_update += delta

	var time_remaining_percent: float = time_remaining / start_time_seconds * 100
	for i in door_times.size():
		if (time_remaining_percent < door_times[i]):
			doors[i].close()

	if (time_since_last_nav_update > nav_check_interval):
		time_since_last_nav_update = 0.0
		check_player_can_complete()

func _on_exit_player_exited() -> void:
	_notify_level_completed()

func check_player_can_complete() -> void:
	if (!nav_agent.is_target_reachable()):
		_notify_level_failed()
