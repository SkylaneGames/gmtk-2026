@tool
extends Node3D

@export_file("*.svg") var svg_file: String = ""

@export_category("Maze Dimensions")
@export_range(0.001, 1.0, 0.001)
var svg_scale: float = 0.01

@export_range(0.05, 20.0, 0.05)
var wall_height: float = 2.0

@export_range(0.01, 10.0, 0.01)
var wall_thickness: float = 0.25

@export_range(1, 32, 1)
var curve_segments: int = 6

@export_range(0.001, 10.0, 0.001)
var minimum_segment_length: float = 0.05

@export_category("Appearance")
@export var wall_material: Material

@export_category("Generation")
@export var build_button: bool = false:
	set(value):
		build_button = false

		if value:
			build_maze()

@export var clear_button: bool = false:
	set(value):
		clear_button = false

		if value:
			clear_generated_maze()


const GENERATED_ROOT_NAME := "GeneratedMaze"


func build_maze() -> void:
	clear_generated_maze()

	if svg_file.is_empty():
		push_error("Select an SVG file in the Inspector.")
		return

	if not FileAccess.file_exists(svg_file):
		push_error("SVG file not found: %s" % svg_file)
		return

	var path_data_list := extract_svg_path_data(svg_file)

	if path_data_list.is_empty():
		push_error("No SVG <path> elements containing a d attribute were found.")
		return

	var all_subpaths: Array[PackedVector2Array] = []

	for path_data in path_data_list:
		var parsed_subpaths := parse_svg_path(path_data)
		all_subpaths.append_array(parsed_subpaths)

	if all_subpaths.is_empty():
		push_error("No usable maze lines were found in the SVG.")
		return

	var maze_bounds := calculate_bounds(all_subpaths)
	var svg_centre := maze_bounds.get_center()

	var generated_root := Node3D.new()
	generated_root.name = GENERATED_ROOT_NAME

	add_child(generated_root)
	set_editor_owner(generated_root)

	var wall_count := 0

	for subpath in all_subpaths:
		for point_index in range(subpath.size() - 1):
			var start_svg := subpath[point_index]
			var end_svg := subpath[point_index + 1]

			# Centre the SVG around the Godot origin.
			var start_point := (start_svg - svg_centre) * svg_scale
			var end_point := (end_svg - svg_centre) * svg_scale

			if start_point.distance_to(end_point) < minimum_segment_length:
				continue

			create_wall_segment(
				generated_root,
				start_point,
				end_point,
				wall_count
			)

			wall_count += 1

	print(
		"Generated %d maze wall segments from %d SVG path element(s)."
		% [wall_count, path_data_list.size()]
	)


# Reads the SVG as XML instead of searching the entire file with a regex.
# This prevents letters from attributes such as id="path #2" being mistaken
# for SVG drawing commands.
func extract_svg_path_data(file_path: String) -> Array[String]:
	var path_data_list: Array[String] = []
	var parser := XMLParser.new()

	var open_error := parser.open(file_path)

	if open_error != OK:
		push_error(
			"Could not open SVG as XML. Error code: %d"
			% open_error
		)
		return path_data_list

	while parser.read() == OK:
		if parser.get_node_type() != XMLParser.NODE_ELEMENT:
			continue

		var element_name := parser.get_node_name().to_lower()

		# This also tolerates namespace-prefixed names.
		if not element_name.ends_with("path"):
			continue

		for attribute_index in range(parser.get_attribute_count()):
			var attribute_name := parser.get_attribute_name(attribute_index)

			if attribute_name == "d":
				var path_data := parser.get_attribute_value(attribute_index)

				if not path_data.strip_edges().is_empty():
					path_data_list.append(path_data)

	return path_data_list


func parse_svg_path(path_data: String) -> Array[PackedVector2Array]:
	var tokens := tokenize_svg_path(path_data)
	var subpaths: Array[PackedVector2Array] = []

	var current_path := PackedVector2Array()
	var current_position := Vector2.ZERO
	var subpath_start := Vector2.ZERO

	var command := ""
	var token_index := 0

	while token_index < tokens.size():
		var token := tokens[token_index]

		if is_svg_command(token):
			command = token
			token_index += 1

		if command.is_empty():
			push_warning("SVG path contained coordinates before a command.")
			break

		var relative := command == command.to_lower()
		var upper_command := command.to_upper()

		match upper_command:
			"M":
				if not has_numbers(tokens, token_index, 2):
					break

				var destination := read_point(tokens, token_index)
				token_index += 2

				if relative:
					destination += current_position

				if not current_path.is_empty():
					subpaths.append(current_path)
					current_path = PackedVector2Array()

				current_position = destination
				subpath_start = destination
				current_path.append(destination)

				# Coordinate pairs after M implicitly become L commands.
				command = "l" if relative else "L"

			"L":
				if not has_numbers(tokens, token_index, 2):
					break

				var destination := read_point(tokens, token_index)
				token_index += 2

				if relative:
					destination += current_position

				current_position = destination
				append_unique_point(current_path, current_position)

			"H":
				if not has_numbers(tokens, token_index, 1):
					break

				var destination_x := float(tokens[token_index])
				token_index += 1

				if relative:
					destination_x += current_position.x

				current_position.x = destination_x
				append_unique_point(current_path, current_position)

			"V":
				if not has_numbers(tokens, token_index, 1):
					break

				var destination_y := float(tokens[token_index])
				token_index += 1

				if relative:
					destination_y += current_position.y

				current_position.y = destination_y
				append_unique_point(current_path, current_position)

			"C":
				if not has_numbers(tokens, token_index, 6):
					break

				var control_1 := read_point(tokens, token_index)
				var control_2 := read_point(tokens, token_index + 2)
				var destination := read_point(tokens, token_index + 4)
				token_index += 6

				if relative:
					control_1 += current_position
					control_2 += current_position
					destination += current_position

				append_cubic_curve(
					current_path,
					current_position,
					control_1,
					control_2,
					destination
				)

				current_position = destination

			"Z":
				append_unique_point(current_path, subpath_start)
				current_position = subpath_start
				command = ""

			_:
				push_warning(
					"Unsupported SVG command '%s'. "
					+ "This maze importer supports M, L, H, V, C and Z."
					% command
				)
				break

	if not current_path.is_empty():
		subpaths.append(current_path)

	return subpaths


