extends CharacterBody2D

@onready var side_shot_timer = $side_shot_timer
@onready var boss_area = $Area2D
@onready var hit_timer = $hit_timer
@onready var hitbox = $Area2D/Hitbox
@onready var meteor_timer = $meteor_timer
@onready var collision_shape = $CollisionShape
@onready var boss_proj = load("res://Scenes/boss_projectile.tscn")
@onready var game = get_tree().get_root().get_node("Game")

@export var player : CharacterBody2D
@export var SPEED : float
@export var bl_corner : Marker2D
@export var br_corner : Marker2D
@export var tl_corner : Marker2D
@export var tr_corner : Marker2D

signal boss_died

var health : int = 150

var walk : bool = false
var shoot : bool = false
var shooting : bool = false

var saved_position : Vector2

var can_side_shoot : bool = true

var meteor_ready = false

var enabled = true

func _physics_process(delta):
	if Input.is_action_just_pressed("enable_boss"):
		enabled = true
	if Input.is_action_just_pressed("disable_boss"):
		enabled = false
	if not enabled:
		return
	
	var dir = sign(player.position.x - position.x)
	#if walk and not shooting:
		#velocity.x = dir * SPEED
	#else:
		#velocity.x = 0
	##if meteor_ready:
		##meteors()
		##meteor_ready = false
		##meteor_timer.start()
	#if shoot and can_side_shoot: 
		#shoot_sideways()
	move_and_slide()

func _ready():
	modulate = Color(0, 0, 200, 1)
	meteor_timer.start()
	health = 150

func _on_hit_timer_timeout():
	modulate.a = 255
	
func _on_area_2d_body_entered(body):
	modulate.a = 10
	body.on_being_hit()
	hit_timer.start()
	health -= 1
	if health <= 0:
		visible = false
		enabled = false
		hitbox.set_deferred("disabled", true)
		collision_shape.set_deferred("disabled", true)
		boss_died.emit()
		
func set_player_node(player_node):
	player = player_node

func _on_action_timer_timeout():
	walk = false
	shoot = false
	walk = randi() % 3 > 0
	shoot = randi() % 3 > 0
	if shoot:
		walk = false
	
func meteors():
	var x_axis
	var x_size = tr_corner.position.x - tl_corner.position.x
	var meteor_num = 4
	var buffer = 8
	for i in meteor_num:
		x_axis = randf_range(i * (x_size / meteor_num) + buffer, (i + 1) * (x_size / meteor_num) - buffer)
		spawn_meteor(Vector2(0, 1), x_axis - x_size / 2)
	
func shoot_sideways():	
	side_shot_timer.start()
	shooting = true
	can_side_shoot = false
	modulate = Color(0, 200, 200, 1)
	meteors()
	
	await get_tree().create_timer(1.5).timeout
	saved_position = global_position
	
	var level1
	var level2
	var level_size = 38
	var floor_dist = 5
	var bullet_speed
	
	var weights : Array = [ 100, 100, 100 ]
	
	for i in 18:
		if not enabled:
			return
		level1 = utils.weighted_random(weights)
		level2 = utils.weighted_random(weights)
		if level1 == level2:
			level2 = (level1 + 1) % 3
		
		for j in range(weights.size()):
			if j == level1 or j == level2:
				weights[j] -= 12
			else:
				weights[j] += 24
			
		bullet_speed = 310
		spawn_side_shot(Vector2(-1, 0), floor_dist + level1 * level_size, bullet_speed)
		spawn_side_shot(Vector2(1, 0), floor_dist + level1 * level_size, bullet_speed)
		spawn_side_shot(Vector2(-1, 0), floor_dist + level2 * level_size, bullet_speed)
		spawn_side_shot(Vector2(1, 0), floor_dist + level2 * level_size, bullet_speed)
		
		if i == 9:
			meteors()
		await get_tree().create_timer(0.38).timeout
		
	meteors()	
	await get_tree().create_timer(1).timeout
	modulate = Color(0, 0, 200, 1)
	shooting = false
	
func _on_side_shot_timer_timeout():
	can_side_shoot = true

func spawn_side_shot(dir : Vector2, height : float, speed : float):
	var shot = boss_proj.instantiate()
	shot.spawn_position = Vector2(saved_position.x + dir.x * 50, 
								  bl_corner.position.y - height)
	shot.starting_dir = dir
	shot.starting_speed = speed
	game.add_child.call_deferred(shot)
	
func spawn_meteor(dir : Vector2, x_axis : float):
	var meteor = boss_proj.instantiate()
	meteor.spawn_position = Vector2(x_axis , tl_corner.position.y + 20)
	meteor.starting_dir = dir
	meteor.starting_speed = 200
	meteor.type = "meteor"
	game.add_child.call_deferred(meteor)
	

func on_being_hit():
	pass

func _on_meteor_timer_timeout():
	meteor_ready = true
