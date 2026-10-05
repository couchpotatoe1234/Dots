extends Control

@onready var hearts: Array[AnimatedSprite2D] = [$Heart1, $Heart2, $Heart3, $Heart4, $Heart5]

func _ready() -> void:
	var player = get_tree(). get_first_node_in_group("player")
	if player:
		_connect_to_player(player)
	else:
		get_tree().node_added.connect(_on_node_added)
		
@warning_ignore("unused_parameter")
func _on_health_changed(current_health: int, max_health: int) -> void:
	for i in hearts.size():
		var last_frame = hearts[i].sprite_frames.get_frame_count("hit") - 1
		if i < current_health:
			hearts[i].frame = 0
		elif i == current_health:
			hearts[i].play("hit")
		else:
			hearts[i].frame = last_frame
			
func _on_node_added(node: Node) -> void:
	if node.is_in_group("player"):
		_connect_to_player(node)
		get_tree().node_added.disconnect(_on_node_added)
		
func _connect_to_player(player: Node) -> void:
	player.health_changed.connect(_on_health_changed)
	_on_health_changed(player.health, player.max_health)
	
func _money() -> void:
	
