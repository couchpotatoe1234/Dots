extends Node

var controls_allowed = true
var last_save_point = Vector2(-2372, -65)
var last_level = "res://scenes/Level2.tscn"
var player_x: float = 0
var last_respawn_position: Vector2 = Vector2.ZERO

func hitstop(duration: float, magnitude: float = 0.0) -> void:
	Engine.time_scale = magnitude
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0



#LEVELSSS
#level 1 = -675, -400
#level 2 = -2372, -65
