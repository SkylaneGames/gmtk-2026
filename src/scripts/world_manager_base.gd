extends Node3D

class_name WorldManagerBase

signal level_completed(world: WorldManagerBase);
signal level_failed(world: WorldManagerBase);

@export var world_id: int = 0
@export var player: Player
@export var spawn_point: Node3D
@export var game_over_message: String

var running := false

func initialize_world() -> void:
	print("initializing world %d" % world_id)
	_initialize_world()
	spawn_player()
	running = true

func dispose() -> void:
	# TODO: dispose of world resources, NPCs, items, etc.
	pass

func _initialize_world() -> void:
	pass

func spawn_player() -> void:
	if player == null:
		return

	player.set_position(spawn_point.get_position())

func _notify_level_completed() -> void:
	print("Level %d Completed!" % world_id)
	running = false
	level_completed.emit(self)

func _notify_level_failed() -> void:
	print("Level %d Failed!" % world_id)
	running = false
	level_failed.emit(self)
