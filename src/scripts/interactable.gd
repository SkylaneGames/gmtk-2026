extends Area3D

class_name Interactable

signal interaction_started(interactor: Interactor)

func handle_interaction(interactor: Interactor):
	print("handle_interaction(): " + get_parent().name + " was interacted with by " + interactor.name)
	interaction_started.emit(interactor)