extends Node

@export var player : CharacterBody2D

var active_actions : Dictionary = {}

func _ready():
	for child in get_children():
		if child is Action:
			child.end_action.connect(on_action_end)

func _process(delta):
	for action in active_actions:
		active_actions[action].update()

func _physics_process(delta):
	insert_new_actions()
		
	for action in active_actions:
		active_actions[action].physics_update()
		
	player.physics_update(delta)

func insert_new_actions():
	if Input.is_action_pressed("dash") \
	and not active_actions.has("dash"):
		insert_action("dash", $'Dash')
		
	if Input.get_axis("left", "right"):
		insert_action("move", $'Move')
		
	if Input.is_action_just_pressed("jump"):
		insert_action("jump", $'Jump')
	
	if Input.is_action_pressed("shoot") \
	or Input.is_action_just_pressed("switch_weapon"):
		insert_action("shoot", $'Shoot')
		
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		

func insert_action(acc_type, acc_node):
	active_actions[acc_type] = acc_node
	active_actions[acc_type].start()

func on_action_end(action):
	var acc_node = active_actions[action]
	acc_node.end()
	active_actions.erase(acc_node.acc_name.to_lower())
