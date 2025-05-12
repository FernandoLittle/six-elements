extends Node
@export var deckhand: DeckAndHand
@export var IdBattle:int
@export var InBattle:bool
@export var BattleCards:Array[Cartinha]
@export var BattleZoneArray:Array[Array]
@export var BattleZone1:Array[Cartinha]
@export var BattleZone2:Array[Cartinha]
@export var BattleZone3:Array[Cartinha]

@export var BattleZoneArrayEnemy:Array[Array]
@export var BattleZone1Enemy:Array[Cartinha]
@export var BattleZone2Enemy:Array[Cartinha]
@export var BattleZone3Enemy:Array[Cartinha]



@export var PontuationAlly: Array[int]=[0,0,0]
@export var PontuationEnemy: Array[int]=[0,0,0]
@export var PontuationAllyT: Array[RichTextLabel]
@export var PontuationEnemyT: Array[RichTextLabel]

@export var AllyAttacking:bool

@export var DiceElementAlly:Array[int]
@export var DiceElementEnemy:Array[int]

@export var ElementAlly:int
@export var ElementEnemy:int
@export var ElementIcons:Array[Texture]
@export var ElementAllyS:TextureRect
@export var ElementEnemyS:TextureRect

@export var TurnAlly:bool
@export var Turn:int
@export var zoneplayed: int

func _ready() -> void:
	BattleZoneArray[0].append_array(BattleZone1)
	BattleZoneArray[1].append_array(BattleZone2)
	BattleZoneArray[2].append_array(BattleZone3)
	
	BattleZoneArrayEnemy[0].append_array(BattleZone1Enemy)
	BattleZoneArrayEnemy[1].append_array(BattleZone2Enemy)
	BattleZoneArrayEnemy[2].append_array(BattleZone3Enemy)
	
	HolySpirit.releaseHand.connect(CardHandRelease)
	deckhand.shuffle()
	deckhand.Draw()
	deckhand.DrawEnemy()
	call_deferred("SetDice")
	pass

func ChangeTurn():
	Turn+=1
	TurnAlly=!TurnAlly
	pass
func SetDice():
	print("IIII")
	var chaos=randi_range(0,5)
	var chaos1=randi_range(0,5)

	SetDice1(DiceElementAlly[chaos],DiceElementEnemy[chaos1])

	pass
func SetDice1(Ally: int, Enemy:int):
	if(Ally>0):
		ElementAlly= Ally
		pass
	if(Enemy>0):
		ElementEnemy= Enemy
		pass
	
	ElementAllyS.texture= ElementIcons[ElementAlly-1]
	ElementEnemyS.texture= ElementIcons[ElementEnemy-1]
	HolySpirit.ElementAlly=ElementAlly
	HolySpirit.ElementEnemy=ElementEnemy
	
	HolySpirit.UpdateAllCards()
	pass



func SetPontuation():
	PontuationAlly=[0,0,0]
	PontuationEnemy=[0,0,0]
	for x in range(0, 3):
		for y in range(0, 3):
			if(AllyAttacking==true):
				PontuationAlly[x]+=BattleZoneArray[x][y].Attack
				PontuationEnemy[x]+=BattleZoneArrayEnemy[x][y].Attack
			else:
				PontuationAlly[x]+=BattleZoneArray[x][y].Defense
				PontuationEnemy[x]+=BattleZoneArrayEnemy[x][y].Defense
			pass
		pass
	for x in range(0, 3):
		PontuationAllyT[x].text=str(PontuationAlly[x])
		PontuationEnemyT[x].text=str(PontuationEnemy[x])
		pass

	pass

func AreaEnter(idbattle: int):
	print("wwww")
	IdBattle=idbattle
	InBattle=true
	pass
func AreaExit():
	IdBattle=0
	InBattle=false
	pass

func SetCardInZone(idcard: int):
	if(InBattle==true):		
		for x in range(0, 4):
			if(x==3):
				print("Você só pode reforçar um ataque duas vezes ")
				break
				pass
			else:
				if(BattleZoneArray[IdBattle-1][x].idcard==0):
					AllyPlayCard(IdBattle-1,x,idcard)
					
					break
				pass
			pass
		pass
	SetPontuation()
	pass
	
	
func AllyPlayCard(zone: int, positionzone:int, idcard:int ):
	BattleZoneArray[zone][positionzone].SetAttributes(idcard)
	pass
func CardHandRelease():
	print("foi")
	SetCardInZone(HolySpirit.SelectedCard)
	if(InBattle==true):
		HolySpirit.ZoneMouse=IdBattle
		pass
	else:
		HolySpirit.ZoneMouse=0
		pass



