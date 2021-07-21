### This node is used for levels to generate random events like a tumbleweed
###  moving through the battlefield, or an animal that runs from a corner of the 
### screen, etc.

extends Node

signal event_happened(event)


enum EVENTS {
	TUMBLEWEED,			# A tumbleweed going across the field with moderate speed
	HORSE_RUNNING,		# An animal running through the field with high speed, pushes players
#	REVOLVERS_SPAWNED	# Spawns a bunch of revolvers on the map
	EAGLE_SCREAMING,
	SANDSTRM_WEAK,
	SANDSTRM_STRONG
}
var EVENTS_CHANCES = {
	EVENTS.TUMBLEWEED: 0,
	EVENTS.HORSE_RUNNING: 0,
	EVENTS.EAGLE_SCREAMING: 0,
#	EVENTS.REVOLVERS_SPAWNED: 0,
	EVENTS.SANDSTRM_WEAK: 0,
	EVENTS.SANDSTRM_STRONG: 0
}


onready var tickTimer = $TickTimer
onready var cooldownTimer = $CooldownTimer


func generate_event():
	tickTimer.stop()
	cooldownTimer.start()
	
	pass

func stop_generating_events():
	cooldownTimer.stop()
	tickTimer.stop()

func _on_RandomEventTimer_timeout():
	generate_event()

func _on_CooldownTimer_timeout():
	cooldownTimer.start()


