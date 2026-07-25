extends Node3D

var _current_state: HeadState
@export var current_state: HeadState = HeadState.PEACEFUL :
	get: return _current_state
	set(value):
		_current_state = value
		if (value != HeadState.PEACEFUL):
			_eyes_open = false

var _eyes_open: bool
@export var eyes_open: = false :
	get: return _eyes_open
	set(value):
		_eyes_open = value
		if value:
			_current_state = HeadState.PEACEFUL

@export var current_layout: Layout = Layout.WHOLE

enum HeadState { PEACEFUL, STRAINED_SLIGHT, STRAINED_MEDUIM, STRAINED_HEAVY }
enum Layout { WHOLE, LEVEL_1, LEVEL_2, LEVEL_3 }