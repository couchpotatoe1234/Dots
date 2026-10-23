extends Node

const COMPANION_SCENE = preload("res://scenes/healer.tscn")

var healer: CharacterBody2D

func register_player(player: CharacterBody2D) -> void:
	if not is_instance_valid(player):
		return
		
	var existing_healers := get_tree().get_nodes_in_group("healer")
	
	if not is_instance_valid(healer):
		for node in existing_healers:
			if is_instance_valid(node) and node is CharacterBody2D:
				healer = node
				break
				
	if not is_instance_valid(healer):
		healer = COMPANION_SCENE.instantiate() as CharacterBody2D
		add_child(healer)
		
		
	healer.remove_from_group("player")
	healer.add_to_group("healer")
	
	for node in get_tree().get_nodes_in_group("healer"):
		if node != healer and is_instance_valid(node):
			node.queue_free()
			
	healer.set_player(player)
	
	await get_tree().process_frame
	
	if not is_instance_valid(player) or not is_instance_valid(healer):
		return
		
	healer.snap_to_player(player)
	
	healer.visible = true
	healer.z_index = 100
