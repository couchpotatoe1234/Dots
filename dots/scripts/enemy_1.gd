extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRayCheck
@onready var ledge_ray: RayCast2D = $LedgeRayCheck
@export var health: int = 2
var invulnerable = false
var speed: float = 30.0

var direction: int = 1

func _ready():
	sprite.play("walk")
	sprite.flip_h = (direction > 0)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_wall() or (wall_ray.is_colliding() or not ledge_ray.is_colliding()):
		flip_direction()
	
	velocity.x = direction * speed
	
	move_and_slide()

func flip_direction() -> void:
	direction *= -1
	sprite.flip_h = (direction > 0)
	wall_ray.scale.x = -wall_ray.scale.x
	wall_ray.position.x = -wall_ray.position.x
	ledge_ray.scale.x = -ledge_ray.scale.x
	ledge_ray.position.x = -ledge_ray.position.x
	


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		health -= 1
		invulnerable = true
		velocity.y = 200
		velocity.x = -200 * direction
		await get_tree().create_timer(0.1).timeout
