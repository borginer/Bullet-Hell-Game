extends Action
class_name Shoot

@export var player : CharacterBody2D
@export var player_collision_shape : CollisionPolygon2D

@export var shoot_delay : float
@export var auto_shoot_delay : float


@onready var game = get_tree().get_root().get_node("Game")
@onready var bullet = load("res://Scenes/bullet.tscn")

var shoot_timer : Timer

enum WEAPON_TYPE {NORMAL, AUTO}

var cur_weapon_type = WEAPON_TYPE.NORMAL

var can_shoot : bool = true

func start():
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)
	
	acc_name = "shoot"
	type = "shoot"
	prio = 1
	
func physics_update():
	if Input.is_action_just_pressed("switch_weapon"):
		if cur_weapon_type == WEAPON_TYPE.NORMAL:
			cur_weapon_type = WEAPON_TYPE.AUTO
		else: 
			cur_weapon_type = WEAPON_TYPE.NORMAL
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func end():
	can_shoot = true
	
func shoot():
	var player_x_size = player_collision_shape.polygon.size()
	
	var new_bullet = bullet.instantiate()
	new_bullet.spawn_position = player.global_position + Vector2(player_x_size * player.shooting_dir * 2 ,0)
	new_bullet.starting_dir = Vector2(player.shooting_dir, 0)
	
	if cur_weapon_type == WEAPON_TYPE.NORMAL:
		new_bullet.auto_aim = false
		shoot_timer.wait_time = shoot_delay
	elif cur_weapon_type == WEAPON_TYPE.AUTO:
		new_bullet.auto_aim = true
		shoot_timer.wait_time = auto_shoot_delay
		
	game.add_child.call_deferred(new_bullet)

	can_shoot = false
	shoot_timer.start()

func _on_shoot_timer_timeout():
	can_shoot = true
	
