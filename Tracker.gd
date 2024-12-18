extends VBoxContainer

var hovered
var tracker_dict = {}
var position_by_poke = {}
var caught = 0
var planned = 0
var party_pokemon = ["","","","","",""]
var party_size = 0
var party_to_box_pokemon = []
var box_one_pokemon = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
var box_size = 0
var box_two_pokemon = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
var pokemon_to_evo_or_trade = []
var moon_stone_list = ["clefairy","jigglypuff","nidom","nidorino","nidof","nidorina"]
var leaf_stone_list = ["oddish","gloom","exeggcute"]
var fire_stone_list =["eevee","growlithe"]
var candy_list = []
var evo_trade_dict = {"squirtle":"wartortle","wartortle":"blastoise","caterpie":"metapod","metapod":"butterfree","weedle":"kakuna",
"kakuna":"beedrill","pidgeotto":"pidgeot","spearow":"farfetchd","ekans":"arbok","pikachu":"raichu","raichu":"electrode", "nidof":"nidorina","nidorina":"nidoqueen","nidom":"nidorino","nidorino":"nidoking",
"clefairy":"clefable","jigglypuff":"wigglytuff","zubat":"golbat","oddish":"gloom","gloom":"vileplume","paras":"parasect",
"venonat":"tangela","meowth":"persian", "psyduck":"golduck","mankey":"primeape","growlithe":"arcanine","machop":"machoke",
"tentacool":"tentacruel","geodude":"graveler","ponyta":"seel","seel":"dewgong","exeggcute":"exeggutor","eevee":"flareon"}
var useful_dict = {}

var summary

var squirtles = 0
var time_left_by_split = {"Brock":7596,"Misty":6822,"Bill":6212,"Bike":5722,"Rock Tunnel":5148,"Gio 1":4586,"Snorlax":3708,"Koga":3382,"Blaine":2933,"Sevii":2238,"Sabrina":1380,"Erika":1122,"Gio 3":640}
var comp_mons = [4,9,9,10,10,12,15,20,27,35,44,48,51]


# Called when the node enters the scene tree for the first time.
func _ready():
	summary = get_node("TrackerRow3/Summary")
	for key in evo_trade_dict.keys():
		useful_dict[evo_trade_dict[key]] = key
	for row in [1,2,3]:
		var tracker_row = get_node("TrackerRow"+str(row))
		for col in tracker_row.get_children():
			if col.name not in ["Summary","Button","Spacer"]:
				var key = str(row)+","+col.name.substr(3)
				var load_path = col.get_node("Sprite").texture.load_path
				var poke_start = load_path.find("imported/")
				var poke_end = load_path.find(".png")
				var value = load_path.substr(poke_start+9,poke_end-poke_start-9)
				tracker_dict[key] = value
				position_by_poke[value] = key
				col.mouse_entered.connect(Callable(_on_mouse_entered.bind(row,int(col.name.substr(3)))))
				col.mouse_exited.connect(Callable(_on_mouse_exited))
	starter_tracker()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if hovered in tracker_dict.keys():
			var poke = tracker_dict[hovered]
			if event.button_index == 1:
				catch(poke, hovered)
			elif event.button_index == 2:
				plan(poke,hovered)
			update_summary_text()

func _on_mouse_entered(row, col):
	var key = str(row) + "," + str(col)
	if key in tracker_dict.keys():
		hovered = key

func _on_mouse_exited():
	hovered = null

