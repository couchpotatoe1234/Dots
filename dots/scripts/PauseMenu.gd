extends CanvasLayer

signal return_to_menu_requested

func _ready() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
		if event.is_action_pressed("pause"):
			if GameManager.can_pause == false:
				return
			toggle_pause()

func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_main_menu_button_pressed() -> void:
	var main_scene = get_tree().root.get_node_or_null("MainGame")
	if main_scene and main_scene.player:
		main_scene.player.velocity = Vector2.ZERO
		main_scene.player.set_physics_process(false)
		main_scene.player.set_process(false)
	get_tree().call_group("pauseable", "set_physics_process", false)
	get_tree().call_group("pauseable", "set_process", false)
	for pauseable in get_tree().get_nodes_in_group("pauseable"):
		if "velocity" in pauseable:
			pauseable.velocity = Vector2.ZERO
		if pauseable.has_node("AnimationPlayer"):
			pauseable.get_node("AnimationPlayer").pause()
		if pauseable.has_node("AnimatedSprite2D"):
			pauseable.get_node("AnimatedSprite2D").pause()
	get_tree().paused = false
	visible = false
	hide()
	return_to_menu_requested.emit()
