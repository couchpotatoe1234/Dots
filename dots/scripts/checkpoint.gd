extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.last_respawn_position = global_position
		print("Respawn_pos:", GameManager.last_respawn_position )
