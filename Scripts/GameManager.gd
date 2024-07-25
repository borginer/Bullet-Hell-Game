extends Node

var time = 0
@onready var label = $"../Label"

func _process(delta):
	time += delta
	var ptime = "%.2f" % time
	label.text = "Time: " + ptime