func append_cubic_curve(
	points: PackedVector2Array,
	start: Vector2,
	control_1: Vector2,
	control_2: Vector2,
	end: Vector2
) -> void:
	for step in range(1, curve_segments + 1):
		var t := float(step) / float(curve_segments)
		var point := cubic_bezier(
			start,
			control_1,
			control_2,
			end,
			t
		)

		append_unique_point(points, point)


func cubic_bezier(
	start: Vector2,
	control_1: Vector2,
	control_2: Vector2,
	end: Vector2,
	t: float
) -> Vector2:
	var inverse_t := 1.0 - t

	return (
		inverse_t * inverse_t * inverse_t * start
		+ 3.0 * inverse_t * inverse_t * t * control_1
		+ 3.0 * inverse_t * t * t * control_2
		+ t * t * t * end
	)


func tokenize_svg_path(path_data: String) -> Array[String]:
	var tokens: Array[String] = []
	var regex := RegEx.new()

	var compile_error := regex.compile(
		r"[MmLlHhVvCcZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?"
	)

	if compile_error != OK:
		push_error("Could not compile SVG tokenizer.")
		return tokens

	for result in regex.search_all(path_data):
		tokens.append(result.get_string())

	return tokens


func read_point(tokens: Array[String], index: int) -> Vector2:
	return Vector2(
		float(tokens[index]),
		float(tokens[index + 1])
	)


func has_numbers(
	tokens: Array[String],
	start_index: int,
	number_count: int
) -> bool:
	if start_index + number_count > tokens.size():
		return false

	for index in range(start_index, start_index + number_count):
		if is_svg_command(tokens[index]):
			return false

	return true


func is_svg_command(token: String) -> bool:
	return token.length() == 1 and token in [
		"M", "m",
		"L", "l",
		"H", "h",
		"V", "v",
		"C", "c",
		"Z", "z"
	]


func append_unique_point(
	points: PackedVector2Array,
	point: Vector2
) -> void:
	if points.is_empty() or not points[-1].is_equal_approx(point):
		points.append(point)


func calculate_bounds(
	subpaths: Array[PackedVector2Array]
) -> Rect2:
	var has_point := false
	var minimum := Vector2.ZERO
	var maximum := Vector2.ZERO

	for subpath in subpaths:
		for point in subpath:
			if not has_point:
				minimum = point
				maximum = point
				has_point = true
			else:
				minimum.x = minf(minimum.x, point.x)
				minimum.y = minf(minimum.y, point.y)
				maximum.x = maxf(maximum.x, point.x)
				maximum.y = maxf(maximum.y, point.y)

	return Rect2(minimum, maximum - minimum)


func create_wall_segment(
	parent: Node3D,
	start_point: Vector2,
	end_point: Vector2,
	wall_index: int
) -> void:
	var difference := end_point - start_point
	var segment_length := difference.length()

	if segment_length <= 0.0:
		return

	var midpoint := (start_point + end_point) * 0.5
	var angle := atan2(difference.y, difference.x)

	var body := StaticBody3D.new()
	body.name = "Wall_%04d" % wall_index

	# SVG Y becomes Godot Z.
	body.position = Vector3(
		midpoint.x,
		wall_height * 0.5,
		midpoint.y
	)

	# BoxMesh length runs along local X.
	body.rotation.y = -angle

	parent.add_child(body)
	set_editor_owner(body)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "WallMesh"

	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(
		segment_length + wall_thickness,
		wall_height,
		wall_thickness
	)

	if wall_material != null:
		box_mesh.material = wall_material

	mesh_instance.mesh = box_mesh

	body.add_child(mesh_instance)
	set_editor_owner(mesh_instance)

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "WallCollision"

	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(
		segment_length + wall_thickness,
		wall_height,
		wall_thickness
	)

	collision_shape.shape = box_shape

	body.add_child(collision_shape)
	set_editor_owner(collision_shape)


func clear_generated_maze() -> void:
	var generated_root := get_node_or_null(GENERATED_ROOT_NAME)

	if generated_root == null:
		return

	if Engine.is_editor_hint():
		generated_root.free()
	else:
		generated_root.queue_free()


func set_editor_owner(node: Node) -> void:
	if not Engine.is_editor_hint():
		return

	var scene_root := get_tree().edited_scene_root

	if scene_root != null:
		node.owner = scene_root