func catch(poke,hover):
	print(hover)
	var evolution = false
	if hover in tracker_dict.keys():
		var bg_path = "TrackerRow"+hover.substr(0,1)+"/Col"+hover.substr(2)+"/BG"
		var current_color = get_node(bg_path).modulate
		get_node(bg_path).modulate = Color.LIGHT_SALMON
		if poke not in party_pokemon && poke not in box_one_pokemon:
			caught += 1
		if current_color == Color.CYAN or current_color == Color.GREEN:
			planned -= 1
			if poke == "nidof" and party_pokemon.count("nidom") > 1:
				evolution = true
				var evo_slot = party_pokemon.find("nidom")
				var slot_name = "Pokemon Area/PartyBG/Slot"+str(evo_slot+1)
				var slot = get_parent().get_node(slot_name)
				var file_name = 'res://Sprites/' + poke + '.png'
				slot.get_node("Sprite").texture = load(file_name)
				print("changing " + poke + " at slot " + slot.name)
				party_pokemon.insert(evo_slot,poke)
				party_pokemon.remove_at(evo_slot+1)
				print(party_pokemon)
			elif poke in useful_dict.keys():
				for pokemon in party_pokemon:
					if pokemon == useful_dict[poke]:
						print("evo is true")
						evolution = true
						var evo_slot = party_pokemon.find(pokemon)
						var slot_name = "Pokemon Area/PartyBG/Slot"+str(evo_slot+1)
						var slot = get_parent().get_node(slot_name)
						var file_name = 'res://Sprites/' + poke + '.png'
						slot.get_node("Sprite").texture = load(file_name)
						print("changing " + poke + " at slot " + slot.name)
						party_pokemon.insert(evo_slot,poke)
						party_pokemon.remove_at(evo_slot+1)
						print(party_pokemon)
			print("party size is " + str(party_size))
			print("box size is " + str(box_size))
		if !evolution and party_size < 6:
			print("moving to party")
			move_to_party(poke)
		elif !evolution:
			print("moving to box")
			move_to_box(poke)

func plan(poke,hover):
	if hover in tracker_dict.keys():
		var bg_path = "TrackerRow"+hover.substr(0,1)+"/Col"+hover.substr(2)+"/BG"
		var current_color = get_node(bg_path).modulate
		if current_color == Color.WHITE:
			get_node(bg_path).modulate = Color.CYAN
			pokemon_to_evo_or_trade.append(poke)
			planned += 1
		elif current_color == Color.CYAN:
			get_node(bg_path).modulate = Color.GREEN
			if poke in useful_dict.keys():
				var candy_poke = useful_dict[poke]
				candy_list.append(candy_poke)
				print(candy_poke)
				for candy_button in get_parent().get_node("Candy Area/HBoxContainer/VBoxContainer").get_children():
					if candy_button.selected == -1:
						var candy_index = candy_index_from_poke(candy_poke)
						if candy_index > -1:
							select_candymon(candy_index)
							candy_button.selected = candy_index
							break
				if candy_poke in box_one_pokemon:
					print("candy poke in box")
					var poke_slot = box_one_pokemon.find(candy_poke)
					var slot_name = "Pokemon Area/BoxBG/VBoxContainer/Row"+str((poke_slot/6)+1)+"/Col" + str((poke_slot%6)+1)
					var slot = get_parent().get_node(slot_name)
					slot.get_node("Sprite").modulate = Color.CORNFLOWER_BLUE
		elif current_color == Color.GREEN:
			get_node(bg_path).modulate = Color.WHITE
			pokemon_to_evo_or_trade.remove_at(pokemon_to_evo_or_trade.find(poke))
			if poke in useful_dict.keys():
				var candy_poke = useful_dict[poke]
				candy_list.remove_at(candy_list.find(candy_poke))
				var candy_index = candy_index_from_poke(candy_poke)
				for candy_button in get_parent().get_node("Candy Area/HBoxContainer/VBoxContainer").get_children():
					if candy_button.selected == candy_index:
						candy_button.selected = -1
						break
			planned -= 1
	update_summary_text()

func update_summary_text():
	summary.text = "CAUGHT: " + str(caught) + "   PLANNED: " + str(planned) + "   TOTAL: " + str(caught+planned)

