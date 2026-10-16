extends Node

const COMPANION_SCENE = preload("res://scenes/healer.tscn")

var healer: Node2D

func _ready() -> void:
	print("loaded in")
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_spawn_heal")
	
func _on_scene_changed(_new_scene: Node) -> void:
	print("scene change")
	call_deferred("_spawn_heal")
	
	
func _spawn_heal() -> void:
	print("spawning companion")
	if is_instance_valid(healer):
		print("companion alr exist")
		return
		
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("player not in group")
		return
	
	healer = COMPANION_SCENE.instantiate()
	add_child(healer)
	healer.global_position = player.global_position
	healer.visible = true
	print("healer position:", healer.global_position)
	print("healer visible:", healer.visible)
	print("companion spawn")
	healer.z_index = 101
	healer.visible = true
