extends WorldManagerBase

@export_range(0, 0.2, 0.01, "Memory consumption per second.") var memory_consumption_rate := 0.04
@export var enemy_spawn_positions: Array[Node3D] = []
@export var enemy_template: PackedScene

@onready var ui = %UnifiedMenuUI

var enemies: Array[Node] = []

var nav_map: RID

func _initialize_world() -> void:
	if ui != null:
		ui.memory_label = "Memories remaining"

	for spawn in enemy_spawn_positions:
		var instance: DarkThoughtController = enemy_template.instantiate()
		get_node("/root").add_child(instance)
		instance.global_position = spawn.global_position
		instance.target = player
		instance.player_killed.connect(_on_dark_thought_player_killed)
		enemies.append(instance)

func _dispose() -> void:
	for enemy in enemies:
		enemy.queue_free()

	enemies.clear()

func _process(delta: float) -> void:
	if !running:
		return

	if player.light_enabled && !player.consume_memory(memory_consumption_rate * delta):
		player.light_enabled = false

func _on_dark_thought_player_killed() -> void:
	_notify_level_failed()

func _on_exit_player_exited() -> void:
	_notify_level_completed()
