extends Node3D

@export var next_Level: PackedScene

signal player_exited

func _on_interactable_interaction_started(interactor: Interactor) -> void:
	print(interactor.get_parent().name + " is trying to exit.")

	if interactor.root is Player:
		print("Player is has exited.")
		player_exited.emit()
		if next_Level:
			get_tree().change_scene_to_packed(next_Level)
		else:
			print("No 'Next Level' configured for Exit node")
