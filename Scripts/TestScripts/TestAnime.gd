extends Node
@export var animeEffect: AnimationPlayer 
@export var animeEffectT: String 

@export var animeBoneco: AnimationPlayer 
@export var animeBonecoT: String

func _ready():
	PlayAnime()
	pass
func PlayAnime():
	animeEffect.play(animeEffectT)
	animeBoneco.play(animeBonecoT)
	pass
