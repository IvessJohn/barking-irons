extends Node

enum DEATH_REASONS {
	KILLED = 1,
	BURNED,
	FELL
}
export(DEATH_REASONS) var death_reason: int = 0
var death_source: Node2D = null
