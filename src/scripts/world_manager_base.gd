extends Node3D

class_name WorldManagerBase

signal level_completed(world: WorldManagerBase);
signal level_failed(world: WorldManagerBase);

@export var world_id: int = 0
@export var player: Player
@export var spawn_point: Node3D
@export var game_over_message: String

@onready var ui = %UnifiedMenuUI
@onready var music = MusicController

var running := false

func initialize_world() -> void:
	print("initializing world %d" % world_id)
	music.play_track(world_id_to_track(world_id))
	spawn_player()
	await get_tree().create_timer(5).timeout
	_initialize_world()
	running = true

func dispose() -> void:
	_dispose()

func _dispose() -> void:
	# TODO: dispose of world resources, NPCs, items, etc.
	pass

func _initialize_world() -> void:
	pass

func spawn_player() -> void:
	if player == null:
		return
	player.input_enabled = true
	player.global_transform.origin = spawn_point.global_position

func _notify_level_completed() -> void:
	print("Level %d Completed!" % world_id)
	running = false
	level_completed.emit(self)
	dispose()

func _notify_level_failed() -> void:
	player.input_enabled = false
	print("Level %d Failed!" % world_id)
	running = false
	level_failed.emit(self)
	dispose()

func world_id_to_track(id: int) -> MusicController.Track:
	match id:
		1: return MusicController.Track.LEVEL_1
		2: return MusicController.Track.LEVEL_2
		3: return MusicController.Track.LEVEL_3
		_: return MusicController.Track.LEVEL_1
