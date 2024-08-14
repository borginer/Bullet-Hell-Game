extends CharacterBody2D

@export var NORMAL_SPEED = 600
@export var AUTO_AIM_MAX_SPEED = 450
@export var AUTO_AIM_MIN_SPEED = 300
@export var LIFE_TIME : float = 10

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
		var closest_enemy
		var distance = 1500
		var cur_dist
		
		for enemy in get_tree().get_nodes_in_group("enemies"):
			cur_dist = (enemy.position - position).length()
			if cur_dist < distance:
				distance = cur_dist
				closest_enemy = enemy
				
		var enemy_distance : float = (closest_enemy.position - position).length()
		var enemy_dir : Vector2 = (closest_enemy.position - position).normalized()
		var weight = far_weight * (enemy_distance / 700) + close_weight * ((700 - enemy_distance) / 700)
		
		speed = min(AUTO_AIM_MAX_SPEED, (enemy_distance / 2) + AUTO_AIM_MIN_SPEED)
		dir = ((dir * weight + enemy_dir)).normalized()
	else: 
		speed = NORMAL_SPEED
		dir = starting_dir 
	
	velocity = speed * dir
	
	rotation = dir.angle()
	move_and_slide()

func on_being_hit():
	queue_free()

func _on_lifetime_timeout():
	queue_free()
