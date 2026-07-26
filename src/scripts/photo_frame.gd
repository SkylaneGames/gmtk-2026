extends Control

class_name PhotoFrame

@export var duration: float = 1
@export var fade_in_duration: float = 0.25
@export var fade_out_duration: float = 0.4
@export var safe_zone_size: float = 100

@onready var frame: TextureRect = $ColorRect/TextureRect

var popup_tween: Tween
var original_position: Vector2

func _ready() -> void:
	original_position = position

# Adapted from JT's code in unifiedMenuUI.gd
func show_image(image: Texture2D) -> void:
	frame.texture = image

	if popup_tween != null:
		popup_tween.kill()

	randomise_position()

	modulate.a = 0.0
	show()

	popup_tween = create_tween()

	# Fade in
	popup_tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)

	var remining_time := duration - fade_in_duration - fade_out_duration
	if (remining_time > 0):
		popup_tween.tween_interval(remining_time)

	popup_tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)

	popup_tween.tween_callback(hide)

func randomise_position() -> void:
	var x = randf_range(-safe_zone_size, safe_zone_size)
	var y =randf_range(-safe_zone_size, safe_zone_size)

	position = original_position + Vector2(x, y)
	rotation_degrees = randf_range(-10.0, 10.0)