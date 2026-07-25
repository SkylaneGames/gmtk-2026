extends Node

func _ready() -> void:
	%UnifiedMenuUI.spawn_requested.connect(spawn_player_level1)
	%UnifiedMenuUI.quitgame.connect(quit_game)
	%UnifiedMenuUI.restartgame.connect(restart_game)
	%"Level 1 World".level_failed.connect(game_over)

func game_over(gameover_reason: String = "") -> void:
	print("Game over!")
	%UnifiedMenuUI.displayUI_gameover(gameover_reason)
		
func incrementMemoryCount() -> void:
	#add varying memory related logic here
	%UnifiedMenuUI.incrementMemoryCountLabel()
	
func decrementMemoryCount() -> void:
	#add varying memory related logic here
	%UnifiedMenuUI.decrementMemoryCountLabel()

func spawn_player_level1() -> void:
	%UnifiedMenuUI.displayUI_levelUI(1)
	pass #player spawn logic goes here when the 3 levels are all one

func quit_game() -> void:
	get_tree().quit()

func restart_game() -> void:
	get_tree().reload_current_scene()
