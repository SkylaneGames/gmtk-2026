extends CharacterBody3D

class_name Player

@onready var body := $Body;
@onready var ui: UnifiedMenuUI = %UnifiedMenuUI

@export var input_enabled: bool
@export var light_enabled: bool = true :
	get:
		return light.enabled
	set(value):
		light.enabled = value

@export var light: EnergyEffect

@export var SPEED: float = 5.0
@export var ROTATION_SPEED: float = 8.0

@export var memory_count: float = 0.0 # JT Changed to int was := 0.0
										# JS using float for level 2 memory consumption :)

var memories_from_level_1: float = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		velocity.y = JUMP_VELOCITY

	# only do movement logic if input is enabled
	if not input_enabled:
		return
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
	var target_position: Vector3 = body.global_position + direction
	var target_transform: Transform3D = body.global_transform.looking_at(target_position, Vector3.UP)

	body.global_transform.basis = body.global_transform.basis.slerp(target_transform.basis, ROTATION_SPEED * delta)

# JT trying add images on pick up

#func pickup_memory() -> void:
#	memory_count += 1
#	if ui != null:
#		ui.update_memory_label()

func consume_memory(value: float) -> bool:
	if memory_count < value:
		memory_count = 0
	else:
		memory_count -= value

	if ui != null:
		ui.update_memory_label()

	return memory_count > 0
	
func pickup_memory(memory_image: Texture2D) -> void:
	memory_count += 1

	if ui != null:
		ui.update_memory_label()

		if memory_image != null:
			ui.show_memory_image(memory_image)

	# JT End

func reset() -> void:
	reset_memories()

func reset_memories(baseline: float = 0.0) -> void:
	memory_count = baseline
	if ui != null:
		ui.update_memory_label()
		ui.clear_memory_thumbnails()
