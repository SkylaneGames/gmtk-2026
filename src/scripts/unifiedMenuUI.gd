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
