extends Node3D

@onready var item_mesh = $StaticBody3D/MeshInstance3D
@onready var item_collision = $StaticBody3D/CollisionShape3D

@export var item_template: String
var item_id: String

func _ready() -> void:
	if item_template in ItemsTemplates.items_templates:
		#adding id                                                                    #adding item type
		item_id = str(ItemsTemplates.items_templates[item_template].id) + "_" + str(ItemsTemplates.items_templates[item_template].item_type)
		match ItemsTemplates.items_templates[item_template].item_type:
			0:
				#weapon
				item_id = item_id + "_" + str(ItemsTemplates.items_templates[item_template].mag_size)
			1:
				#consumable
				item_id = item_id + "_" + str(ItemsTemplates.items_templates[item_template].health)
			2:
				#valuable
				pass
			3:
				#amunition
				item_id = item_id + "_" + str(ItemsTemplates.items_templates[item_template].size)
		
		print(item_id)
		
		item_mesh.mesh = load(ItemsTemplates.FILE_PATH + item_template + ".obj")
	else:
		print("Item: " + item_template + " dont exist.")

func _process(delta: float) -> void:
	print(item_id)
