extends Node3D

class_name WorldManagerBase

signal level_completed;
signal level_failed(reason: String);

func _initialize_world() -> void:
	pass

func spawn_player() -> void:
	pass #player spawn logic goes here when the 3 levels are all one

func game_over(gameover_reason: String = "") -> void:
	level_failed.emit(gameover_reason)
