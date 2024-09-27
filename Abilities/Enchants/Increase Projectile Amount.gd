extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var increased_amount : int

# 0 = Line, 1 = EnemyTarget, 2 = AllyTarget, 3 = Area, 4 = Passive, 5 = Self, 6 = Movement, 7 = EnemyAura, 8 = AllyAura, 9 = Summon

var tags = ["Duplicate"]
var values = [increased_amount]
var types = [0]

func _initialize():
    values = [increased_amount]