### This node is used for levels to generate random events like a tumbleweed
###  moving through the battlefield, or an animal that runs from a corner of the 
### screen, etc.

extends Node

signal event_happened(event_num)

export(bool) var is_generating: bool = true setget set_is_generating

export(PackedScene) var EAGLE: PackedScene = preload("res://project/objects/not interactable/Eagle.tscn")
export(PackedScene) var HORSE: PackedScene = preload("res://project/entities/other entities/RunningHorse.tscn")


enum EVENTS {
	TUMBLEWEED,			# A tumbleweed going across the field with moderate speed
	HORSE_RUNNING,		# An animal running through the field with high speed, pushes players
	EAGLE_SCREAMING,
	SANDSTORM_WEAK,
	SANDSTORM_STRONG,
	NOTHING
}
export(Dictionary) var CASUAL_EVENTS_CHANCES: Dictionary = {
	EVENTS.TUMBLEWEED: 5,
	EVENTS.HORSE_RUNNING: 1,
	EVENTS.EAGLE_SCREAMING: 1,
	EVENTS.SANDSTORM_WEAK: 0,
	EVENTS.SANDSTORM_STRONG: 0,
	EVENTS.NOTHING: 20
}


onready var eventTimer = $EventTimer
onready var cooldownTimer = $CooldownTimer


func set_is_generating(value: bool):
	is_generating = value
	if is_generating:
		eventTimer.start()
	else:
		eventTimer.stop()
		cooldownTimer.stop()

func _ready():
	randomize()
#	print(EVENTS.keys()[1])	# Prints out the name of the event from the events enumeration
	cooldownTimer.paused = false
	eventTimer.paused = false
	eventTimer.start()
	
	generate_event(Global.GAME_MODES.CASUAL)


func generate_event(game_mode_number):
	var chances_dictionary: Dictionary = CASUAL_EVENTS_CHANCES
	match (game_mode_number):
		Global.GAME_MODES.ARENA:
			pass
		Global.GAME_MODES.LAN_MULTIPLAYER:
			pass
	
#	var random_picker = RandomPicker.new()
#	var chosen_event = random_picker.pick_random_enum(EVENTS, chances_dictionary)
	var chosen_event = pick_random_event(chances_dictionary)
	print(chosen_event)
	
	emit_signal("event_happened", chosen_event)

func pick_random_event(chances_dictionary: Dictionary):
	if chances_dictionary.size() > 0:
		# 1. Calculate the sum
		var total_sum: int = 0
		for chance in chances_dictionary.values():
			total_sum += chance
		
		# 2. Generate a random number
		var rand_num = randi() % total_sum
		
		# 3. Pick a value
		var offset: int = 0
		var chosen_value
		
		for event in chances_dictionary.keys():
			if chances_dictionary[event] + offset < rand_num:
				chosen_value = event
			else:
				offset += chances_dictionary[event]
		
		# 4. Return the value
		return chosen_value
	else:
		return null

func stop_generating_events():
	self.is_generating = false

func _on_RandomEventTimer_timeout():
	if is_generating:
	#	generate_event(Global.current_game_mode)
		generate_event(Global.GAME_MODES.CASUAL)
		
		cooldownTimer.start()

func _on_CooldownTimer_timeout():
	if is_generating:
		eventTimer.start()


