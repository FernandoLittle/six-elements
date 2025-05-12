extends Node2D
class_name Cartinha

@export var idcard: int
@export var CardName: String
@export var CardIlustration: Texture
#air=1 water=2 fire=3 earth=4 light=5 darkness=6
@export var Attack: int
@export var TrueAttack: int
@export var ElementAttack: int

@export var Defense: int
@export var TrueDefense: int
@export var ElementDefense: int
@export var ElementEffect: int
@export var TextEffect: String

@export var Cost: int
@export var Rarity: int


@export var ElementIcons: Array[TextureRect]
#Attack=0 Defense=1 Effect=2
@export var ElementIconsTexture: Array[Texture]

@export var CardIlustrationS: TextureRect


@export var NameT: RichTextLabel
@export var CostT: RichTextLabel
@export var EffectT: RichTextLabel
@export var AttackT: RichTextLabel
@export var BlockT: RichTextLabel

@export var pressed: bool

@export var IaDefenseValue: int
@export var IaAttackValue: int
@export var IaReforceValue: int
@export var Played: bool

@export var carddatabase:CardDatabase

#air=1 water=2 fire=3 earth=4 light=5 darkness=6

func _ready():
	print("koko")
	HolySpirit.updateCards.connect(SetAttributes1)
	pass

func SetAttributes1():
	SetAttributes(idcard)
	pass

func Reset():
	SetAttributes(0)
	hide()
	pass

func SetAttributes(id:int):
	idcard=id
	Attack=carddatabase.Cards[idcard].Attack
	Defense=carddatabase.Cards[idcard].Defense
	TextEffect=carddatabase.Cards[idcard].TextEffect
	ElementAttack=carddatabase.Cards[idcard].ElementAttack
	ElementDefense=carddatabase.Cards[idcard].ElementDefense
	ElementEffect=carddatabase.Cards[idcard].ElementEffect
	CardName=carddatabase.Cards[idcard].CardName
	Cost=carddatabase.Cards[idcard].Cost
	Rarity=carddatabase.Cards[idcard].Rarity
	CardIlustration=carddatabase.Cards[idcard].CardIlustration
	IaAttackValue=carddatabase.Cards[idcard].IaAttackValue
	IaDefenseValue=carddatabase.Cards[idcard].IaDefenseValue
	IaReforceValue=carddatabase.Cards[idcard].IaReforceValue
	SetDicePower()
	
	
	NameT.text= CardName
	CostT.text = str(Cost)
	EffectT.text = str(TextEffect)
	AttackT.text = str(TrueAttack)
	BlockT.text = str(TrueDefense)
	CardIlustrationS.texture=CardIlustration
	ElementIcons[0].texture= ElementIconsTexture[ElementAttack-1]
	ElementIcons[1].texture= ElementIconsTexture[ElementDefense-1]
	ElementIcons[2].texture= ElementIconsTexture[ElementEffect-1]
	show()
	pass
	
func SetDicePower():
	TrueAttack=Attack;
	TrueDefense=Defense;
	if(HolySpirit.ElementAlly==ElementAttack || HolySpirit.ElementEnemy==ElementAttack):
		TrueAttack+=1
		pass
	if(HolySpirit.ElementAlly==ElementDefense || HolySpirit.ElementEnemy==ElementDefense):
		TrueDefense+=1
		pass
	pass
	
func _process(delta: float) -> void:
	if(pressed==true):
		global_position=get_global_mouse_position()
	pass


func _pressed() -> void:
	pressed=true
	
	pass # Replace with function body.


func _released() -> void:
	HolySpirit.SelectedCard=idcard
	HolySpirit.CardHandRelease(idcard)
	if(HolySpirit.ZoneMouse==0):
		pressed=false
		position.x=0
		position.y=0
	else:
		position.x=0
		position.y=0
		pressed=false
		Played=true
		hide()

	
	
	
	pass # Replace with function body.
