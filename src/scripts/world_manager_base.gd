extends Node3D

class_name WorldManagerBase

signal level_completed;
signal level_failed;

func _initialize_world() -> void:
	pass

func spawn_player() -> void:
	pass #player spawn logic goes here when the 3 levels are all one
