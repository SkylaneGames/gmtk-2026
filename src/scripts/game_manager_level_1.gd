extends Node

@export var start_time_seconds: float = 60
@export var doors: Array[Door]
@export_range(0, 100, 1, "The % of time left in the level which will trigger the door to close.") var door_times: Array[float]

var time_remaining: float

func _ready() -> void:
	time_remaining = start_time_seconds

func _process(delta: float) -> void:
	time_remaining -= delta

	var time_remaining_percent: float = time_remaining / start_time_seconds * 100
	for i in door_times.size():
		if (time_remaining_percent < door_times[i]):
			doors[i].close()

func _on_exit_player_exited() -> void:
	print("Level Completed!")
