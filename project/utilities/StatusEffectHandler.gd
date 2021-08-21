extends Node

signal on_fire_changed(on_fire)
signal wet_changed(wet)
signal in_wind_changed(in_wind)
signal received_fire_damage(fire_damage)
signal is_ready_to_burn


export(bool) var on_fire: bool = false setget set_on_fire
export(bool) var wet: bool = false setget set_wet
export(bool) var in_wind: bool = false setget set_in_wind

export(bool) var can_burn: bool = true			# Constant, defines the ability to burn at all 
												 # (don't confuse with the can_catch_fire)
export(bool) var can_catch_fire: bool = true	# Variable, defines if the object can catch fire right now
export(bool) var extinguishable: bool = true
export(bool) var in_water: bool = false

#export(float, 0.0, 1.0) var heat_determiner: float = 0.0 setget set_heat_determiner	# Must be filled to be burning

export(int) var fire_damage: int = 5

onready var extinguishTimer = $OnFireExtinguishTimer
onready var fireDamageTimer = $FireDamageTimer
onready var dryTimer = $DryTimer
onready var catchingFireTimer = $CatchingFireTimer	# Gives some time to leave fire instead of immediately catching it
#onready var heatTween = $HeatTween	# Currently obsolete


### SETTERS AND GETTERS

#func set_heat_determiner(value):
#	if heat_determiner != value:
#		heat_determiner = clamp(value, 0.0, 1.0)
#		if heat_determiner == 1.0:
#			catch_fire()

func set_on_fire(value):
	if value != on_fire:
		on_fire = (value and can_burn)
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

func collided_with_fire():
	if catchingFireTimer.is_stopped():
		dried()
		catchingFireTimer.start()

func catch_fire(can_extinguish: bool = true):
	if can_burn:
		self.on_fire = true
		can_catch_fire = true
		
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
	can_catch_fire = false
	extinguish()

func start_drying():
	dryTimer.start()

func dried():
	self.wet = false
	can_burn = true


### TIMERS

func _on_FireDamageTimer_timeout():
	if !wet and on_fire and can_burn:
		emit_signal("received_fire_damage", fire_damage)
		fireDamageTimer.start()


func _on_OnFireExtinguishTimer_timeout():
	if extinguishable:
		extinguish()


func _on_DryTimer_timeout():
	if !in_water:
		dried()


func _on_CatchingFireTimer_timeout():
	catch_fire()
