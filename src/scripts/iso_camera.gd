extends Node3D

class_name IsoCamera

@onready var camera: PhantomCamera3D = $PhantomCamera3D

func set_target(target: Node3D):
	camera.follow_target = target;
	camera.look_at_target = target;