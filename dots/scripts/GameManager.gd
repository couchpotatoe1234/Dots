extends Node

var controls_allowed = true
var last_save_point = Vector2(-675, -400)
var last_level = "res://scenes/levels/Level1.tscn"
var player_x: float = 0
var last_respawn_position: Vector2 = Vector2.ZERO
var hitstop_active: bool = false
var current_hitstop_duration: float = 0.0

func hitstop(duration: float, magnitude: float = 0.0) -> void:
	if hitstop_active and duration < current_hitstop_duration:
		return
	current_hitstop_duration = duration
	hitstop_active = true
	Engine.time_scale = magnitude
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	hitstop_active = false
	current_hitstop_duration = 0.0



#LEVELSSS Starting Position; where you first enter from.
#level 1 = -675, -400
#level 2 = -2375, -65
#level 3 (cross) = -2400, -192
