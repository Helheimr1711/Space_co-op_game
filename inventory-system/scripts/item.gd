extends Node3D

@onready var item_mesh = $StaticBody3D/MeshInstance3D
@onready var item_collision = $StaticBody3D/CollisionShape3D

@export var template_item : 
