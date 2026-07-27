extends Node3D

class_name WorldManagerBase

signal level_completed(world: WorldManagerBase);
signal level_failed(world: WorldManagerBase);

@export var world_id: int = 0
@export var spawn_point: Node3D
@export var game_over_message: String
@export var music_track: MusicController.Track

@onready var game_manager: GameManager = %GameManager
@onready var ui = %UnifiedMenuUI
@onready var music = MusicController

var running := false

# PUBLIC FUNCTIONS - START
# These functions are intended to be called by an external GameManger which will orchestrate the game.

## Set up the world ready for play, but don't start any level-specific logic yet (use _play() for that).
##   i.e. start music, spawn items / objects, reset timers, set any puzzles etc.
func initialize_world() -> void:
	print("initializing world %d" % world_id)
	_initialize_world()

	music.play_track(music_track)

## Start the world's level-specific logic, i.e. start timers, enable enemies AI logic, etc.
func play() -> void:
	_play()
	running = true

func stop() -> void:
	_stop()
	running = false

## Cleanup any world-specific resources
## I.e. despawn enemies, items, etc.
## NOTE: Together with the initialize() and play() functions, these should allow the same level
## instance to be reused for multiple runs without having to reload the level's scene tree.
func dispose() -> void:
	_dispose()
	if running:
		stop()

# PUBLIC FUNCTIONS - END

# PROTECTED FUNCTIONS - START
# These functions are intended to be called / overridden by child classes. They should only be called
# from this class or classes that inherit from it.

## Override this function in any child classes to perform world-specific initialization.
func _initialize_world() -> void:
	pass

## Override this function in any child classes to start any world-specific logic.
##   i.e. start timers, enable enemies AI logic, etc.
func _play() -> void:
	pass

func _stop() -> void:
	pass

## Override to dispose of world resources, NPCs, items, etc.
func _dispose() -> void:
	pass

func _notify_level_completed() -> void:
	print("Level %d Completed!" % world_id)
	level_completed.emit(self)

func _notify_level_failed() -> void:
	print("Level %d Failed!" % world_id)
	level_failed.emit(self)

# PROTECTED FUNCTIONS - END

# PRIVATE FUNCTIONS - START
# These functions are intended to be called only by this class.

# PRIVATE FUNCTIONS - END
