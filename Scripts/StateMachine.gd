extends Node

@export var delay_between_states : float
@export var boss : CharacterBody2D

var current_state : State
var states : Dictionary = {}
var skill_weights : Array = [ 100 ]

var sm_enabled : bool = true

func _ready():
	boss.boss_died.connect(on_boss_death)
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.leave_state.connect(on_leave_state)
	current_state = states["idle_0"]
	current_state.enter()

func _process(delta):
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)
	
func on_leave_state():
	if current_state:
		current_state.exit()
		
	await get_tree().create_timer(delay_between_states).timeout
	if sm_enabled:
		choose_new_state()

func choose_new_state():
	current_state = states["skill_1"]
	current_state.enter()

func on_boss_death():
	await current_state.death()
	sm_enabled = false
	current_state.exit()
