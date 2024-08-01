extends Action
class_name Jump

@export var player : CharacterBody2D

var jump_velocity : float

var double_jump_charge : bool = true

func start():
	acc_name = "jump"
	type = "jump"
	prio = 1
	
	jump_velocity = player.jump_velocity
	
	jump()
	
	player.jumping = true
	
func physics_update():
	if not Input.is_action_pressed("jump"):
		end_action.emit("jump")

func end():
	player.jumping = false
	
func jump():
	if player.is_on_floor():
		player.velocity.y = -jump_velocity
		double_jump_charge = true
	elif double_jump_charge:
		player.velocity.y = -jump_velocity
		double_jump_charge = false
