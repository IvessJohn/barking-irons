extends Node
class_name SFXPLAYER_CLASS


func play_sfx(sound: AudioStream, parent: Node = get_tree().current_scene,
		pitch_range: Vector2 = Vector2(1.0,1.0), volume_db: float = 1.0,
		pause_behavior = PAUSE_MODE_INHERIT):
	if sound != null and parent != null:
		var stream_player = AudioStreamPlayer.new()
		
		stream_player.stream = sound
		stream_player.connect("finished", stream_player, "queue_free")
		stream_player.pitch_scale = rand_range(pitch_range.x, pitch_range.y)
		stream_player.volume_db = volume_db
		stream_player.pause_mode = pause_behavior
		
		parent.add_child(stream_player)
		stream_player.play()
