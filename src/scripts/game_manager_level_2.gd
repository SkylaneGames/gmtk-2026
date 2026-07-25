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

func _on_dark_thought_player_killed() -> void:
	get_tree().reload_current_scene()
