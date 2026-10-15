extends Node

const COMPANION_SCENE = preload("res://scenes/healer.tscn")

var companion: Node2D

func ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_spawn_heal")
	print("loaded in")
	
func _on_scene_changed(_new_scene: Node) -> void:
	print("scene change")
	call_deferred("_spawn_heal")
	
	
func _spawn_heal() -> void:
	if is_instance_valid(companion):
		print("companion alr exist")
		return
		
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("player not in group")
		return
	
	companion = COMPANION_SCENE.instantiate()
	get_tree().root.add_child(companion)
	companion.global_position = player.global_position + Vector2(-28, -18)
