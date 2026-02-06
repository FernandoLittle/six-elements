extends Node3D
@export var PirateAnime: AnimationPlayer
@export var MageAnime: AnimationPlayer
@export var SparkAnime: AnimationPlayer
@export var AshuraAnime: AnimationPlayer


func Charge():
	MageAnime.play("Charge")
	pass
func Fall():
	MageAnime.play("Fall")
	pass
func Dodge():
	PirateAnime.play("Dodge")
	pass
func Spark():
	SparkAnime.play("new_animation")
	pass
func Ashura():
	AshuraAnime.play("Ashura Pulse")
	pass


func _on_button_pressed() -> void:
	Charge()
	pass # Replace with function body.
