extends Node

@export var nav_agent: NavigationAgent3D
@export var exit: Node3D
@export var nav_check_interval := 2.0
@export_range(0, 0.2, 0.01, "Memory consumption per second.") var memory_consumption_rate := 0.04

@onready var player: Player = %Player

var time_since_last_nav_update: float = 0.0

func _ready() -> void:
	nav_agent.target_position = exit.global_position

func _process(delta: float) -> void:
	if !player.consume_memory(memory_consumption_rate * delta):
		player.light_enabled = false

	time_since_last_nav_update += delta

	if (time_since_last_nav_update > nav_check_interval):
		time_since_last_nav_update = 0.0
		check_player_can_complete()

func _on_exit_player_exited() -> void:
	print("Level Completed!")

func check_player_can_complete() -> void:
	if (!nav_agent.is_target_reachable()):
		game_over()
		return

	print("Exit is still reachable.")

func game_over() -> void:
	print("Game over!")
	get_tree().reload_current_scene()

func _on_dark_thought_player_killed() -> void:
	get_tree().reload_current_scene()
