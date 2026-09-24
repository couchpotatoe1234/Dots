extends Node2D

@onready var level_container = $Level
@onready var player = $Player
var current_level_node: Node = null

func _ready() -> void:
	if player:
		player.hide()
		player.process_mode = PROCESS_MODE_DISABLED
	load_main_menu()
	
func load_main_menu() -> void:
	var menu_scene = load("res://scenes/MainMenu.tscn").instantiate()
	level_container.add_child(menu_scene)
	menu_scene.play_pressed.connect(_on_start_game)
	
func _on_start_game() -> void:
	if player:
		player.show()
		player.process_mode = Node.PROCESS_MODE_INHERIT
	change_level(GameManager.last_level, GameManager.last_save_point)

func change_level(level_path: String, spawn_position: Vector2 = Vector2.ZERO) -> void:
	if current_level_node:
		current_level_node.queue_free()
		await current_level_node.tree_exited
	
	for child in level_container.get_children():
		child.queue_free()
	
	var level_resource = load(level_path)
	
	if level_resource:
		current_level_node = level_resource.instantiate()
		level_container.add_child(current_level_node)
		if player and spawn_position != Vector2.ZERO:
			player.global_position = spawn_position
