extends Resource

class_name Card

@export var id: int
@export var CardName: String
@export var CardIlustration: Texture
#air=1 water=2 fire=3 earth=4 light=5 darkness=6
@export var Attack: int
@export var ElementAttack: int

@export var Defense: int
@export var ElementDefense: int
@export var ElementEffect: int
@export var TextEffect: String

@export var Cost: int
@export var Rarity: int

@export var IaDefenseValue: int
@export var IaAttackValue: int
@export var IaReforceValue: int
