extends Node

var time = 0
@onready var label = $"/root/Game/Label"
@onready var player = $"/root/Game/Player"
@onready var boss1 = $"/root/Game/Boss1"

func _ready():
	boss1.set_player_node(player)

func _process(delta):
	time += delta
	var ptime = "%.2f" % time
	label.text = "Time: " + ptime
