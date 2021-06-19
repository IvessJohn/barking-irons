extends CanvasLayer


onready var messageShower = $MessageShower

func show_message(text: String, time_seconds: float = 1):
	# Pause the game
	get_tree().set_deferred("paused", true)
	
	# Show the message
	messageShower.show()
	var label = messageShower.find_node("Label")
	label.text = text
	
	# Start the animation
	# ---
	
	# Return to normal game
	get_tree().set_deferred("paused", false)
	messageShower.hide()
