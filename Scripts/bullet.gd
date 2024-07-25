extends CharacterBody2D

@export var SPEED = 600
@onready var bullet_collision_shape = $CollisionShape2D

var dir : float
var spawn_position : Vector2
#var spawn_rotation : float

func _on_ready():
	global_position = spawn_position
	
func _physics_process(delta):
	bullet_collision_shape.disabled = false
	velocity = Vector2(SPEED * dir, 0)
	move_and_slide()

func free_bullet():
	queue_free()
	
func enable():
	print("enable")
