extends Node3D

# TODO: When player enters a dark thoughts visual range it should start moving towards the player.

signal player_killed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interactable_interaction_started(interactor: Interactor) -> void:
	if interactor.root is Player:
		player_killed.emit()