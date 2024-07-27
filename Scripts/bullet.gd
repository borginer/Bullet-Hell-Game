extends CharacterBody2D

@export var NORMAL_SPEED = 600
@export var AUTO_AIM_MAX_SPEED = 450
@export var AUTO_AIM_MIN_SPEED = 300

@onready var bullet_collision_shape = $CollisionShape2D
@onready var boss_1 : CharacterBody2D = $/root/Game/Boss1
@onready var animations = $Animations
@onready var blue_fireball = $Sprite2D

var far_weight : float = 7
var close_weight : float = 11

var auto_aim : bool = false
var spawn_position : Vector2
var starting_dir : Vector2

var dir : Vector2

func _on_ready():
	global_position = spawn_position
	dir = starting_dir
	rotation = dir.angle()
	animations.play("empty")
	if auto_aim:
		animations.play("green_star")
	else: 
		blue_fireball.visible = true

func _physics_process(delta):
	bullet_collision_shape.disabled = false
	var speed : float
	if auto_aim:
		var boss_distance : float = (boss_1.position - position).length()
		var boss_dir : Vector2 = (boss_1.position - position).normalized()
		var weight = far_weight * (boss_distance / 700) + close_weight * ((700 - boss_distance) / 700)
		speed = min(AUTO_AIM_MAX_SPEED, (boss_distance / 2) + AUTO_AIM_MIN_SPEED)
		dir = ((dir * weight + boss_dir)).normalized()
	else: 
		speed = NORMAL_SPEED
		dir = starting_dir 
	
	velocity = speed * dir
	
	rotation = dir.angle()
	move_and_slide()

func free():
	queue_free()
	
