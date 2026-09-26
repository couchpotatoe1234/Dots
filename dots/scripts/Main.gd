extends Node2D

@onready var level_container = $Level
@onready var player = $Player
@onready var pause_menu = $PauseMenu
@onready var transition_layer = $GUI/TransitionLayer
var current_level_node: Node = null

func _ready() -> void:
	if player:
		player.hide()
		player.process_mode = PROCESS_MODE_DISABLED
	if pause_menu:
		pause_menu.return_to_menu_requested.connect(return_to_main_menu)
	load_main_menu()
	
func load_main_menu() -> void:
	var menu_scene = load("res://scenes/MainMenu.tscn").instantiate()
	level_container.add_child(menu_scene)
	menu_scene.play_pressed.connect(_on_start_game)
	
func _on_start_game() -> void:
	if player:
		player.set_physics_process(true)
	change_level(GameManager.last_level, GameManager.last_save_point)
	

func change_level(level_path: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
	GameManager.controls_allowed = false
	if transition_layer:
		await transition_layer.fade_out()
	if player:
		player.hide()
	if current_level_node:
		current_level_node.queue_free()
		await current_level_node.tree_exited
	for child in level_container.get_children():
		child.queue_free()
	var level_resource = load(level_path)
	if level_resource:
		current_level_node = level_resource.instantiate()
		level_container.add_child(current_level_node)
	if player:
		player.global_position = spawn_position
		player.process_mode = Node.PROCESS_MODE_INHERIT
		player.show()
	if transition_layer:
		await transition_layer.fade_in()
		GameManager.controls_allowed = true
			
func return_to_main_menu() -> void:
	GameManager.controls_allowed = false
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
