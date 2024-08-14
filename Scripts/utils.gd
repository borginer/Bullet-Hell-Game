extends Node
class_name utils
# returns index of chosen array element
static func weighted_random(weights : Array) -> int:
	var w_sum : float = 0
	
	for i in range(weights.size()):
		w_sum += weights[i]
	
	var rand : float = randf_range(0, w_sum)
	
	var cur_sum : float = 0
	
	for i in range(weights.size()):
		cur_sum += weights[i]
		if cur_sum > rand: 
			return i
		
	assert("no weight selected")
	return -1
