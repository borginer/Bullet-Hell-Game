extends Action
class_name Move

@export var player : CharacterBody2D
@export var normal_speed : float = 250.0
@export var moon_walk_speed : float = 100

@export var ramp_frames : int
@export var deramp_frames : int
@export var speed_percent_cutoff : float = 0.1

@onready var deramp_mult = pow(speed_percent_cutoff, 1.0 / deramp_frames)
@onready var ramp_mult = 1 - pow(speed_percent_cutoff, 1.0 / (ramp_frames - 1))

var speed : float = normal_speed

func start():
	acc_name = "move"
	type = "horizontal_move"
	prio = 1
	
	var axis = Input.get_axis("left", "right")
	player.move_dir = axis
	player.shooting_dir = axis
	
func physics_update():
	set_directions()
		
	if not player.dashing:
		update_player_velocity(player.move_dir)
		
	if abs(player.velocity.x) > speed:
		player.velocity.x = speed
		
	if player.velocity.x == 0 and player.move_dir == 0:
		end_action.emit("move")

func end():
	pass
	
func update_player_velocity(dir):
	if dir:
		if player.shooting_dir == player.move_dir \
		and speed == moon_walk_speed:
			speed = normal_speed
			player.velocity.x *= (normal_speed / moon_walk_speed)
		elif speed == normal_speed:
			speed = moon_walk_speed
			player.velocity.x *= (moon_walk_speed / normal_speed)
			
		player.move_dir = dir
		
		var vel_diff = dir * speed - player.velocity.x
		
		if abs(vel_diff) < speed * speed_percent_cutoff:
			player.velocity.x = dir * speed
		elif abs(vel_diff) < speed:
			player.velocity.x += ramp_mult * vel_diff
		else: 
			player.velocity.x *= deramp_mult
			if abs(player.velocity.x) < speed_percent_cutoff * speed:
				player.velocity.x = speed_percent_cutoff * speed * dir
	else:
		player.velocity.x *= deramp_mult
		if abs(player.velocity.x) < speed_percent_cutoff * speed:
			player.velocity.x = 0

func set_directions():
	if Input.is_action_just_pressed("left"):
		if player.move_dir == 0:
			player.move_dir = -1
		player.shooting_dir = -1
		
	if Input.is_action_just_pressed("right"):
		if player.move_dir == 0:
			player.move_dir = 1
		player.shooting_dir = 1
		
	if Input.is_action_just_released("left"):
		player.move_dir = 0
		if Input.is_action_pressed("right"):
			player.move_dir = 1
			player.shooting_dir = 1

	if Input.is_action_just_released("right"):
		player.move_dir = 0
		if Input.is_action_pressed("left"):
			player.move_dir = -1
			player.shooting_dir = -1
	
	player.facing_dir = player.shooting_dir
