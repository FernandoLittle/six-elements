extends Node

signal DamageToAlly(ally: bool)
signal PushTheEnemy(VelocityEnemy: Vector3, TimeEnemy: float, AllyIs:bool)
signal GuardEnemy(ally: bool)
signal FallEnemy(ally: bool)


func EnemyFall(IsAlly:bool):
	FallEnemy.emit(IsAlly)
	print("FALL")
	pass
func EnemyGuard(IsAlly:bool):
	GuardEnemy.emit(IsAlly)
	pass
func SendDamageToAlly(IsAlly:bool):
	DamageToAlly.emit(IsAlly)
	pass
func PushEnemy(EnemyVelocity:Vector3, EnemyTime:float, IsAlly:bool):
	PushTheEnemy.emit(EnemyVelocity,EnemyTime, IsAlly)
	pass
