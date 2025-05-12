extends Node
class_name DeckAndHand
@export var DeckAlly=[1,2,3,4,5,6,7,8]
@export var DeckEnemy=[1,2,3,4,5,6,7,8]
@export var CardHand: Array[Cartinha]
@export var CardHandEnemy: Array[Cartinha]
@export var carddatabase:CardDatabase


func shuffle():
	DeckAlly.shuffle()
	DeckEnemy.shuffle()
	pass	
func Draw():
	for x in range(0, 4):
		if(CardHand[x].idcard==0):

			CardHand[x].idcard=DeckAlly.pop_front()	
			SetCardInfo(x,CardHand[x].idcard)		
		pass

	pass	
func DrawEnemy():
	for x in range(0, 4):
		if(CardHandEnemy[x].idcard==0):

			CardHandEnemy[x].idcard=DeckEnemy.pop_front()	
			SetCardInfoEnemy(x,CardHandEnemy[x].idcard)		
		pass

	pass	


func SetCardInfo(cardzone: int, cardid: int):
	
	CardHand[cardzone].SetAttributes(cardid)
	pass
func SetCardInfoEnemy(cardzone: int, cardid: int):
	
	CardHandEnemy[cardzone].SetAttributes(cardid)
	pass
