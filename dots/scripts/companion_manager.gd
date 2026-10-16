extends Node

const COMPANION_SCENE = preload("res://scenes/healer.tscn")

var healer: Node2D

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_spawn_heal")
	
func _on_scene_changed(_new_scene: Node) -> void:
	call_deferred("_spawn_heal")
	
	
func _spawn_heal() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("player not in group")
		return
	
	if not is_instance_valid(healer):
		healer = COMPANION_SCENE.instantiate()
		add_child(healer)
		
	if healer.has_method("set_player"):
		healer.set_player(player)
		
	var side := -1.0 if player.facing > 0 else 1.0
	healer.global_position = player.global_position + Vector2(28.0 * side, -18.0)
	
	healer.visible = true
	healer.z_index = 100
