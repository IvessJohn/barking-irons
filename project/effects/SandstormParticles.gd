extends Node2D

enum SANDSTORMS {
	WEAK,
	STRONG
}

func start_sandstorm(storm_enumerator: int):
	var sandstorm: Node2D = get_children()[storm_enumerator]
	if sandstorm.is_in_group("SandstormParticles"):
		sandstorm.emitting = true
		sandstorm.show()
		
		sandstorm.get_child(0).start()	# Start this sandstorm's timer


func _on_StrongTimer_timeout():
	pass # Replace with function body.


func _on_WeakTimer_timeout():
	pass # Replace with function body.
