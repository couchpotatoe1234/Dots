extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var main_node = get_tree().root.get_node("Main")
		print("level_change")
		if main_node and main_node.has_method("change_level"):
			main_node.change_level("res://scenes/rooms/Room2.tscn", Vector2(-2415, -65))
