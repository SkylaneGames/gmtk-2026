extends Node

@export var worlds: Array[WorldManagerBase]
@export var current_world_index: int

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

	play(current_world_index)

func play(world_index: int) -> void:
	# TODO: Set environment lighting
	# TODO: Move camera
	
	worlds[world_index].initialize_world()

func game_over(gameover_reason: String) -> void:
	print("Game over!")
	%UnifiedMenuUI.displayUI_gameover(gameover_reason)

func quit_game() -> void:
	get_tree().quit()

func _on_world_completed(world: WorldManagerBase) -> void:
	next_level()

func next_level() -> void:
	current_world_index += 1
	if current_world_index >= worlds.size():
		# TODO: return to main menu
		current_state = GameState.MENU
		return;
	%UnifiedMenuUI.displayUI_levelUI(current_world_index+1)
	worlds[current_world_index].initialize_world()

func _on_world_failed(world: WorldManagerBase) -> void:
	game_over(world.game_over_message)
	world.initialize_world()

func restart_game() -> void:
	get_tree().reload_current_scene()
