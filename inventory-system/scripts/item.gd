extends Node3D

@onready var item_mesh = $StaticBody3D/MeshInstance3D
@onready var item_collision = $StaticBody3D/CollisionShape3D

@export var item_template: String
var item_id: String
var item_number: int
var item_type: String

func _ready() -> void:
	if item_template in ItemsTemplates.items_templates:
		#creating item id
		create_item_id()
		item_number = ItemsTemplates.items_templates[item_template].number
		item_mesh.mesh = load(ItemsTemplates.FILE_PATH + item_template + ".obj")
	else:
		print("Item: " + item_template + " dont exist.")

func create_item_id():
	item_id = str(ItemsTemplates.items_templates[item_template].id) + "_" + str(ItemsTemplates.items_templates[item_template].item_type) + "_" + str(ItemsTemplates.items_templates[item_template].number)
func update_item_id():
	var old_item_id = item_id.split("_", 1)
	var new_item_id = old_item_id + "_" + str(item_number)
	item_id = new_item_id
	print("Old: " + old_item_id)
	print("New: " + new_item_id)
	

func _physics_process(delta: float) -> void:
	update_item_id()
	item_number -= 1
	#print(item_id)
