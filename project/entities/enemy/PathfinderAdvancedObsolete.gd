extends Node

var levelNav: Navigation2D = null
var path: Array = []
var pathfindManager: PathfindManager = null

export(bool) var is_active: bool = true

var check_this_frame: bool = false


func _ready():
	check_this_frame = randi() % 2 == 0
	yield(get_tree(), "idle_frame")
	pathfindManager = get_tree().get_nodes_in_group("PathfindManager")[0]

func request_path():
	if is_active:
		check_this_frame = !check_this_frame
		if check_this_frame:
			if is_instance_valid(pathfindManager):
#				pathfindManager.calculate_path_for_agent(self, levelNav)
				pathfindManager.calculate_path_for_agent(self)
				print("Requesting pathfinding")

func update_path(new_path):
	
	path = new_path
	$Line2D.points = path

func navigate():	# Define the next position to go to
	if path.size() > 0:
		get_parent().velocity = get_parent().global_position.direction_to(path[0]) * get_parent().SPEED
		
		# If reached the destination, remove this point from path array
		if get_parent().global_position == path[0]:
			path.pop_front()


func get_global_position():
	return get_parent().global_position

func get_target_position():
	if is_instance_valid(get_parent().cur_target):
		return get_parent().cur_target.global_position
	else:
		get_parent().global_position
