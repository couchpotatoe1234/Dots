extends CanvasLayer

signal return_to_menu_requested

func _ready() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
		if event.is_action_pressed("pause"):
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
	get_tree().paused = false
	visible = false
	hide()
	return_to_menu_requested.emit()
