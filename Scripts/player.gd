extends CharacterBody2D

@export var SPEED : float = 250.0
@export var DASH_SPEED : float = 450.0
@export var bottom_collision_shape : CollisionShape2D

@onready var dash_cd_timer = $DashCD
@onready var game = get_tree().get_root().get_node("Game")
@onready var bullet = load("res://Scenes/bullet.tscn")
@onready var animations = $Animations

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var release_jump_gravity_multiplier : float
@export var shoot_delay : float
@export var auto_shoot_delay : float

@onready var jump_velocity : float = (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity : float = (-2.0 * jump_height) / pow(jump_time_to_peak, 2)
@onready var fall_gravity : float = (-2.0 * jump_height) / pow(jump_time_to_descent, 2)

@export var dash_frames : int = 10

var dash_count : int = 0
var dash_on_cd : bool = false

# -1, 1
var facing_dir : int = 1
var shooting_dir : int = 1

var dashing : bool = false
var jumping : bool = false
var double_jump_charge : bool = true
var can_shoot : bool = true

var shoot_timer : Timer

enum WEAPON_TYPE {NORMAL, AUTO}

var cur_weapon_type = WEAPON_TYPE.NORMAL

func _ready():
	facing_dir = 0
	
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.wait_time = shoot_delay
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)
	

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		
	if Input.is_action_pressed("shoot"):
		if can_shoot:
			shoot()

	if Input.is_action_pressed("dash"):
		dash()

	if Input.is_action_pressed("jump"):
		jumping = true
	else:
		jumping = false
			
	if Input.is_action_just_pressed("switch_weapon"):
		if cur_weapon_type == WEAPON_TYPE.NORMAL:
			cur_weapon_type = WEAPON_TYPE.AUTO
		else: 
			cur_weapon_type = WEAPON_TYPE.NORMAL
	
	set_directions()
	
	play_animation()
	
	if Input.is_action_just_pressed("jump"):
		jump()
	
	move_player(facing_dir)
	
	add_gravity(delta)

	move_and_slide()

func _on_shoot_timer_timeout():
	can_shoot = true

func _on_dash_cd_timeout():
	dash_on_cd = false

func play_animation():
	if shooting_dir == 1 and facing_dir != 0:
		animations.play("walk_right")
	elif shooting_dir == -1 and facing_dir != 0:
		animations.play("walk_left")
	elif shooting_dir == 1:
		animations.play("idle_right")
	else:
		animations.play("idle_left")
		

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
	
func set_directions():
	if Input.is_action_just_pressed("left"):
		if facing_dir == 0:
			facing_dir = -1
		shooting_dir = -1
		
	if Input.is_action_just_pressed("right"):
		if facing_dir == 0:
			facing_dir = 1
		shooting_dir = 1
		
	if Input.is_action_just_released("left"):
		facing_dir = 0
		if Input.is_action_pressed("right"):
			facing_dir = 1

	if Input.is_action_just_released("right"):
		facing_dir = 0
		if Input.is_action_pressed("left"):
			facing_dir = -1
			
func move_player(direction):
	if dash_count > 0:
		velocity.x = DASH_SPEED * facing_dir
		velocity.y = 0
		dash_count -= 1
	else:
		dashing = false
		if direction:
			var vel_diff = direction * SPEED - velocity.x
			facing_dir = direction
			if sign(direction) == sign(vel_diff):
				velocity.x += 0.3 * vel_diff
			else:
				velocity.x = 0.1 * SPEED
		else: 
			velocity.x = 0
	
func add_gravity(delta):
	velocity.y -= get_gravity() * delta
	
func shoot():
	var player_x_size = bottom_collision_shape.shape.extents.x
	
	var new_bullet = bullet.instantiate()
	new_bullet.spawn_position = global_position + Vector2(player_x_size * shooting_dir * 1.8 ,0)
	new_bullet.starting_dir = Vector2(shooting_dir, 0)
	
	if cur_weapon_type == WEAPON_TYPE.NORMAL:
		new_bullet.auto_aim = false
		shoot_timer.wait_time = shoot_delay
	elif cur_weapon_type == WEAPON_TYPE.AUTO:
		new_bullet.auto_aim = true
		shoot_timer.wait_time = auto_shoot_delay
		
	game.add_child.call_deferred(new_bullet)

	can_shoot = false
	shoot_timer.start()
