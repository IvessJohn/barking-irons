extends Node
class_name RandomPicker

export(Array, Resource) var items_list: Array = []

func pick_random_item(items_array: Array = items_list):
	var chosen_value = null
	if items_array.size() > 0:
		# 1. Calculate the overall chance
		var overall_chance: int = 0
		for item in items_array:
			if item.can_be_picked:
				overall_chance += item.PICK_CHANCE
		
		# 2. Generate a random number
		var random_number = randi() % overall_chance
		
		# 3. Pick a random item
		var offset: int = 0
		for item in items_array:
			if item.can_be_picked:
				if random_number < item.PICK_CHANCE + offset:
					chosen_value = item.VALUE
					break
				else:
					offset += item.PICK_CHANCE
	# 4. Return the value
	return chosen_value

func pick_random_enum(enumeration, chances_dictionary: Dictionary):
	var chosen_value = null
#	if enumeration.size() > 0 and chances_dictionary.keys().size() > 0:
#	if chances_dictionary.keys().size() > 0:
	if chances_dictionary.size() > 0:
		# 1. Calculate the overall chance
		var overall_chance: int = 0
		for chance in chances_dictionary.values():
			if chance > 0:
				overall_chance += chance
		
		# 2. Generate a random number
		var random_number = randi() % overall_chance
		
		# 3. Pick a random item
		var offset: int = 0
		for event in enumeration:
			print(event)
			if chances_dictionary[int(event)] > 0:
				if random_number < chances_dictionary[int(event)] + offset:
					chosen_value = event
					break
				else:
					offset += chances_dictionary[int(event)]
	# 4. Return the value
	return chosen_value
