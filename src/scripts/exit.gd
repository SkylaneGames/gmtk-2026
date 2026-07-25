extends Node3D

signal player_exited

func _on_interactable_interaction_started(interactor: Interactor) -> void:
	print(interactor.get_parent().name + " is trying to exit.")

	if interactor.root is Player:
		print("Player is has exited.")
		player_exited.emit()
