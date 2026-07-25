extends WorldManagerBase

func _initialize_world() -> void:
	player.light_enabled = true

func _on_exit_player_exited() -> void:
	_notify_level_completed()
