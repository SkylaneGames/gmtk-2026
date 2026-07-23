extends Area3D

class_name Interactor

@export var root: Node3D

# TODO: Could store reference to interactable item and only interact on key press.
#		UI could be used to show what item is being interacted with.

func _on_area_entered(area: Area3D) -> void:
	if area is Interactable:
		print("interactor: " + get_parent().name + " has started interaction with " + area.get_parent().name)
		area.handle_interaction(self)
