extends Node

var time = 0

@onready var time_label = $"/root/Game/TimeLabel"
@onready var player_health_label = $"/root/Game/PlayerHealth"
@onready var boss_health_label = $"/root/Game/BossHealth"

@onready var player = $"/root/Game/Player"
@onready var boss1 = $"/root/Game/Boss1"

func _ready():
	boss1.set_player_node(player)

func _process(delta):
	time += delta
	var ptime = "%.2f" % time
	
	#time_label.text = "Time: " + ptime
	player_health_label.text = "HP: " + str(player.health)
	boss_health_label.text = "Boss HP: " + str(boss1.health)
