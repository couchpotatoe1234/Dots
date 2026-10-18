extends Node

const COMPANION_SCENE = preload("res://scenes/healer.tscn")

var healer: Node2D

func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_spawn_heal")
	
func _on_scene_changed(_new_scene: Node) -> void:
	call_deferred("_spawn_heal")
	
	
func _spawn_heal() -> void:
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if player == null:
		print("player not in group")
		return
	
	if not is_instance_valid(healer):
		healer = COMPANION_SCENE.instantiate() as CharacterBody2D
		add_child(healer)
		
	healer.set_player(player)
	
	healer.snap_to_player(player)
	
	healer.visible = true
	healer.z_index = 100
