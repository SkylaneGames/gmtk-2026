extends CharacterBody3D

signal player_killed

@export var SPEED := 5.0
@export var JUMP_VELOCITY := 4.5
@export var ROTATION_SPEED := 8.0

@export_group("Path Finding")
@export var target: Node3D
@export var check_interval := .5
# The time it takes for the enemy to lose interest in the player after losing a visual.
@export var attention_span := 5.0


@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var body: Node3D = $Body;

var time_since_last_visual: float = attention_span + 1.0
var time_since_last_check: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target == null:
		target = %Player

func set_target(delta: float) -> void:
	if target == null:
		return;

	agent.target_desired_distance = 2.0
	agent.target_position = target.global_position

func is_hunting_target(delta: float) -> bool:
	if target == null:
#		print( "No target!")
		return false;

#	print("Raycasting for player...")

	var start := global_position
	start.y = 1
	var end := target.global_position
	end.y = 1

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self]

	var result: Dictionary = space_state.intersect_ray(query)

#	if result:
#		print(result)
#	else:
#		print("No hits")

	if result && result.collider is Player:
		time_since_last_visual = 0.0
#		print("Can see player!")
		return true

	if time_since_last_visual > attention_span:
#		print( "Lost interest in player!")
		return false

#	print("Lost visual on player!")
	return true

func _on_interactable_interaction_started(interactor: Interactor) -> void:
	if interactor.root is Player:
		player_killed.emit()

var is_hunting: bool = false

func _physics_process(delta: float) -> void:
#	last_nav_update += delta
#	if last_nav_update > nav_update_interval:
#		last_nav_update = 0.0

	if time_since_last_visual < attention_span:
			time_since_last_visual += delta

	time_since_last_check += delta
	if time_since_last_check > check_interval:
		time_since_last_check = 0.0
		is_hunting = is_hunting_target(delta)

	if !is_hunting:
		return

	set_target(delta)
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
