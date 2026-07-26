extends Node3D

@export var rotation_speed: float = 2.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0

@export var memory_image: Texture2D # JT
@export var memory_music: AudioStream # JT

@onready var body: Node3D = $Body
@onready var emitter: GPUParticles3D = $Body/GPUParticles3D

var memory_sound: AudioStreamPlayer3D #JT

var starting_y: float
var elapsed_time: float = 0.0
var collected: bool = false

func _ready() -> void:
	starting_y = body.position.y

	memory_sound = AudioStreamPlayer3D.new()
	add_child(memory_sound)

func _process(delta: float) -> void:
	elapsed_time += delta

	body.rotate_y(rotation_speed * delta)

	body.position.y = starting_y + sin(elapsed_time * bob_speed) * bob_height

func _on_interactable_interaction_started(
	interactor: Interactor
) -> void:
	if collected:
		return

	if interactor.root is not Player:
		return

	collected = true

	var player: Player = interactor.root
	player.pickup_memory(memory_image)

	emitter.emitting = false

	if memory_music != null:
		memory_sound.stream = memory_music
		memory_sound.play()
		await memory_sound.finished

	await get_tree().create_timer(3).timeout

	queue_free()
