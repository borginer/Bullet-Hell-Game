extends State

@export var boss : CharacterBody2D

@onready var side_shot_timer = $side_shot_timer
@onready var boss_proj = load("res://Scenes/boss_projectile.tscn")
@onready var game = get_tree().get_root().get_node("Game")

var saved_position : Vector2

var can_side_shoot : bool = true
var enabled : bool = true

func enter():
	await shoot_sideways()
	leave_state.emit()

func meteors():
	var x_axis
	var x_size = boss.tr_corner.position.x - boss.tl_corner.position.x
	var meteor_num = 4
	var buffer = 8
	for i in meteor_num:
		x_axis = randf_range(i * (x_size / meteor_num) + buffer, (i + 1) * (x_size / meteor_num) - buffer)
		spawn_meteor(Vector2(0, 1), x_axis - x_size / 2)
	
func shoot_sideways():	
	if not enabled:
		return

	side_shot_timer.start()
	boss.modulate = Color(0, 200, 200, 1)
	meteors()
	
	await get_tree().create_timer(1.5).timeout
	saved_position = boss.global_position
	
	var level1
	var level2
	var level_size = 38
	var floor_dist = 5
	var bullet_speed
	
	var weights : Array = [ 120, 100, 120 ]
	
	for i in 18:
		if not enabled:
			return
		level1 = utils.weighted_random(weights)
		level2 = utils.weighted_random(weights)
		if level1 == level2:
			level2 = (level1 + 1) % 3
		
		for j in range(weights.size()):
			if j == level1 or j == level2:
				weights[j] -= 12
			else:
				weights[j] += 24
			
		bullet_speed = 310
		spawn_side_shot(Vector2(-1, 0), floor_dist + level1 * level_size, bullet_speed)
		spawn_side_shot(Vector2(1, 0), floor_dist + level1 * level_size, bullet_speed)
		spawn_side_shot(Vector2(-1, 0), floor_dist + level2 * level_size, bullet_speed)
		spawn_side_shot(Vector2(1, 0), floor_dist + level2 * level_size, bullet_speed)
		
		if i == 9:
			meteors()
		await get_tree().create_timer(0.38).timeout
		
	meteors()	
	await get_tree().create_timer(1).timeout
	boss.modulate = Color(0, 0, 200, 1)
	
func _on_side_shot_timer_timeout():
	can_side_shoot = true

func spawn_side_shot(dir : Vector2, height : float, speed : float):
	var shot = boss_proj.instantiate()
	shot.spawn_position = Vector2(saved_position.x + dir.x * 50, 
								  boss.bl_corner.position.y - height)
	shot.starting_dir = dir
	shot.starting_speed = speed
	game.add_child.call_deferred(shot)
	
func spawn_meteor(dir : Vector2, x_axis : float):
	var meteor = boss_proj.instantiate()
	meteor.spawn_position = Vector2(x_axis , boss.tl_corner.position.y + 20)
	meteor.starting_dir = dir
	meteor.starting_speed = 200
	meteor.type = "meteor"
	game.add_child.call_deferred(meteor)
	
func death():
	enabled = false
