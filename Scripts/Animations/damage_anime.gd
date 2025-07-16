extends Node
@export var AllyTree:AnimationTree
@export var AnimeAttacks: AnimationAttacks
@export var Ally: MyCharacter

func _ready() -> void:
	AutoloadBoneco.GuardEnemy.connect(GuardAnime1)
	AutoloadBoneco.FallEnemy.connect(FallAnime1)
	pass

func FallAnime1(IsAlly: bool):
	if(Ally.Ally!=IsAlly):
		AllyTree.set("parameters/TransitionB/transition_request", "Fall")
		AllyTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

		pass
func GuardAnime1(IsAlly: bool):
	if(Ally.Ally!=IsAlly):
		AllyTree.set("parameters/Transition/transition_request", "GuardStance")	
		print("Guard")
		pass

func GuardAnime():
	AutoloadBoneco.EnemyGuard(Ally.Ally)
	print("Guard")
	pass
	##AnimeAttacks.Stances(4)
	#if(is_instance_valid(DefenderTree)):
		#DefenderTree.set("parameters/Transition/transition_request", "GuardStance")	
		#print("Guard")
	#else:
		#print("no anime defender")
		#pass
	pass
	
func FallAnime():
	AutoloadBoneco.EnemyFall(Ally.Ally)
	#if(is_instance_valid(DefenderTree)):
		#DefenderTree.set("parameters/TransitionB/transition_request", "Fall")
		#DefenderTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)



		

	pass
func DamageVFXAnime():
	Ally.CauseDamage()
	print("DamageVFX")

	pass
func PushSlash():
	Push(0.2,Vector3(0.0,0.0,-2.0))
	pass
func Push(TimerPush:float, Velocity:Vector3):
	Ally.EnemyTimer=TimerPush
	Ally.EnemyVelocity= Velocity
	Ally.MoveEnemy()
	pass
