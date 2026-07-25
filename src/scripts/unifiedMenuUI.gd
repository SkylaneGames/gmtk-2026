extends CanvasLayer
signal spawn_requested
signal quitgame
signal restartgame
var memorycount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	
func incrementMemoryCountLabel() -> void:
	memorycount = memorycount+1
	print("Memories Collected: " + str(memorycount))
	%label_MemoryCount.text = "Memories Collected: " + str(memorycount)
	
func decrementMemoryCountLabel() -> void:
	memorycount = memorycount-1
	print("Memories Remaining: " + str(memorycount))
	%label_MemoryCount.text = "Memories Remaining: " + str(memorycount)
