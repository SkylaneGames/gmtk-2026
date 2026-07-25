extends Node3D

class_name WorldManagerBase

signal level_completed(world: WorldManagerBase);
signal level_failed(world: WorldManagerBase);

@export var world_id: int = 0

func _initialize_world() -> void:
	get_tree().reload_current_scene()
	pass

func spawn_player() -> void:
	pass #player spawn logic goes here when the 3 levels are all one

func _notify_level_completed() -> void:
	print("Level %d Completed!" % world_id)
	level_completed.emit(self)

func _notify_level_failed() -> void:
	print("Level %d Failed!" % world_id)
	level_failed.emit(self)