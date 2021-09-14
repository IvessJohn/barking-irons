extends Control

enum MENU_STATES {
	WAITING,	# The "Press any key" screen is shown
	ACTIVE		# Meaning it is launched
}
var cur_menu_state = MENU_STATES.WAITING


func _process(delta):
	if cur_menu_state == MENU_STATES.WAITING:
#		if Input.is_action_just_pressed()
		pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if cur_menu_state == MENU_STATES.WAITING:
			sequence_launch()

func sequence_launch():
	cur_menu_state = MENU_STATES.ACTIVE
