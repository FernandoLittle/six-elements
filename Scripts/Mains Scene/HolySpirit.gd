extends Node
@export var ZoneMouse: int
@export var SelectedCard: int


@export var ElementEnemy: int
@export var ElementAlly: int
signal releaseHand
signal updateCards
func CardHandRelease(idcard:int):
	print("oooo")
	releaseHand.emit()
	pass


func UpdateAllCards():
	updateCards.emit()
	pass
