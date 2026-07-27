extends Node

class_name GameManager

@export var skip_intro := false
@export var failure_mode: FailureResetMode
@export var head: HeadController
@export var camera_menu: PhantomCamera3D
@export var worlds: Array[WorldManagerBase]
@export var current_world_index: int
@export var player_template: PackedScene
@export var camera: IsoCamera
@export var ui: UnifiedMenuUI

@onready var music = MusicController

enum FailureResetMode { DEFAULT, REPLAY_GAME, REPLAY_LEVEL }
enum GameState { SPLASH, MENU, GAME } # TODO: Add game over, win, pause, etc. as needed.

var current_state: GameState = GameState.SPLASH

var _player: Player
func get_player() -> Player:
	return _player

func _ready() -> void:
	if (skip_intro):
		transition_to_menu()
	else:
		music.play_track(MusicController.Track.SPLASH)

	head.current_state = HeadController.HeadState.STRAINED_HEAVY

	for world in worlds:
		world.level_completed.connect(_on_world_completed)
		world.level_failed.connect(_on_world_failed)

func transition_to_menu() -> void:
		current_state = GameState.MENU
		music.play_track(MusicController.Track.MENU)

func transition_to_game() -> void:
	current_state = GameState.GAME
	play(current_world_index)

func skip_intro_pressed() -> void:
	print("skipping intro")
	set_intro_complete()

func set_intro_complete() -> void:
	print("setting game state to menu")
	transition_to_menu()

func start_game() -> void:
	_create_player()
	transition_to_game()

func play(world_index: int) -> bool:
	if world_index < 0 || world_index >= worlds.size():
		# invalid world index
		return false

	%UnifiedMenuUI.displayUI_levelUI(world_index + 1)
	var world: WorldManagerBase = worlds[world_index]

	# If we're already focuesed on a level, pan out to the menu camera to see the head animation
	if world_index > 0:
		camera_menu.priority = 2
		await get_tree().create_timer(1.5).timeout

	# Update head layout which will trigger animatations to the next level slice.
	head.current_layout = world_index + 1 as HeadController.HeadLayout

	# If we're panning back out to the menu, allow some time for that to finish
	if world_index > 0:
		await get_tree().create_timer(2.4).timeout

	camera_menu.priority = 0

	# Move player so camera pan
	teleport_player(world.spawn_point)

	# Wait for head animations and camera moves to more or less finish before starting the level
	await get_tree().create_timer(0.5).timeout
	world.initialize_world()
	world.play()
	_player.input_enabled = true

	return true

func teleport_player(level_start: Node3D) -> void:
	_player.global_transform.origin = level_start.global_position

func next_level() -> void:
	current_world_index += 1

	if current_world_index >= worlds.size():
		camera_menu.priority = 2
		await get_tree().create_timer(2).timeout
		head.eyes_open = true
		%UnifiedMenuUI.displayUI_gameover("You have successfully escaped the countdown!")
		current_state = GameState.MENU
		return;

	play(current_world_index)

func game_over(gameover_reason: String) -> void:
	print("Game over!")
	camera_menu.priority = 2
	head.current_layout = HeadController.HeadLayout.WHOLE
	%UnifiedMenuUI.displayUI_gameover(gameover_reason)

func quit_game() -> void:
	get_tree().quit()

var saved_memory_count: float = 0.0
func _on_world_completed(world: WorldManagerBase) -> void:
	# store the number of memories the player had for use when resetting subsequent levels.
	saved_memory_count = _player.memory_count
	handle_world_end(world)

	head.current_state = 3 - world.world_id as HeadController.HeadState

	next_level()

func _on_world_failed(world: WorldManagerBase) -> void:
	handle_world_end(world)
	game_over(world.game_over_message)

func handle_world_end(world: WorldManagerBase):
	_player.input_enabled = false
	world.dispose()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.SPLASH:
			skip_intro_pressed()
			return

		get_tree().reload_current_scene()

func restart(mode_override: FailureResetMode) -> void:
	if mode_override == FailureResetMode.DEFAULT:
		mode_override = failure_mode

	match mode_override:
		FailureResetMode.REPLAY_GAME:
			_restart_game()
		FailureResetMode.REPLAY_LEVEL:
			_restart_level()

func _restart_game() -> void:
	# Re-create the player to re-initialize any default values set on the scene in the editor.
	_player.queue_free()
	current_world_index = 0
	start_game()

func _create_player() -> void:
	_player = player_template.instantiate()
	_player.init(ui)

	# Add player to root of the Game scene (GameManager node should always be placed directly under the scene root)
	get_parent().add_child(_player)

	# Alight with camera
	_player.rotation_degrees.y += 45

	# Link camera to player
	camera.set_target(_player)

func _restart_level() -> void:
	_player.set_memory_count(saved_memory_count)
	play(current_world_index)
