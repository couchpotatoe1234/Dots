extends Node2D

@onready var level_container = $Level
@onready var player = $Player
@onready var pause_menu = $PauseMenu
@onready var transition_layer = $GUI/TransitionLayer
@onready var hud = $GUI/HUD
var current_level_node: Node = null
signal game_started
signal changed_level
signal respawned

func _ready() -> void:
	if hud:
		hud.set_deferred("visible", false)
	if player:
		player.hide()
		player.process_mode = PROCESS_MODE_DISABLED
	if pause_menu:
		pause_menu.return_to_menu_requested.connect(return_to_main_menu)
	load_main_menu()

	
func load_main_menu() -> void:
	GameManager.can_pause = false
	var menu_scene = load("res://scenes/MainMenu.tscn").instantiate()
	level_container.add_child(menu_scene)
	menu_scene.play_pressed.connect(_on_start_game)
	
func _on_start_game() -> void:
	if player:
		player.set_physics_process(true)
		player.change_state("idle")
		game_started.emit()
	change_level(GameManager.last_level, GameManager.last_save_point)
	player.register_companion()

func change_level(level_path: String, spawn_position: Vector2 = Vector2.ZERO, _spawn_velocity: Vector2 = Vector2.ZERO) -> void:
	GameManager.controls_allowed = false
	GameManager.can_pause = false
	if player:
		player.hide()
		player.set_collision_mask_value(2, false)
		player.set_physics_process(false)
	if hud:
		hud.set_deferred("visible", false)
	if transition_layer:
		await transition_layer.fade_out()
	if current_level_node:
		current_level_node.queue_free()
		await current_level_node.tree_exited
	for child in level_container.get_children():
		child.queue_free()
	var level_resource = load(level_path)
	if level_resource:
		current_level_node = level_resource.instantiate()
		level_container.add_child(current_level_node)
		if "camera_limits" in current_level_node and player.has_node("Camera2D"):
			var cam: Camera2D = player.get_node("Camera2D")
			var rect: Rect2 = current_level_node.camera_limits
			cam.limit_left = int(rect.position.x)
			cam.limit_top = int(rect.position.y)
			cam.limit_right = int(rect.position.x + rect.size.x)
			cam.limit_bottom = int(rect.position.y + rect.size.y)
	if player:
		player.set_physics_process(true)
		player.global_position = spawn_position
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player.set_collision_mask_value(2, true)
		changed_level.emit()
		player.show()
		player.velocity = _spawn_velocity
	if hud:
		hud.set_deferred("visible", true)
	if transition_layer:
		transition_layer.fade_in()
		await get_tree().create_timer(0.5).timeout
		GameManager.can_pause = true
		GameManager.controls_allowed = true
	player.register_companion()
			
func return_to_main_menu() -> void:
	GameManager.controls_allowed = false
	GameManager.can_pause = false
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
	if transition_layer:
		await transition_layer.fade_out()
	if player:
		player.hide()
		player.process_mode = Node.PROCESS_MODE_DISABLED
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null
	for child in level_container.get_children():
		child.queue_free()
	load_main_menu()
	if transition_layer:
		await transition_layer.fade_in()

func _on_player_respawn() -> void:
	change_level(GameManager.last_level, GameManager.last_save_point)
	respawned.emit()
