extends Node

const COMPANION_SCENE = preload("res://scenes/healer.tscn")

var healer: CharacterBody2D

func register_player(player: CharacterBody2D) -> void:
	if not is_instance_valid(player):
		print("player invalid")
		return
		
		
	print("register: ", player.name)
	print("pos", player.global_position)
	if not is_instance_valid(healer):
		healer = COMPANION_SCENE.instantiate() as CharacterBody2D
		add_child(healer)
		
	healer.remove_from_group("player")
	healer.set_player(player)
	
	await get_tree().process_frame
	
	if not is_instance_valid(player) or not is_instance_valid(healer):
		return
		
	healer.snap_to_player(player)
	
	healer.visible = true
	healer.z_index = 100
