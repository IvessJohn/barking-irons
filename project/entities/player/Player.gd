extends "res://project/entities/EntityBase.gd"

signal shot_himself

export(bool) var has_shot_himself: bool = false

var moved_while_paused: bool = false

var available_interactive_areas: Array = []


func _physics_process(_delta):
	if can_move:
		### MOVEMENT
		var input_direction = get_input_direction()
		velocity = SPEED * SPEED_MODIFIER * input_direction
		
		if input_direction != Vector2.ZERO and get_tree().paused:
			moved_while_paused = true
		
		### ATTACKING
		if Input.is_action_just_pressed("shoot"):
	#		var shooting_vector = global_position.direction_to(get_global_mouse_position())
			var attack_vector = get_local_mouse_position().normalized()
			
			$ProjSpawnPivot.rotation = attack_vector.angle()
			
			attack_in_direction(attack_vector, current_armed_state == ARMED_STATES.UNARMED)
		
		### INTERACTING
		if Input.is_action_just_pressed("action_interact"):
			interact_with_closest_object()
	
	apply_and_decrease_knockback()
	move()

func interact_with_closest_object():
	if available_interactive_areas.size() > 0:
		var closest_area: InteractiveArea = available_interactive_areas[0]
		
		if available_interactive_areas.size() > 1:
			for area in available_interactive_areas:
				if global_position.distance_to(area.global_position) < global_position.distance_to(closest_area.global_position):
					closest_area = area
		
		closest_area.interact(self)


func get_input_direction() -> Vector2:
	var input_dir: Vector2 = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_dir = input_dir.normalized()
	
	return input_dir


func _on_Player_got_hit(damage):
	get_tree().get_nodes_in_group("LevelCamera")[0].start_new_shake(damage * 0.1, 0.15)


func _on_Hurtbox_area_entered(hitbox):
	if hitbox.is_in_group("Hitbox"):
		if hitbox.hit_owner == self:
			emit_signal("shot_himself")
			has_shot_himself = true
			print("shot_himself")
			
			if get_tree().current_scene.is_in_group("Level"):
				get_tree().current_scene.player_shot_himself = true
		
		receive_damage(hitbox.damage)
		receive_knockback(hitbox.global_position, hitbox.damage)
		
		if hitbox.is_in_group("Projectile"):
			hitbox.destroy()
		
		SfxPlayer.play_sfx(HIT_SOUND, get_tree().current_scene, Vector2(0.8, 1.1))
	#	spawn_effect(EFFECT_HIT)

func _on_Player_died(_self):
	die(false)


func _on_InteractingArea_area_entered(area):
	available_interactive_areas.append(area)

func _on_InteractingArea_area_exited(area):
	available_interactive_areas.erase(area)
