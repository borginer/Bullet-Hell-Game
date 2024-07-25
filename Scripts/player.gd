extends CharacterBody2D

@export var SPEED = 250.0
@export var DASH_SPEED = 480.0

@onready var player_collision_shape = $CollisionShape2D
@onready var dash_cd_timer = $DashCD
@onready var game = get_tree().get_root().get_node("Game")
@onready var bullet = load("res://Scenes/bullet.tscn")

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var release_jump_gravity_multiplier : float

@onready var jump_velocity : float = (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity : float = (-2.0 * jump_height) / pow(jump_time_to_peak, 2)
@onready var fall_gravity : float = (-2.0 * jump_height) / pow(jump_time_to_descent, 2)

var dash_count = 0
var dash_on_cd = false
var dash_frames = 15
# -1, 1
var facing = 1
var dashing = false
var jumping = false
var double_jump_charge = true

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("jump"):
		jump()
		
	if Input.is_action_pressed("jump"):
		jumping = true
	else:
		jumping = false	
		
	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_pressed("dash"):
		dash()

	var direction = Input.get_axis("left", "right")
	
	move_player(direction)
	
	add_gravity(delta)

	move_and_slide()


func _on_dash_cd_timeout():
	dash_on_cd = false
	
func get_gravity():
	if is_on_floor() or dashing:
		return 0
	if velocity.y > 0:
		return fall_gravity
	if not jumping:
		return fall_gravity * release_jump_gravity_multiplier
	return jump_gravity
	
func dash():
	if dash_count == 0 and not dash_on_cd:
		dash_count = dash_frames
		dash_on_cd = true
		dash_cd_timer.start()
		dashing = true
	
func jump():
	if is_on_floor():
		velocity.y = -jump_velocity
		double_jump_charge = true
	elif double_jump_charge:
		velocity.y = -jump_velocity
		double_jump_charge = false
	jumping = true
	
func move_player(direction):
	if dash_count > 0:
		velocity.x = DASH_SPEED * facing
		velocity.y = 0
		dash_count -= 1
	else:
		dashing = false
		if direction:
			var vel_diff = direction * SPEED - velocity.x
			facing = direction
			if sign(direction) == sign(vel_diff):
				velocity.x += 0.3 * vel_diff
			else:
				velocity.x = 0.1 * SPEED
		else: 
			velocity.x = 0
	
func add_gravity(delta):
	velocity.y -= get_gravity() * delta
	
func shoot():
	var player_x_size = player_collision_shape.shape.extents.x
	var new_bullet = bullet.instantiate()
	new_bullet.spawn_position = global_position + Vector2(player_x_size * rotation * 1.5 ,0)
	new_bullet.dir = facing
	game.add_child.call_deferred(new_bullet)
	new_bullet.enable()
