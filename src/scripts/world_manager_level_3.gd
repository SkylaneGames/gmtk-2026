extends WorldManagerBase

func _initialize_world() -> void:
	if ui != null:
		ui.memory_popup_state = UnifiedMenuUI.MemoryPopupState.CONSUMING

	player.light_enabled = true

func _on_exit_player_exited() -> void:
	_notify_level_completed()
