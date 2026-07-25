extends WorldManagerBase

@export_range(0, 0.2, 0.01, "Memory consumption per second.") var memory_consumption_rate := 0.04

func _initialize_world() -> void:
	%UnifiedMenuUI.memory_label = "Memories remaining"

func _process(delta: float) -> void:
	if !running:
		return

	if player.light_enabled && !player.consume_memory(memory_consumption_rate * delta):
		player.light_enabled = false

func _on_dark_thought_player_killed() -> void:
#	get_tree().reload_current_scene()
	pass

func _on_exit_player_exited() -> void:
	_notify_level_completed()
