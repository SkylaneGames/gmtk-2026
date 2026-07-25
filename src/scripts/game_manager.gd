extends Node

@export var worlds: Array[WorldManagerBase]
@export var current_world_index: int

@export var head: HeadController

@export var camera_menu: PhantomCamera3D

enum GameState { SPLASH, MENU, GAME } # TODO: Add game over, win, pause, etc. as needed.

var current_state: GameState = GameState.SPLASH

func _ready() -> void:
	%UnifiedMenuUI.start_game.connect(start_game)
	%UnifiedMenuUI.quitgame.connect(quit_game)
	%UnifiedMenuUI.restartgame.connect(restart_game)

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
	head.current_layout = world_index + 1 as HeadController.HeadLayout
	worlds[world_index].initialize_world()

func game_over(gameover_reason: String) -> void:
	print("Game over!")
	camera_menu.priority = 2
	head.current_layout = HeadController.HeadLayout.WHOLE
	%UnifiedMenuUI.displayUI_gameover(gameover_reason)

func quit_game() -> void:
	get_tree().quit()

func _on_world_completed(world: WorldManagerBase) -> void:
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

func restart_game() -> void:
	get_tree().reload_current_scene()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	
