extends WorldManagerBase

func _initialize_world() -> void:
	player.light_enabled = true

func _on_exit_player_exited() -> void:
	game_over_message = "You have successfully escaped the countdown!"
	_notify_level_failed()
