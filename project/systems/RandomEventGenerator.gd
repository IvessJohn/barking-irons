### This node is used for levels to generate random events like a tumbleweed
###  moving through the battlefield, or an animal that runs from a corner of the 
### screen, etc.

extends Node

signal event_happened(event)


enum EVENTS {
	TUMBLEWEED,			# A tumbleweed going across the field with moderate speed
	HORSE_RUNNING,		# An animal running through the field with high speed, pushes players
	REVOLVERS_SPAWNED	# Spawns a bunch of revolvers on the map
}


func generate_event():
	pass
