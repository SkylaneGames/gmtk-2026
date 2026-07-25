extends Node3D

@export var rotation_speed: float = 2.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0
@export var memory_image: Texture2D # JT

var starting_y: float
var elapsed_time: float = 0.0


func _ready() -> void:
	starting_y = position.y

func _process(delta: float) -> void:
	elapsed_time += delta

	rotate_y(rotation_speed * delta)

	position.y = starting_y + sin(
		elapsed_time * bob_speed
	) * bob_height

func _on_interactable_interaction_started(interactor: Interactor) -> void:
	if interactor.root is not Player:
		return

	var player: Player = interactor.root
	player.pickup_memory(memory_image) # JT player.pickup_memory()
	queue_free()
