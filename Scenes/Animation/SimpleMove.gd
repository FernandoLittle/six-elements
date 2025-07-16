extends CharacterBody3D
class_name MyCharacter
@export var MyVelocity:Vector3
@export var moving: bool
@export var MoveTimer: Timer

@export var EnemyVelocity:Vector3
@export var EnemyTimer: float
@export var EnemyCharacter: MyCharacter

@export var Ally:bool
@export var Damage1: GPUParticles3D
@export var Guard1: GPUParticles3D

func _ready() -> void:
	AutoloadBoneco.DamageToAlly.connect(DamagedAlly)
	AutoloadBoneco.PushTheEnemy.connect(Move)
	pass
	
	
	
func DamagedAlly(IsAlly:bool):
	print(IsAlly)
	if(IsAlly==Ally):
		Damage1.restart()
		Damage1.emitting=true
		Guard1.restart()
		Guard1.emitting=true
		print("Ally Take Damage")
		pass
	pass
	
func CauseDamage():
	if(Ally==true):
		AutoloadBoneco.SendDamageToAlly(false)
		pass
	if(Ally==false):
		AutoloadBoneco.SendDamageToAlly(true)
		pass
	pass
	
	
func _physics_process(delta):
	if(moving==true):
		velocity = MyVelocity
		move_and_slide()
	pass
func Move(EnemyVelocity:Vector3, EnemyTime:float, IsAlly:bool):
	if(IsAlly!=Ally):
		moving=true
		MoveTimer.wait_time=EnemyTime
		MyVelocity=EnemyVelocity
		MoveTimer.start()	
		pass
func MoveEnemy():
	AutoloadBoneco.PushEnemy(EnemyVelocity,EnemyTimer,Ally)
	pass














func TimerStop() -> void:
	moving=false
	pass # Replace with function body.