func clear_party_slots():
	party_size = 0
	for i in 6:
		var slot_name = "Pokemon Area/PartyBG/Slot"+str(i+1)
		var slot = get_parent().get_node(slot_name)
		slot.get_node("Sprite").texture = null

func clear_box():
	box_size = 0
	for i in 5:
		var row_name = "Pokemon Area/BoxBG/VBoxContainer/Row"+str(i+1)
		for j in 6:
			var col_name = "/Col"+str(j+1)
			var slot = get_parent().get_node(row_name + col_name)
			slot.get_node("Sprite").texture = null

func cerulean_deposit():
	#deposit turtle and everything but spearow and second bug, then pull out turtle
	var bugs = 0
	var second_bug = false
	var bug = ""
	var first_bug_slot = 0
	var pika = false
	if "caterpie" in party_pokemon || "weedle" in party_pokemon:
		if "caterpie" in party_pokemon && "weedle" in party_pokemon:
			bugs = 2
			if party_pokemon.find("caterpie") < party_pokemon.find("weedle"):
				first_bug_slot = party_pokemon.find("caterpie")
				bug = "caterpie"
			else:
				first_bug_slot = party_pokemon.find("weedle")
				bug = "weedle"
		elif "caterpie" in party_pokemon:
			first_bug_slot = party_pokemon.find("caterpie")
			bug = "caterpie"
			bugs = 1
		else:
			first_bug_slot = party_pokemon.find("weedle")
			bug = "weedle"
			bugs = 1
	for pokemon in party_pokemon:
		if pokemon not in ["spearow", bug,"pikachu"]:
			party_to_box(pokemon)
		else:
			if pokemon == "pikachu":
				pika = true
	remove_stored_party_pokes()
	party_pokemon = ["","","","","",""]
	party_size = 0
	clear_party_slots()
	move_to_party("wartortle")
	move_to_party("spearow")
	if bug != "":
		move_to_party(bug)
	if pika:
		move_to_party("pikachu")

func sevii_deposit():
	#pull out veno (if we have it), pony, and pika
	var bug = ""
	for pokemon in party_pokemon:
		if pokemon not in ["farfetchd","caterpie","weedle"]:
			party_to_box(pokemon)
		if pokemon == "caterpie" || pokemon == "weedle":
			bug = pokemon
	remove_stored_party_pokes()
	party_pokemon = ["","","","","",""]
	party_size = 0
	clear_party_slots()
	if bug != "":
		move_to_party(bug)
	else:
		move_to_party("caterpie")
	move_to_party("farfetchd")
	if "venonat" in box_one_pokemon && "ponyta" in box_one_pokemon:
		move_to_party("venonat")
		move_to_party("ponyta")
	elif "venonat" in box_one_pokemon || "ponyta" in box_one_pokemon:
		if "venonat" in box_one_pokemon:
			move_to_party("venonat")
		else:
			move_to_party("ponyta")
		if "growlithe" in box_one_pokemon:
			move_to_party("growlithe")
		elif "gloom" in box_one_pokemon:
			move_to_party("gloom")
		else:
			move_to_party("oddish")
	else:
		if "gloom" in box_one_pokemon:
			move_to_party("gloom")
		else:
			move_to_party("oddish")
		move_to_party("exeggcute")
	move_to_party("pikachu")
	move_to_party("blastoise")
	print("party size is " + str(party_size))

func silph_deposit():
	for pokemon in party_pokemon:
		if pokemon not in ["blastoise","farfetchd"]:
			party_to_box(pokemon)
	remove_stored_party_pokes()
	party_pokemon = ["","","","","",""]
	party_size = 0
	move_to_party("blastoise")
	move_to_party("farfetchd")
	if "nidom" in box_one_pokemon:
		move_to_party("nidom")
	else:
		move_to_party("nidorino")
	if "nidof" in box_one_pokemon:
		move_to_party("nidof")
	elif "nidorina" in box_one_pokemon:
		move_to_party("nidorina")
	elif "nidom" in box_one_pokemon:
		move_to_party("nidom")
	move_to_party("clefairy")
	if "caterpie" in box_one_pokemon:
		move_to_party("caterpie")
	else:
		move_to_party("weedle")

