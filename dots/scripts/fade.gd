extends CanvasLayer

@onready var fade: ColorRect = $Fade
var transitioning := false

func change_room(scene_path: String, spawn_id: String, entry_dir := 0) -> void:
	if transitioning:
		return
	transitioning = true
	
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.control_locked = true
		
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 1.0, 0.25)
	await t.finished
	
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group("player")
	var spawn := get_tree().current_scene.find_child(spawn_id, true, false)
	if player and spawn:
		player.global_position = spawn.global_position
		player.velocity = Vector2.ZERO
		var cam := player.get_node_or_null("Camera2D")
		if cam:
			cam.reset_smoothing()
			
	t = create_tween()
	t.tween_property(fade, "modulate:a", 0.0, 0.25)
	await t.finished
	
	#walk forward to be more smooth
	if player and entry_dir != 0:
		player.velocity.x = entry_dir * 200.0
		await get_tree().create_timer(0.3).timeout
		
	if player:
		player.control_locked = false
	transitioning = false
