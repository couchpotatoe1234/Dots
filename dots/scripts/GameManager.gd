extends Node

var controls_allowed = true
var last_save_point = Vector2(-675, -400)
var last_level = "res://scenes/rooms/Room1.tscn"
var player_x: float = 0
var last_respawn_position: Vector2 = Vector2.ZERO
var hitstop_active: bool = false
var current_hitstop_duration: float = 0.0
var can_pause = false
var heals = 2

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



#ROOMSS Starting Position; where you first enter from.
#room 1 = -675, -400
#room 2 = -2415, -65
#room 3 = -2543, -161


var block1_broken = false
