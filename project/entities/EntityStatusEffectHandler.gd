extends Node

signal on_fire_changed(on_fire)
signal wet_changed(wet)
signal in_wind_changed(in_wind)
signal received_fire_damage()


export(bool) var on_fire: bool = false setget set_on_fire
export(bool) var wet: bool = false setget set_wet
export(bool) var in_wind: bool = false setget set_in_wind

export(bool) var can_be_set_on_fire: bool = true

onready var onFireTimer = $OnFireExtinguishTimer
onready var fireDamageTimer = $FireDamageTimer


### SETTERS AND GETTERS

func set_on_fire(value):
	if value != on_fire:
		on_fire = value
		emit_signal("on_fire_changed", on_fire)
		
func set_wet(value):
	if value != wet:
		wet = value
		emit_signal("wet_changed", wet)
		
func set_in_wind(value):
	if value != in_wind:
		in_wind = value
		emit_signal("in_wind_changed", in_wind)


### FUNCTIONS

func catch_fire(can_extinguish: bool = true):
	self.on_fire = true
	can_be_set_on_fire = true
	
	fireDamageTimer.start()
	if can_extinguish:
		onFireTimer.start()

func extinguish():
	self.on_fire = false
	fireDamageTimer.stop()

func got_wet():
	self.wet = true
	can_be_set_on_fire = false
	extinguish()

func dried():
	self.wet = false
	can_be_set_on_fire = true


### TIMERS

func _on_FireDamageTimer_timeout():
	if !wet and on_fire and can_be_set_on_fire:
		emit_signal("received_fire_damage")
		fireDamageTimer.start()


func _on_OnFireExtinguishTimer_timeout():
	extinguish()
