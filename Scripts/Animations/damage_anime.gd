extends Node
@export var DefenderNode: Node3D
@export var DefenderAnime: AnimationPlayer
@export var AnimeAttacks: AnimationAttacks
func GuardAnime():
	AnimeAttacks.Stances(4)
	pass
func _ready() -> void:
	GuardAnime()
	pass