func move_to_party(pokemon):
	party_pokemon[party_size] = pokemon
	party_size += 1
	print(party_pokemon)
	#get appropriate slot
	var slot_name = "Pokemon Area/PartyBG/Slot"+str(party_size)
	var slot = get_parent().get_node(slot_name)
	var file_name = 'res://Sprites/' + pokemon + '.png'
	slot.get_node("Sprite").texture = load(file_name)
	if pokemon in box_one_pokemon:
		var box_index = box_one_pokemon.find(pokemon)
		print("need to withdraw " + pokemon + " at " + str(box_index))
		var box_slot_name = "Pokemon Area/BoxBG/VBoxContainer/Row"+str((box_index/6)+1)+"/Col" + str((box_index%6)+1)
		var slot_obj = get_parent().get_node(box_slot_name)
		slot_obj.get_node("Sprite").texture = null
		slot_obj.get_node("Sprite").modulate = Color.WHITE
		box_one_pokemon[box_one_pokemon.find(pokemon)] = ""
		box_size -= 1

func party_to_box(pokemon):
	if party_pokemon.has(pokemon):
		var slot = party_pokemon.find(pokemon)+1
		party_to_box_pokemon.append(slot-1)
		var slot_name = "Pokemon Area/PartyBG/Slot"+str(slot)
		var slot_obj = get_parent().get_node(slot_name)
		slot_obj.get_node("Sprite").texture = null
		move_to_box(pokemon)
	else:
		print("no such pokemon")

func remove_stored_party_pokes():
	for i in 6:
		if 6 - i in party_to_box_pokemon:
			party_pokemon.remove_at(6 - i)

func move_to_box(pokemon):
	var first_empty_slot = box_one_pokemon.find("")
	box_one_pokemon[first_empty_slot] = pokemon
	print(first_empty_slot)
	box_size += 1
	if first_empty_slot != -1:
		var slot_name = "Pokemon Area/BoxBG/VBoxContainer/Row"+str((first_empty_slot/6)+1)+"/Col" + str((first_empty_slot%6)+1)
		var slot = get_parent().get_node(slot_name)
		var file_name = 'res://Sprites/' + pokemon + '.png'
		print(file_name)
		slot.get_node("Sprite").texture = load(file_name)
		slot.get_node("Sprite").modulate = Color.WHITE
		if pokemon in fire_stone_list:
			slot.get_node("Sprite").modulate = Color.ORANGE
		elif pokemon in moon_stone_list:
			slot.get_node("Sprite").modulate = Color.BLUE_VIOLET
		elif pokemon in leaf_stone_list:
			slot.get_node("Sprite").modulate = Color.GREEN
	else:
		var second_empty_slot = box_two_pokemon.find("")
		box_two_pokemon[second_empty_slot] = pokemon
	print("box is:")
	print(box_one_pokemon)
	print(box_two_pokemon)

func candy_index_from_poke(poke):
	var candy_poke_index
	match poke:
		"pidgeotto": candy_poke_index = 0
		"nidom": candy_poke_index = 1
		"nidof": candy_poke_index = 2
		"seel": candy_poke_index = 3
		"paras": candy_poke_index = 4
		"meowth": candy_poke_index = 5
		"psyduck": candy_poke_index = 6
		"tentacool": candy_poke_index = 7
		"ekans": candy_poke_index = 8
		"mankey": candy_poke_index = 9
		"zubat": candy_poke_index = 10
		"geodude": candy_poke_index = 11
		"machop": candy_poke_index = 12
		"oddish": candy_poke_index = 13
		_: candy_poke_index = -1
	return candy_poke_index

