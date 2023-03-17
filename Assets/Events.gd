extends Node

#Global event signals that nodes can freely connect and signal through

signal combo_up #global that allows any class, usually a dead enemy, to increase the combo count
signal combo_changed(new_value:int, combo_time:float) #called by the combo storage class when its value changes to update GUI

signal add_gold(gold_to_add:int)
signal gold_changed(new_value:int)