func PlayCards():
	if(AllyAttacking==true):
		OpponentPlayDefense();
		pass
	pass

func FindFreeZone():
	if(CheckFullZone(zoneplayed,false)==true):
		zoneplayed=0
		if(CheckFullZone(zoneplayed,false)==true):
			zoneplayed=1
			if(CheckFullZone(zoneplayed,false)==true):
				zoneplayed=2
				if(CheckFullZone(zoneplayed,false)==true):
					print("Você Tá de sacanagem comigo")
		pass
	pass
func OpponentPlayAttack():
	var cardplayed: int
	
	for x in range(0, 4):
		cardplayed=x
		if(deckhand.CardHandEnemy[cardplayed].Played==false):
			zoneplayed=randi_range(0,3)
			FindFreeZone()
			OpponentPlayCard(cardplayed,zoneplayed)
	pass





func OpponentPlayDefense():
	var cardplayed: int
	for x in range(0, 4):
		if(x<3):	
			if(deckhand.CardHandEnemy[x].IaDefenseValue<deckhand.CardHandEnemy[x+1].IaDefenseValue):
				cardplayed=x+1
			else:
				cardplayed=x
				pass
			pass
		pass
	var zoneplayed: int
	for x in range(0, 2):
		if(PontuationAlly[x]<PontuationAlly[x+1]):
			zoneplayed==x+1
		else:
			zoneplayed=x			
			pass
		pass
	
	OpponentPlayCard(cardplayed,zoneplayed)
	pass
func OpponentPlayCard(cardplayed:int,zoneplayed):
	var positionPlay=0
	if(BattleZoneArrayEnemy[zoneplayed][0].idcard==0):
		positionPlay==0
		pass
	elif(BattleZoneArrayEnemy[zoneplayed][1].idcard==0):
		positionPlay==1
	elif(BattleZoneArrayEnemy[zoneplayed][2].idcard==0):
		positionPlay==2
	else:
		print("Num pode ser")
			
	print("CardPlayedis")
	print(zoneplayed)
	print(positionPlay)
	print(cardplayed)
	BattleZoneArrayEnemy[zoneplayed][positionPlay].SetAttributes(deckhand.CardHandEnemy[cardplayed].idcard)
	CardPlayed(deckhand.CardHandEnemy[cardplayed])
	SetPontuation()
	pass
func CardPlayed(PlayedCard:Cartinha):
	PlayedCard.Played=true
	PlayedCard.hide()
	pass

func CheckFullZone(idBattleZone: int, IsAlly:bool):
	if(IsAlly==true):
		if(BattleZoneArray[idBattleZone][2].idcard!=0):
			return true
			pass
		else:
			return false
		pass
	if(IsAlly==false):
		if(BattleZoneArrayEnemy[idBattleZone][2].idcard!=0):
			return true
			pass
		else:
			return false
		pass
	pass

func UpTurn():
	ResetZones()
	AllyAttacking=!AllyAttacking
	if(AllyAttacking==false):
		deckhand.Draw()
		OpponentPlayAttack()
		pass
	else:
		deckhand.DrawEnemy()
		

	pass

func ResetZones():
	for x in range(0, 3):
		for y in range(0, 3):
			BattleZoneArray[x][y].Reset()
			pass
	pass
	for x in range(0, 3):
		for y in range(0, 3):
			BattleZoneArrayEnemy[x][y].Reset()
			pass
	pass
func UndoPlay():
	for x in range(0, 4):
		if(deckhand.CardHand[x].idcard!=0):
			deckhand.CardHand[x].show()
		pass
	for x in range(0, 3):
		for y in range(0, 3):
			BattleZoneArray[x][y].Reset()
			pass
	
	pass



func Area1Enter() -> void:
	AreaEnter(1)
	
	pass # Replace with function body.


func Area1Exit() -> void:
	AreaExit()
	pass # Replace with function body.


func Area2Enter() -> void:
	AreaEnter(2)
	pass # Replace with function body.


func Area2Exit() -> void:
	AreaExit()
	pass # Replace with function body.


func Area3Enter() -> void:
	AreaEnter(3)
	pass # Replace with function body.


func Area3Exit() -> void:
	AreaExit()
	pass # Replace with function body.


func PlayButtonPressed() -> void:
	PlayCards()
	pass # Replace with function body.


func TurnBeta() -> void:
	UpTurn()
	pass # Replace with function body.


func Undo() -> void:
	UndoPlay()
	pass # Replace with function body.
