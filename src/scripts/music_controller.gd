extends Node

@export var LevelTracks: Dictionary[Track, AudioStream]
@export var crossfade_duration_seconds: float = 1.0
@export var min_volume_db: float = -80.0

@onready var player_a: AudioStreamPlayer = $AudioStreamPlayerA
@onready var player_b: AudioStreamPlayer = $AudioStreamPlayerB

var primary: AudioStreamPlayer
var secondary: AudioStreamPlayer
var tween: Tween

func _ready() -> void:
	primary = player_a
	secondary = player_b
	primary.volume_db = min_volume_db
	secondary.volume_db = min_volume_db

enum Track { SPLASH, MENU, LEVEL_1, LEVEL_2, LEVEL_3 }

func play_track(track: Track) -> void:
	if tween:
		tween.kill()
	secondary.stream = LevelTracks[track]
	secondary.volume_db = min_volume_db
	secondary.play()

	tween = create_tween()
	tween.tween_property(primary, "volume_db", min_volume_db, crossfade_duration_seconds)
	tween.set_parallel(true)
	tween.tween_property(secondary, "volume_db", 0.0, crossfade_duration_seconds)

	await tween.finished

	primary.stop()
	var tmp := primary
	primary = secondary
	secondary = tmp
