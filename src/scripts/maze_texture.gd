extends Sprite3D

@export_file("*.svg", "*.png")
var maze_file: String = "res://assets/paths/hedge_02.svg"

func _ready() -> void:
	var maze_texture := load(maze_file) as Texture2D

	if maze_texture == null:
		push_error("Could not load maze: " + maze_file)
		return

	texture = maze_texture
