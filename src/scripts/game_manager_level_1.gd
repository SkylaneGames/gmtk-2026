extends Node

@export var start_time_seconds: float = 60

var time_remaining: float

func _ready() -> void:
	time_remaining = start_time_seconds

func _process(delta: float) -> void:
	time_remaining -= delta

func _on_exit_player_exited() -> void:
	print("Level Completed!")
