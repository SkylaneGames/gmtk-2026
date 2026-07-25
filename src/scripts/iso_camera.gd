extends Node3D

@onready var camera: PhantomCamera3D = $PhantomCamera3D
@export var target: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.follow_target = target
