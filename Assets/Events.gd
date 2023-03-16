extends Node

#Global event signals that nodes can freely connect and signal through

signal combo_up #global that allows any class, usually a dead enemy, to increase the combo count
signal combo_changed(new_value, combo_time) #called by the combo storage class when its value changes to update GUI

signal gold_changed(new_value)