func select_candymon(index):
	var candy_poke = ""
	match index:
		0: candy_poke = "pidgeotto"
		1: candy_poke = "nidom"
		2: candy_poke = "nidof"
		3: candy_poke = "seel"
		4: candy_poke = "paras"
		5: candy_poke = "meowth"
		6: candy_poke = "psyduck"
		7: candy_poke = "tentacool"
		8: candy_poke = "ekans"
		9: candy_poke = "mankey"
		10: candy_poke = "zubat"
		11: candy_poke = "geodude"
		12: candy_poke = "machop"
		13: candy_poke = "oddish"
	for pokemon in box_one_pokemon:
		if pokemon == candy_poke:
			var slot_name = "Pokemon Area/BoxBG/VBoxContainer/Row"+str(((box_one_pokemon.size()-1)/6)+1)+"/Col" + str(((box_one_pokemon.size()-1)%6)+1)
			var slot = get_parent().get_node(slot_name)
			slot.get_node("Sprite").modulate = Color.CORNFLOWER_BLUE

func add_squirtle():
	squirtles += 1
	get_parent().get_node("Label2/Label").text = str(squirtles)


func minus_squirtle():
	squirtles -= 1
	get_parent().get_node("Label2/Label").text = str(squirtles)

func project_time():
	var proj_area = get_parent().get_node("Label3")
	var curr_split = time_left_by_split.keys()[proj_area.get_node("OptionButton").selected]
	var minu = proj_area.get_node("LineEdit").text as int
	var sec = proj_area.get_node("LineEdit2").text as int
	var calc_caught = proj_area.get_node("LineEdit3").text as int
	var comp_caught = comp_mons[proj_area.get_node("OptionButton").selected]
	print(comp_caught)
	var calc_planned = proj_area.get_node("LineEdit4").text as int
	var pace = (minu*60)+sec
	print(pace)
	var caught_adj = 30*(calc_caught-comp_caught)
	print(caught_adj)
	var planned_adj = 30*(60-calc_planned)
	print(planned_adj)
	var projection = pace-caught_adj+planned_adj+time_left_by_split[curr_split]
	var proj_hours = (projection/60)/60
	var proj_minutes = (projection/60)%60
	var proj_secs = projection%60
	proj_area.get_node("Projection").text = ("%01d:%02d:%02d" % [proj_hours, proj_minutes, proj_secs])

func clear_tracker():
	caught = 0
	planned = 0
	for row in [1,2,3]:
		var tracker_row = get_node("TrackerRow"+str(row))
		for col in tracker_row.get_children():
			if col.name not in ["Summary","Button","Spacer"]:
				col.get_node("BG").modulate = Color.WHITE

func starter_tracker():
	var pokes_to_plan = [Vector2(1,1),Vector2(1,2),Vector2(1,3),Vector2(1,4),Vector2(1,5),Vector2(1,6),
	Vector2(1,7),Vector2(1,8),Vector2(1,9),Vector2(1,15),Vector2(1,28),Vector2(1,27),Vector2(2,2),
	Vector2(2,3),Vector2(2,11),Vector2(2,17),Vector2(2,20),Vector2(2,27),Vector2(3,13),Vector2(3,14),
	Vector2(3,16),Vector2(3,17),Vector2(3,18)]
	for poke in pokes_to_plan:
		var row = poke[0]
		var colname = "Col" + str(poke[1])
		var tracker_row = get_node("TrackerRow"+str(row))
		var col_bg = tracker_row.get_node(colname).get_node("BG")
		if poke[0] == 1 and poke[1] == 1:
			catch("squirtle","1,1")
		else:
			col_bg.modulate = Color.CYAN
			planned += 1
	update_summary_text()

func reset_tracker():
	clear_tracker()
	clear_party_slots()
	clear_box()
	party_pokemon = ["","","","","",""]
	box_one_pokemon = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
	box_two_pokemon = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
	starter_tracker()
