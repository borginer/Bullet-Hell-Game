extends State

@export var idle_time : float

var idle_timer : Timer

func enter():
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_time
	idle_timer.one_shot = true
	idle_timer.timeout.connect(on_idle_timeout)
	add_child(idle_timer)
	idle_timer.start()
	
	print("entered idle")
	
func on_idle_timeout():
	leave_state.emit()
