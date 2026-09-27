extends CanvasLayer


signal play_pressed

func _on_start_pressed() -> void:
	play_pressed.emit()
	

func _on_quit_pressed() -> void:
	get_tree().quit()
