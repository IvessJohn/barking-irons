extends "res://project/objects/pickables/PickableItem.gd"

var faction: int = Global.FACTIONS.OFFICER

export(Texture) var OUTLAW_BADGE_TEXTURE: Texture = null
export(Texture) var OFFICER_BADGE_TEXTURE: Texture = null


func init(_faction: int):
	faction = _faction

func _ready():
	match (faction):
		Global.FACTIONS.OUTLAW:
			sprite.texture = OUTLAW_BADGE_TEXTURE
		Global.FACTIONS.OFFICER:
			sprite.texture = OFFICER_BADGE_TEXTURE

func _on_BadgeItem_picked(picker):
	pass # Replace with function body.
