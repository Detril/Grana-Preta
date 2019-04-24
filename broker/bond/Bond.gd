extends Button

signal opened(parent)
signal closed(parent)

const FONT_WIDTH = 15
const BASE_HEIGHT = 80
const TWN_TIME = .2
const SUBJECT_LESSON_SCN = preload("res://school/Subjects/SubjectLesson.tscn")

var is_open = false
var bond_name : String
var rentability : float
var rentability_type : String # Pre, Pos index or Pos provisioned 
var expiration
var min_investment : int
var min_time
var taxes
var creation_time


func setup(bond_name : String, rentability : float, rentability_type : String, expiration : Array, min_investment : int, min_time : Array, taxes : Array, creation_time):
	self.bond_name = bond_name
	self.rentability = stepify(rentability, 0.1)
	self.rentability_type = rentability_type
	self.expiration = expiration
	self.min_investment = min_investment
	self.min_time = min_time
	self.taxes = taxes
	
	$Name.text = bond_name
	$MinTime.text = "Carencia: "
	if min_time[0] > 0:
		$MinTime.text += str(min_time[0], " dias")
		if min_time[1] > 0:
			$MinTime.text += str(" e\n", min_time[1], " horas")
	elif min_time[1] > 0:
		$MinTime.text += str(min_time[1], " horas")
	$Taxes.text = str("Taxas:\nIR(", taxes[0], "%), Adm(", stepify(taxes[1], 0.1), "%),\nPerf(", stepify(taxes[2], 0.1), "%)")
	expand_info() # used here to adapt labels to correct size
	resume_info()


func resume_info():
	$Rentability.rect_scale = Vector2(1, 1)
	if rentability_type == "Pre-fixada":
		$Rentability.text = str("PRE", rentability)
	elif rentability_type == "Pos-fixada":
		$Rentability.text = str("POS", rentability)
		$Name.text = bond_name
	
	$Expiration.rect_scale = Vector2(1, 1)
	if expiration[0] > 0: # days left
		$Expiration.text = str(expiration[0], "D")
	elif expiration[1] > 0: # hours left
		$Expiration.text = str(expiration[1], "H")
	
	$MinInvestment.rect_scale = Vector2(1, 1)
	$MinInvestment.text = str(min_investment)


func expand_info():
	$Rentability.rect_scale = Vector2(.7, .7)
	$Rentability.text = "Rentabilidade:\n"
	if rentability_type == "Pre-fixada":
		$Rentability.text += str("Pre-fixada em ", rentability , "%")
	elif rentability_type == "Pos-fixada":
		$Rentability.text += str("Pos-fixada em ", rentability , "%")
		var name_split = bond_name.split("-")
		if name_split[0] == "S":
			$Name.text = str("Selic - ", name_split[1])
		elif name_split[0] == "I":
			$Name.text = str("Inflation - ", name_split[1])
	
	$Expiration.rect_scale = Vector2(.7, .7)
	$Expiration.text = "Vencimento:\n"
	if expiration[0] > 0: # days left
		$Expiration.text += str(expiration[0], " dias")
		if expiration[1] > 0: # hours left
			$Expiration.text += str("\ne ", expiration[1], " horas")
	elif expiration[1] > 0: # hours left
		$Expiration.text += str(expiration[1], " horas")
	
	$MinInvestment.rect_scale = Vector2(.7, .7)
	$MinInvestment.text = str("Requisito:\nG$ ", min_investment)


func close():
	resume_info()
	$MinTime.hide()
	$Taxes.hide()
	$Tween.interpolate_property(self, "rect_size:y", null, 70, TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Name, "rect_position:x", null, 10, TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Rentability, "rect_position", null, Vector2(110, -20), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Expiration, "rect_position", null, Vector2(260, -45), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MinInvestment, "rect_position", null, Vector2(320, -20), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Apply, "rect_position", null, Vector2(425, 2), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Apply, "rect_size", null, Vector2(147, 64), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	
	is_open = false
	emit_signal("closed", self)


func open():
	expand_info()
	$MinTime.show()
	$Taxes.show()
	$Tween.interpolate_property(self, "rect_size:y", null, 360, TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Name, "rect_position:x", null, (rect_size.x - $Name.rect_size.x)/2, TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Rentability, "rect_position", null, Vector2(10, 50), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Expiration, "rect_position", null, Vector2(300, 50), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MinInvestment, "rect_position", null, Vector2(10, 130), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Apply, "rect_position", null, Vector2((rect_size.x - 350)/2, 290), TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Apply, "rect_size:x", null, 350, TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($MinTime, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2*TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Taxes, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2*TWN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	
	is_open = true
	emit_signal("opened", self)


func _on_Bond_pressed():
	if is_open:
		close()
	else:
		open()
