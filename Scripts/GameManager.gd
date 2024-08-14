extends Node

var time = 0

@onready var time_label = $"/root/Game/TimeLabel"
@onready var player_health_label = $"/root/Game/PlayerHealth"

@onready var player = $"/root/Game/Player"
@onready var boss1 = $"/root/Game/Boss1"
@onready var boss_health = $"../Control/BossHealth"

func _ready():
	
	
	boss1.set_player_node(player)
	
	boss_health.min_value = 0
	boss_health.max_value = boss1.health
	boss_health.value = boss1.health

	#get_window().size = get_viewport().get_visible_rect().size
	
func _process(delta):
	time += delta
	var ptime = "%.2f" % time

	#time_label.text = "Time: " + ptime
	player_health_label.text = "HP: " + str(player.health)
	boss_health.value = boss1.health
