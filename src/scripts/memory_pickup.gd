extends Area3D

@export var rotation_speed: float = 2.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0

var starting_y: float
var elapsed_time: float = 0.0
@onready var game_manager = (
	get_tree().current_scene.get_node("GameManagerLevel1")
)

func _ready() -> void:
	starting_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	elapsed_time += delta

	rotate_y(rotation_speed * delta)

	position.y = starting_y + sin(
		elapsed_time * bob_speed
	) * bob_height


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	game_manager.incrementMemoryCount()
	queue_free()
