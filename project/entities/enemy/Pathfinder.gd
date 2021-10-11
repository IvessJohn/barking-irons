extends Node

var update_frame: bool = true

var levelNav: Navigation2D = null
var path: Array = []


func _ready():
	update_frame = randi() % 2 == 0

func navigate():	# Define the next position to go to
	if path.size() > 0:
		get_parent().velocity = get_parent().global_position.direction_to(path[1]) * get_parent().SPEED
		
		# If reached the destination, remove this point from path array
		if get_parent().global_position == path[0]:
			path.pop_front()

func get_path_to_target(target: Node2D):	# It's obvious
	if levelNav and target:
		$Line2D.points = path
		return levelNav.get_simple_path(get_parent().global_position, target.global_position, false)

func generate_path_to_target(target: Node2D):	# It's obvious
	if levelNav and target:
#		if update_frame:
		if true:
			path = levelNav.get_simple_path(get_parent().global_position, target.global_position, false)
	#		line2d.points = path
		update_frame = !update_frame

func set_path_to_target(target: Node2D):
	var new_path = null
	
	new_path = get_path_to_target(target)
	
	if new_path:
		path = new_path

func calculate_path_distance(path_points: Array):
	var dist: float = 0
	
	if path_points.size() > 1:
		for i in path_points.size():
			if i == 0:
				continue
			dist += path_points[i-1].distance_to(path_points[i])
	
	return dist
