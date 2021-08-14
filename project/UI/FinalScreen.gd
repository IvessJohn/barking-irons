extends Control

signal request_new_level


enum FINAL_POSSIBILITY {
	VICTORY,
	DEFEAT
}
var FINAL_DESCRIPTIONS = {
	FINAL_POSSIBILITY.VICTORY: "You Won!",
	FINAL_POSSIBILITY.DEFEAT: "You Lost!"
}


func show_screen(final: int, additional_text: String = ""):
	var main_text = FINAL_DESCRIPTIONS[final]
	
	# Show the message
	show()
	$MarginContainer/BigText.text = main_text
	$MarginContainer/AdditionalText.text = additional_text
	
	# Start the animation
	$AnimationPlayer.play("message_popup")

func _process(_delta):
	if visible and $AnimationPlayer.current_animation != "message_hide":
		if Input.is_action_just_pressed("menu_restartRound"):
			emit_signal("request_new_level")

func hide_screen():
	if $AnimationPlayer.is_playing():
		yield($AnimationPlayer, "animation_finished")
	
	$AnimationPlayer.play("message_hide")
	yield($AnimationPlayer, "animation_finished")
	
	# Return to normal game
	hide()
