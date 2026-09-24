extends CharacterBody2D


@export var speed: float = 30.0
@export var gravity: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRayCheck
@onready var ledge_ray: RayCast2D = $LedgeRayCheck

var direction: int = 1

func _physics_process(delta: float) -> void:
	print("tick", velocity)
	print("wall: ", wall_ray.is_colliding(), " ledge: ", ledge_ray.is_colliding())
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#Turn around code
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
	
func _ready():
	sprite.play("walk")
	sprite.flip_h = (direction > 0)
