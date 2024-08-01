extends Action
class_name Dash

@export var player : CharacterBody2D

@export var dash_speed : float
@export var dash_frames : int
@export var dash_cooldown : float

@onready var dash_delay_timer = $time_between_dashes

var dash_frames_remaining : int = 0
var double_jump_charge : bool = false
var dash_on_cd = false
var dash_dir

func start():
	if dash_on_cd:
		end_action.emit("dash")
		return
	
	acc_name = "dash"
	type = "dash"
	prio = 1
	
	dash_frames_remaining = dash_frames
	dash_dir = player.facing_dir
	
	player.dashing = true
	dash_on_cd = true
	
func physics_update():
	if dash_frames_remaining > 0:
		player.velocity.x = dash_dir * dash_speed
		player.velocity.y = 0
		dash_frames_remaining -= 1
	else:
		end_action.emit("dash")
		player.velocity.x = 0

func end():
	player.dashing = false
	if dash_delay_timer.is_stopped():
		dash_delay_timer.start()

func _on_time_between_dashes_timeout():
	dash_on_cd = false
