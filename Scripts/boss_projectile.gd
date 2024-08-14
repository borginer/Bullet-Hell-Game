extends CharacterBody2D

@onready var animations = $Animations
@onready var meteor_start_timer = $meteor_start_timer

var spawn_position : Vector2
var starting_dir : Vector2
var starting_speed : float
var type : String

var speed : float

var can_move : bool = false

@export var meteor_top_speed : float = 500
@export var meteor_ramp_time : float = 1.5

var types = [ "side", "meteor" ] 

func _ready():
	animations.play("blue_disk")
	if type == "meteor":
		scale = Vector2(3.8, 3.8)
		meteor_start_timer.start()
	else:
		can_move = true
	position = spawn_position
	speed = starting_speed

	
func _physics_process(delta):
	if not can_move:
		return
	velocity = starting_dir * speed
	if type == "meteor":
		speed += delta * (meteor_top_speed - starting_speed) / meteor_ramp_time
	move_and_slide()

func free():
	queue_free()

func _on_lifetime_timeout():
	queue_free()

func on_being_hit():
	queue_free()


func _on_meteor_start_timer_timeout():
	can_move = true
