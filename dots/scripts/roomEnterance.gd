extends Area2D

@export_file("*.tscn") var target_room: String
@export var target_spawn: String = ""
@export var entry_direction := 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		SceneManager.change_room(targer_room, target_spawn, entry_direction)
