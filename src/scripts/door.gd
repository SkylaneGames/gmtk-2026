extends Node3D

class_name Door

@export var warning_threshold: float = 5.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var mesh: MeshInstance3D = $StaticBody3D/MeshInstance3D

var closed: bool = false
var closing: bool = false
var about_to_close: bool = false

var close_delay: float
var delay_remaining: float = 0.0

func _process(delta: float) -> void:
	if !closing:
		return

	if !closed && delay_remaining <= 0.0:
		close()
		return

	delay_remaining -= delta
	if !about_to_close && delay_remaining < warning_threshold:
		print("Door %s about to close" % name)
		animation.play("warning")
		about_to_close = true

func close_after(delay: float = 0.0) -> void:
	if delay == 0.0:
		close()

	print("Door %s closing in %f seconds" % [name, delay])
	closing = true
	close_delay = delay
	delay_remaining = close_delay

func close() -> void:
	if closed:
		return

	print("Door %s closing" % name)
	closed = true;
	animation.play("close")
	$NavigationLink3D.enabled = false

func open() -> void:
	if !closed:
		return

	closing = false
	about_to_close = false
	closed = false;
	animation.play("open")
	$NavigationLink3D.enabled = true