extends CharacterBody2D

@onready var boss_area = $Area2D
@onready var hit_timer = $hit_timer
@onready var player : CharacterBody2D
@onready var hitbox = $Area2D/Hitbox
@onready var collision_shape = $CollisionShape

@export var SPEED : float

var health : int

var walk : bool = false

var enabled = false

func _physics_process(delta):
	if Input.is_action_just_pressed("enable_boss"):
		enabled = true
	if Input.is_action_just_pressed("disable_boss"):
		enabled = false
	if not enabled:
		return
	
	var dir = sign(player.position.x - position.x)
	if walk:
		velocity.x = dir * SPEED
	else: 
		velocity.x = 0
	move_and_slide()

func _ready():
	modulate = Color(0, 0, 200, 1)
	health = 50

func _on_hit_timer_timeout():
	modulate = Color(0, 0, 200, 1)
	
func _on_area_2d_body_entered(body):
	modulate = Color(200, 0, 0, 1)
	body.free()
	hit_timer.start()
	health -= 1
	if health <= 0:
		visible = false
		enabled = false
		hitbox.set_deferred("disabled", true)
		collision_shape.set_deferred("disabled", true)

func set_player_node(player_node):
	player = player_node


func _on_action_timer_timeout():
	walk = randi() % 5 > 0
