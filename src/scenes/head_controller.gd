extends Node3D

@export var current_state: HeadState = HeadState.PEACEFUL
@export var eyes_open: bool = true
enum HeadState { PEACEFUL, STRAINED_SLIGHT, STRAINED_MEDUIM, STRAINED_HEAVY }
