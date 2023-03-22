extends Node2D

#Rooms are the contained, crafted chunks that comprise each level
#Rooms are defined by their height and width, and location of their doorways
#Rooms are stacked at their doorways, creating a wavy, messy tower of rooms
#In the future, may allow for splitting and joining rooms

const PORTAL_LENGTH : int = 6

#rooms offer free read access to their identifying variables
@export var height : int = 10
@export var width : int = 10
@export var entrance_location : Vector2 = Vector2(0,3)
