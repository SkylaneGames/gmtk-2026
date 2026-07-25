extends CanvasLayer

class_name UnifiedMenuUI

signal spawn_requested
signal quitgame
signal restartgame

@export var player: Player

@export var memory_display_time: float = 0.5

var memory_popup_tween: Tween

var memory_label: String = "Memories Collected"

# Called when the node enters the scene tree for the first time.

#Functions to send signals to game manager to execute logic
func _on_button_start_pressed() -> void:
	spawn_requested.emit()
	
func _on_button_quit_pressed() -> void:
	quitgame.emit()

func _on_button_back_to_menu_pressed() -> void:
	restartgame.emit()

#Functions to update the UI while running
func displayUI_levelUI(levelindex: int) -> void:
	if levelindex == 1:
		%MenuUI.hide()
		%GameUI.show()
		%label_TutorialThisLevel.text = "Gather your memories, but don't linger too long"
	elif levelindex == 2: 
		%label_MemoryCount.text = "Memories Remaining: 0 "
		%label_TutorialThisLevel.text = "Let your memories keep you safe from dark thoughts"
	elif levelindex == 3:
		%label_TutorialThisLevel.text = "Clear your mind"
	else:
		print("Error: Attempted to display level-specific UI with invalid level index: "+str(levelindex))
	
func displayUI_gameover(gameover_reason: String = "") -> void: # call this on transition to level 3
	%GameUI.hide()
	%GameOverUI.show()
	%label_GameOverReason.text = gameover_reason

func update_memory_label() -> void:
	print("Updating memory label")
	%label_MemoryCount.text = generate_memory_label()

func generate_memory_label() -> String:
	if player == null:
		return "%s: N/A"

	return "%s: %d" % [memory_label, player.memory_count]
	
func show_memory_image(memory_image: Texture2D) -> void:
	if memory_image == null:
		push_warning("No image was provided for this memory.")
		return
		
	add_memory_thumbnail(memory_image) # JT

	# Stop the previous animation if another memory is collected quickly.
	if memory_popup_tween != null:
		memory_popup_tween.kill()

	%MemoryTexture.texture = memory_image
	%MemoryPopup.modulate.a = 0.0
	%MemoryPopup.show()

	memory_popup_tween = create_tween()

	# Fade in.
	memory_popup_tween.tween_property(
		%MemoryPopup,
		"modulate:a",
		1.0,
		0.25
	)

	# Remain visible.
	memory_popup_tween.tween_interval(memory_display_time)

	# Fade out.
	memory_popup_tween.tween_property(
		%MemoryPopup,
		"modulate:a",
		0.0,
		0.4
	)

	memory_popup_tween.tween_callback(%MemoryPopup.hide)
	
	# JT
	
func add_memory_thumbnail(memory_image: Texture2D) -> void:
	if memory_image == null:
		push_warning("Thumbnail image is null.")
		return

	var image := TextureRect.new()

	image.texture = memory_image
	image.custom_minimum_size = Vector2(96, 96)

	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	image.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	image.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	image.modulate = Color.WHITE
	image.visible = true
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	%MemoryList.add_child(image)

	print("Added thumbnail: ", memory_image.resource_path)
