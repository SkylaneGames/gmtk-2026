extends Node

@export var worlds: Array[WorldManagerBase]
@export var tmp_level_2_scene: PackedScene
@export var current_world_index: int

func _ready() -> void:
	%UnifiedMenuUI.spawn_requested.connect(spawn_player_level1)
	%UnifiedMenuUI.quitgame.connect(quit_game)
	%UnifiedMenuUI.restartgame.connect(restart_game)
	%"Level 1 World".level_failed.connect(game_over)

	worlds[current_world_index].initialize_world()

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


func _on_world_completed(world: WorldManagerBase) -> void:
	if (world.world_id == 1):
		get_tree().change_scene_to_packed(tmp_level_2_scene)

	pass # Replace with function body.


func _on_world_failed(world: WorldManagerBase) -> void:
	world.initialize_world()

func restart_game() -> void:
	get_tree().reload_current_scene()
