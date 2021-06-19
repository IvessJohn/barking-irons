extends Control

export(bool) var interactable: bool = false

export(AudioStream) var SOUND_START: AudioStream = null

var LEVELS: Array = [
	"res://project/levels/Level1.tscn",
	"res://project/levels/Level2.tscn",
	"res://project/levels/Level3.tscn"
	]
 
onready var animPlayer = $AnimationPlayer


func _ready():
	randomize()

func _physics_process(_delta):
	pass

func _input(event):
	if interactable and event is InputEventKey and event.pressed:
		animPlayer.play("fade_in")
		SfxPlayer.play_sfx(SOUND_START, self)
		yield(animPlayer, "animation_finished")
		get_tree().change_scene(LEVELS[randi() % LEVELS.size()])

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		SoundtrackPlayer.play_soundtrack(SoundtrackPlayer.THEMES.MAIN_MENU)
		animPlayer.play("intermission")
