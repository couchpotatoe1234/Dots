extends Node

@onready var animation_player = $AnimationPlayer

func fade_out() -> void:
	animation_player.play("Fade_to_black")
	await animation_player.animation_finished
	
func fade_in() -> void:
	animation_player.play("Fade_to_clear")
	await animation_player.animation_finished
