extends Node
class_name PathfindManager

var queue = []
var cache = {}

var paths_calculated_per_turn = 1

export(NodePath) var navigation_node_path: NodePath = ""
var navigation: Navigation2D = null


func _ready():
	yield(get_tree(), "idle_frame")
	navigation = get_node(navigation_node_path)

func _physics_process(delta):
	for i in paths_calculated_per_turn:
		dequeue_path_request()

func calculate_path_for_agent(agent, nav: Navigation2D = navigation):
	# Adds the agent to the queue
	var key = str(agent)
	if key in cache:
		return
	cache[key] = ""
	queue.append({
		"agent": agent,
		"nav": nav
	})

func dequeue_path_request():
	if queue.size() == 0:
		return
	
	var calc_path_info = queue.pop_front()
	var agent = calc_path_info.agent
	var nav: Navigation2D = calc_path_info.nav
	if !is_instance_valid(nav):
		return
	
	var start_pos: Vector2 = agent.get_global_position()
	var end_pos: Vector2 = agent.get_target_position()
	
	var new_path = nav.get_simple_path(start_pos, end_pos, false)
	agent.update_path(new_path)
	cache.erase(str(agent))
	print("New path: " + str(new_path))
