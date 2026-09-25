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
	get_tree().paused = false
	hide()
	return_to_menu_requested.emit()
