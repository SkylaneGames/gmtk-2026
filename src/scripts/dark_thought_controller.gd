extends CharacterBody3D

signal player_killed

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var ROTATION_SPEED: float = 8.0

@export var target: Node3D
@export var nav_update_interval: float = 2.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var body: Node3D = $Body;

var last_nav_update: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target == null:
		target = %Player

func set_target() -> void:
	if target == null:
		return;

	agent.target_desired_distance = 2.0
	agent.target_position = target.global_position

func _on_interactable_interaction_started(interactor: Interactor) -> void:
	if interactor.root is Player:
		player_killed.emit()

func _physics_process(delta: float) -> void:
#	last_nav_update += delta
#	if last_nav_update > nav_update_interval:
#		last_nav_update = 0.0

	set_target()
	var destination: Vector3 = agent.get_next_path_position()
	destination.y = 0.0
	var direction: Vector3 = (destination - position).normalized()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
