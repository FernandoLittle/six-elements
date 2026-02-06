extends Node3D
@export var anime: AnimationPlayer
@export var anime1: AnimationPlayer
func Shock_Anime():

	pass
func Ashura_Pulse():
	anime1.play("Ashura Pulse")
	pass
func Ashura_End():
	anime1.play("End")
	pass


func _on_button_pressed() -> void:
	Ashura_Pulse()
	pass # Replace with function body.
