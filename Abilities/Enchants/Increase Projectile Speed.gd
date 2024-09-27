extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var increased_speed : int

var tags = ["ProjectileSpeed"]
var values = [increased_speed]
var types = [0]

# 0 = Line, 1 = EnemyTarget, 2 = AllyTarget, 3 = Area, 4 = Passive, 5 = Self, 6 = Movement, 7 = EnemyAura, 8 = AllyAura, 9 = Summon

func _initialize():
    values = [increased_speed]