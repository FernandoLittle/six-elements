extends Node
class_name AnimationAttacks
@export var TreeAnime: AnimationTree
@export var testanime:int
@export var test_attack_name:String
@export var test_attack_type:int

func _input(event):
	if event.is_action_pressed("E"):
		Stances(testanime)
		testanime+=1
		
	pass
	
func Attack(AttackName:String,AttackAttribute:int):
	print("Attack")
	Stances(AttackAttribute);
	await get_tree().create_timer(0.2).timeout
	TreeAnime.set("parameters/TransitionB/transition_request", AttackName)
	TreeAnime.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	pass
func Stances(stance:int):
	
	if(stance==0):
		print("FireStance")
		TreeAnime.set("parameters/Transition/transition_request", "FireStance")	
		pass
	if(stance==1):
		TreeAnime.set("parameters/Transition/transition_request", "EarthStance")	
		print("Earthtance")
		pass
	if(stance==2):
		TreeAnime.set("parameters/Transition/transition_request", "AirStance")	
		print("PrayStance")
		pass
	if(stance==3):
		TreeAnime.set("parameters/Transition/transition_request", "WaterStance")	
		print("WaterStance")
		pass
	if(stance==4):
		TreeAnime.set("parameters/Transition/transition_request", "GuardStance")	
		print("GuardStance")
		pass
	

	pass


func _on_button_pressed() -> void:
	Attack(test_attack_name,test_attack_type)
	pass # Replace with function body.
