extends Label

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "FPS: " + str(Engine.get_frames_per_second())
