extends Node3D

class_name Door

@onready var animation: AnimationPlayer = $AnimationPlayer

var closed: bool = false

func close() -> void:
	if closed:
		return

	closed = true;
	animation.play("close")
