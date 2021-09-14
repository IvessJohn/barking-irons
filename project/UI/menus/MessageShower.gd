extends Control


func show_message(text: String, additional_text: String = "", time_seconds_delay: float = 0.2):
	# Pause the game
	get_tree().set_deferred("paused", true)
	
	# Show the message
	show()
	$MarginContainer/BigText.text = text
	$MarginContainer/AdditionalText.text = additional_text
	
	# Start the animation
	$AnimationPlayer.play("message_popup")
	yield($AnimationPlayer, "animation_finished")
	
	yield(get_tree().create_timer(time_seconds_delay), "timeout")
	
	$AnimationPlayer.play("message_hide")
	yield($AnimationPlayer, "animation_finished")
	
	# Return to normal game
	get_tree().set_deferred("paused", false)
	hide()
