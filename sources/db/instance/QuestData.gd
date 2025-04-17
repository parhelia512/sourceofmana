extends Resource
class_name QuestData

@export var id : int							= DB.UnknownHash
@export var name : String						= ""
@export_multiline var description : String		= ""
@export var giver : String						= ""
@export var giverLocation : String				= ""
@export var target : String						= ""
@export var targetLocation : String				= ""
@export var reward : String						= ""
