extends Node3D

class_name EnergyEffect

@onready var animation: AnimationPlayer = $AnimationPlayer

var _enabled: bool = true

@export var enabled: bool = true :
	get: return _enabled
	set(value):
		_enabled = value

		if value:
			animation.play("flicker")
		else:
			animation.play("turn_off")

