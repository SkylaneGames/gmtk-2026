extends Node

func _ready() -> void:
	%UnifiedMenuUI.spawn_requested.connect(spawn_player_level1)
	%UnifiedMenuUI.quitgame.connect(quit_game)

func game_over() -> void:
	print("Game over!")
	get_tree().reload_current_scene()
	
func incrementMemoryCount() -> void:
	#add varying memory related logic here
	%UnifiedMenuUI.incrementMemoryCountLabel()
	
func decrementMemoryCount() -> void:
	#add varying memory related logic here
	%UnifiedMenuUI.decrementMemoryCountLabel()

func spawn_player_level1() -> void:
	pass #player spawn logic goes here when the 3 levels are all one

func quit_game() -> void:
	get_tree().quit()
