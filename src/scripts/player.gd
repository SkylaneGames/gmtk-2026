extends CharacterBody3D

class_name Player

@onready var body: Node3D = $Body;
@export var light_enabled: bool = true :
	get: return $Body/Energy.enabled
	set(value): $Body/Energy.enabled = value

@export var SPEED: float = 5.0
@export var ROTATION_SPEED: float = 8.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	face_direction(direction, delta);

func face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() == 0:
		return

	# Get the body node to face the direction smoothly.
	var target_position := body.global_position + direction
	var target_transform := body.global_transform.looking_at(target_position, Vector3.UP)

	body.global_transform.basis = body.global_transform.basis.slerp(target_transform.basis, ROTATION_SPEED * delta)
