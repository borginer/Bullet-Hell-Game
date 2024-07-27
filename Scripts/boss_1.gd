extends CharacterBody2D

@onready var boss_area = $Area2D
@onready var hit_timer = $hit_timer
@onready var player : CharacterBody2D

@export var SPEED : float

var walk : bool = false


func _physics_process(delta):
	var dir = sign(player.position.x - position.x)
	if walk:
		velocity.x = dir * SPEED
	else: 
		velocity.x = 0
	move_and_slide()

func _ready():
	modulate = Color(0, 0, 200, 1)

func _on_hit_timer_timeout():
	modulate = Color(0, 0, 200, 1)
	
func _on_area_2d_body_entered(body):
	modulate = Color(200, 0, 0, 1)
	body.free()
	hit_timer.start()

func set_player_node(player_node):
	player = player_node


func _on_action_timer_timeout():
	walk = randi() % 5 > 0
