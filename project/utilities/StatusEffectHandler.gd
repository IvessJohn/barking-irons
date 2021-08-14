extends Node

signal on_fire_changed(on_fire)
signal wet_changed(wet)
signal in_wind_changed(in_wind)
signal received_fire_damage(fire_damage)


export(bool) var on_fire: bool = false setget set_on_fire
export(bool) var wet: bool = false setget set_wet
export(bool) var in_wind: bool = false setget set_in_wind

export(bool) var ignitable: bool = true
export(bool) var extinguishable: bool = true
export(bool) var in_water: bool = false

export(int) var fire_damage: int = 5

onready var extinguishTimer = $OnFireExtinguishTimer
onready var fireDamageTimer = $FireDamageTimer
onready var dryTimer = $DryTimer


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
	ignitable = true
	
	fireDamageTimer.start()
	if extinguishable:
		extinguishTimer.start()

func extinguish():
	self.on_fire = false
	fireDamageTimer.stop()

func got_into_water():
	in_water = true
	got_wet()

func exited_water():
	in_water = false
	start_drying()

func got_wet():
	self.wet = true
	ignitable = false
	extinguish()

func start_drying():
	dryTimer.start()

func dried():
	self.wet = false
	ignitable = true


### TIMERS

func _on_FireDamageTimer_timeout():
	if !wet and on_fire and ignitable:
		emit_signal("received_fire_damage", fire_damage)
		fireDamageTimer.start()


func _on_OnFireExtinguishTimer_timeout():
	if extinguishable:
		extinguish()


func _on_DryTimer_timeout():
	if !in_water:
		dried()
