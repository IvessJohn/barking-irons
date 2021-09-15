extends Node

var levelNav: Navigation2D = null
var path: Array = []


func navigate():	# Define the next position to go to
	if path.size() > 0:
		get_parent().velocity = get_parent().global_position.direction_to(path[1]) * get_parent().SPEED
		
		# If reached the destination, remove this point from path array
		if get_parent().global_position == path[0]:
			path.pop_front()

func generate_path_to_target(target: Node2D):	# It's obvious
	if levelNav and target:
		path = levelNav.get_simple_path(get_parent().global_position, target.global_position, false)
#		line2d.points = path
