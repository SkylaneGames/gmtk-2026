extends Node

@export var skip_intro := false
@export var worlds: Array[WorldManagerBase]
@export var current_world_index: int

@export var head: HeadController

@export var camera_menu: PhantomCamera3D

@onready var music = MusicController

func transition_to_menu() -> void:
		current_state = GameState.MENU
		music.play_track(MusicController.Track.MENU)

func skip_intro_pressed() -> void:
	print("skipping intro")
	set_intro_complete()

func set_intro_complete() -> void:
	print("setting game state to menu")
	transition_to_menu()

enum GameState { SPLASH, MENU, GAME } # TODO: Add game over, win, pause, etc. as needed.

var current_state: GameState = GameState.SPLASH

func _ready() -> void:
	%UnifiedMenuUI.start_game.connect(start_game)
	%UnifiedMenuUI.quitgame.connect(quit_game)
	%UnifiedMenuUI.restartgame.connect(restart_game)
	%UnifiedMenuUI.restart_level.connect(restart_level)
	%UnifiedMenuUI.restart_game_skip_intro.connect(restart_game_skip_intro)

	if (skip_intro):
		transition_to_menu()
	else:
		music.play_track(MusicController.Track.SPLASH)

	head.current_state = HeadController.HeadState.STRAINED_HEAVY

	for world in worlds:
		world.level_completed.connect(_on_world_completed)
		world.level_failed.connect(_on_world_failed)

func start_game() -> void:
	%UnifiedMenuUI.displayUI_levelUI(1)
	current_state = GameState.GAME
	camera_menu.priority = 0

	play(current_world_index)

func play(world_index: int) -> void:
	# TODO: Set environment lighting
	if (world_index > 0):
		camera_menu.priority = 2
		await get_tree().create_timer(1.5).timeout

	head.current_layout = world_index + 1 as HeadController.HeadLayout

	if (world_index > 0):
		await get_tree().create_timer(2).timeout
		camera_menu.priority = 0

	worlds[world_index].initialize_world()


func game_over(gameover_reason: String) -> void:
	print("Game over!")
	camera_menu.priority = 2
	head.current_layout = HeadController.HeadLayout.WHOLE
	%UnifiedMenuUI.displayUI_gameover(gameover_reason)

func quit_game() -> void:
	get_tree().quit()

func _on_world_completed(world: WorldManagerBase) -> void:
	head.current_state = 3 - world.world_id as HeadController.HeadState
	if (world.world_id == 3):
		camera_menu.priority = 2
		await get_tree().create_timer(2).timeout
		head.eyes_open = true
		%UnifiedMenuUI.displayUI_gameover("You have successfully escaped the countdown!")

	next_level()

func next_level() -> void:
	current_world_index += 1
	if current_world_index >= worlds.size():
		current_state = GameState.MENU
		return;
	%UnifiedMenuUI.displayUI_levelUI(current_world_index+1)
	play(current_world_index)

func _on_world_failed(world: WorldManagerBase) -> void:
	game_over(world.game_over_message)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.SPLASH:
			skip_intro_pressed()
			return

		get_tree().reload_current_scene()
	
func restart_game() -> void:
	get_tree().reload_current_scene()
	
func restart_game_skip_intro() -> void:
	restart_to_specific_level(0)
	
func restart_level() -> void:
	restart_to_specific_level(current_world_index)
	
func restart_to_specific_level(world_index: int) -> void:
	current_state = GameState.GAME
	head.current_layout = world_index + 1 as HeadController.HeadLayout
	%UnifiedMenuUI.displayUI_levelUI(world_index + 1)
	camera_menu.priority = 0
	current_world_index = world_index
	worlds[current_world_index].initialize_world()
