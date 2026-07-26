extends CanvasLayer

class_name UnifiedMenuUI

signal start_game
signal quitgame
signal restartgame

@export var player: Player

@export var memory_display_time: float = 0.5

@onready var photo_frame: PhotoFrame = $GameUI/PhotoFrame

var memory_popup_tween: Tween

enum MemoryPopupState { COLLECTING, CONSUMING }
var memory_popup_state: MemoryPopupState = MemoryPopupState.COLLECTING

# Called when the node enters the scene tree for the first time.

#Functions to send signals to game manager to execute logic
func _on_button_start_pressed() -> void:
	start_game.emit()
	
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
#		%label_MemoryCount.text = "Memories Remaining: 0 "
		%label_TutorialThisLevel.text = "Let your memories keep you safe from dark thoughts"
	elif levelindex == 3:
#		%label_MemoryCount.text = "Memories Held: 0 "
		%label_TutorialThisLevel.text = "Clear your mind"
	else:
		print("Error: Attempted to display level-specific UI with invalid level index: "+str(levelindex))
	
func displayUI_gameover(gameover_reason: String = "") -> void: # call this on transition to level 3
	%GameUI.hide()
	%GameOverUI.show()
	%label_GameOverReason.text = gameover_reason

func update_memory_label() -> void:
	%label_MemoryCount.text = generate_memory_label()

func get_memory_label() -> String:
	match memory_popup_state:
		MemoryPopupState.COLLECTING:
			return "Memories collected: %d"
		MemoryPopupState.CONSUMING:
			return "Memories remaining: %0.2f"
		_:
			return "Memories: %d"

func generate_memory_label() -> String:
	if player == null:
		return "Memories: N/A"

	return get_memory_label() % player.memory_count
	
func show_memory_image(memory_image: Texture2D) -> void:
	if memory_image == null:
		push_warning("No image was provided for this memory.")
		return
		
	add_memory_thumbnail(memory_image) # JT
	photo_frame.show_image(memory_image)

	# JT
	
func add_memory_thumbnail(memory_image: Texture2D) -> void:
	if memory_image == null:
		push_warning("Thumbnail image is null.")
		return

	var image := TextureRect.new()

	image.texture = memory_image

	image.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	image.stretch_mode = TextureRect.STRETCH_SCALE

	image.modulate = Color.WHITE
	image.visible = true
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE

	%MemoryList.add_child(image)

	print("Added thumbnail: ", memory_image.resource_path)
