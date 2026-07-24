extends CanvasLayer
signal spawn_requested
signal quitgame
var memorycount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_start_pressed() -> void:
	spawn_requested.emit()
	displayUI_level1()
	
func _on_button_quit_pressed() -> void:
	quitgame.emit()
	
func displayUI_level1() -> void:
	%MenuUI.hide()
	%GameUI.show()
	
func displayUI_level2() -> void: # call this on transition to level 2
	%label_MemoryCount.text = "Memories Remaining: 0 "
	
func displayUI_level3() -> void: # call this on transition to level 3
	pass

func incrementMemoryCountLabel() -> void:
	memorycount = memorycount+1
	print("Memories Collected: " + str(memorycount))
	%label_MemoryCount.text = "Memories Collected: " + str(memorycount)
	
func decrementMemoryCountLabel() -> void:
	memorycount = memorycount-1
	print("Memories Remaining: " + str(memorycount))
	%label_MemoryCount.text = "Memories Remaining: " + str(memorycount)
