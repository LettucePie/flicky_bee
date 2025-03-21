extends Node

class_name PlaystorePlugin

##
## This script is working off the signals and methods
## found in the GodotGooglePlayBilling Plugin 2.0.0 rc1.
## It can be found here:
## https://github.com/godotengine/godot-google-play-billing.git
## At this SHA address
## 265e78c7b61930cc5d0e8f7bacaaaf26ea888e8c
##
## Changes to the plugin need to be made before build/import.
## They can be found here:
## https://github.com/godotengine/godot-google-play-billing/pull/36
##

signal sku_catalog_report()
signal update_purchases(result)
signal purchase_complete(result)
signal turtle_speed_purchase()

@export var products : Array[PriceTag] = []

@export var debugging := false
var log_out : String

var playstore : Object
var connected := false
var sku_integrated := false
var receipt_integrated := false
var purchase_integrated := false
var acknowledgement_integrated := false
var sku_cataloged := false
var requesting_sku_catalog := false
var sku_catalog = null
var requesting_receipts := false
var receipts_cataloged := false
var receipt_catalog : Array
var resuming_billing := false
var requesting_purchase := false
var purchase_limbo : Array
var turtle_purchase := false
var acknowledging_purchase := false


func _ready():
	$Debug.visible = debugging
	if OS.has_feature("playstore"):
		pass
#		_request_SKUs()


func _plugin_integrated() -> bool:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		playstore = Engine.get_singleton("GodotGooglePlayBilling")
		_log("Integrated with PlayStore Plugin")
		return true
	else:
		_log("NOT Integrated with PlayStore")
		return false


func _establish_connection() -> void:
	if playstore.has_signal("connected"):
		if !playstore.connected.is_connected(_connection_established):
			playstore.connected.connect(_connection_established)
#		print("***play*** Connection Verity Signal found and connected")
		_log("Connection Verity Signal Found")
		print(playstore.getConnectionState())
		if playstore.getConnectionState() == 3:
			_log("CONNECTION CLOSED AND CANNOT BE REOPENED")
		else:
			playstore.startConnection()
	else:
#		print("***play*** Connection Verity Signal not found...")
		_log("Connection Verity Signal NOT Found")


## Command Zone


func _request_SKUs() -> void:
	var prod_ids = PackedStringArray()
	for p in products:
		prod_ids.append(p.prod_id.to_lower())
	_log("Requesting SKU for Product: " + str(prod_ids))
	if sku_integrated and !requesting_sku_catalog:
		## Calling has_method("querySkuDetails") returns false, maybe incompatible with plugins?
		if prod_ids is PackedStringArray:
			requesting_sku_catalog = true
			playstore.querySkuDetails(prod_ids, "inapp")
			$Timer.start(10)
			_log("SKU Request Sent")
		else:
			_log("ERROR Prod_Ids provided are not a PackedStringArray.")
		
	else:
		_log("ERROR Request not sent because signal callback is missing.")


func _request_receipts() -> void:
	_log("Requesting Receipts.")
	receipt_catalog.clear()
	if receipt_integrated:
		if sku_cataloged:
			if !requesting_receipts:
				requesting_receipts = true
				playstore.queryPurchases("inapp")
				$Timer.start(10)
				_log("Receipt Request Sent.")
			else:
				_log("ERROR Already Requesting Receipts.")
		else:
			_log("ERROR Cannot Request Receipts until SKU is Cataloged.")
	else:
		_log("ERROR Receipt Signals are not integrated.")


func _request_purchase(prod_id : String) -> void:
	_log("Requesting Purchase of prod_id: " + prod_id.to_lower())
	if purchase_integrated and acknowledgement_integrated:
		if sku_cataloged:
			if !requesting_purchase:
				_log("Purchase Request Sent.")
				requesting_purchase = true
				turtle_purchase = false
				purchase_limbo.clear()
				playstore.purchase(prod_id.to_lower())
				$Timer.start(60)
			else:
				_log("ERROR Already Requesting Purchase.")
		else:
			_log("ERROR Cannot Make Purchases until SKU is Cataloged.")
	else:
		_log("ERROR Purchase Signals are not integrated.")


func _request_acknowledgement(token) -> void:
	_log("Requesting Acknowledgement for token: " + str(token))
	if acknowledgement_integrated:
		if purchase_limbo.size() > 0:
			if !acknowledging_purchase:
				acknowledging_purchase = true
				playstore.acknowledgePurchase(token)
				$Timer.start(10)
				_log("Acknowledgement Request Sent.")
			else:
				_log("ERROR Already Requesting Acknowledgement.")
		else:
			_log("ERROR There are no Purchases in Limbo needing acknowledgement.")
	else:
		_log("ERROR Acknowledgement Signals are not integrated.")


func _disconnect_service() -> void:
	_log("Forcing Disconnect")
	playstore.endConnection()
	_disconnected()


## Signal Landing Zone


func _connection_established() -> void:
#	print("***play*** Connected to PlayStore")
	_log("Connected to PlayStore.")
	connected = true
	if playstore.has_signal("disconnected"):
		_log("*Disconnect* Signal Connected.")
		playstore.disconnected.connect(_disconnected)
	if playstore.has_signal("billing_resume"):
		_log("*Billing Resume* Signal Connected.")
		playstore.billing_resume.connect(_billing_resume)
	if playstore.has_signal("product_details_query_completed"):
		_log("*Product Query Complete* Signal Connected.")
		playstore.product_details_query_completed.connect(_product_details)
		sku_integrated = true
	if playstore.has_signal("product_details_query_error"):
		_log("*Product Query Error* Signal Connected.")
		playstore.product_details_query_error.connect(_product_details_error)
	if playstore.has_signal("query_purchases_response"):
		_log("*Receipt Response* Signal Connected.")
		playstore.query_purchases_response.connect(_receipt_response)
		receipt_integrated = true
	if playstore.has_signal("purchases_updated"):
		_log("*Purchases Updated* Signal Connected.")
		playstore.purchases_updated.connect(_purchase_complete)
		purchase_integrated = true
	if playstore.has_signal("purchase_error"):
		_log("*Purchase Error* Signal Connected.")
		playstore.purchase_error.connect(_purchase_error)
	if playstore.has_signal("purchase_acknowledged"):
		_log("*Purchase Acknowledge* Signal Connected.")
		playstore.purchase_acknowledged.connect(_purchase_acknowledge)
		acknowledgement_integrated = true
	if playstore.has_signal("purchase_acknowledgement_error"):
		_log("*Purchase Acknowledge Error* Signal Connected.")
		playstore.purchase_acknowledgement_error.connect(_purchase_acknowledge_error)
	##
	## Initialize
	##
	if !sku_cataloged and sku_integrated:
		_request_SKUs()


func _disconnected() -> void:
	connected = false
	_log("Disconnected from PlayStore.")


func _product_details(sku_details) -> void:
	_log("Recieved SKU Details")
	sku_cataloged = true
	requesting_sku_catalog = false
	$Timer.stop()
	sku_catalog = sku_details
	for s in sku_details:
		for p in products:
			if s.id.to_upper() == p.prod_id:
				_log("Setting " + str(p.prod_id) + " to VALID with local price: " + str(s.one_time_purchase_details.formatted_price))
				p.validated = true
				p.usd_amount = s.one_time_purchase_details.formatted_price
	_request_receipts()
	emit_signal("sku_catalog_report")


func _product_details_error(e_code, e_msg, prod_ids) -> void:
	_log("***ERROR on SKU Detail Request...")
	_log("*** " + str(e_code) + " : " + str(e_msg) + " : " + str(prod_ids))
	sku_cataloged = false
	requesting_sku_catalog = false
	$Timer.stop()
	emit_signal("sku_catalog_report")


##
## I would like to quickly try to justify what is going on, and why I'm
## casually typing out IF ELSE Nightmare soup.
##
## This would be my very first app where I have ever used App Store and 
## Playstore integration. Up until now, I have never asked anyone for
## any money, in any of my creations.
##
## I not only have no idea what to do if something goes wrong with a 
## purchase, but I am also completely terrified of being in that 
## situation.
##
## Also, this plugin is in a slightly messy state. It's thrown together
## in a state where Godot 4.0 just came out, and Google Billing has to be
## updated. The Documentation tries its best, but I'm still mostly tredding
## through the dark.
##
## So... in the unlikely case this is viewed and critiqued by others...
## Yes, this code looks barbaric.
## Yes, it could be more optimized.
## No, I am not sorry.
## Yes, I am terrified.
##


func _receipt_response(receipts) -> void:
	_log("Received Receipts.")
	receipts_cataloged = true
	requesting_receipts = false
	$Timer.stop()
	var result = ["", ""]
	result[0] = "ERROR"
	if receipts is Dictionary:
		if receipts.has("purchases"):
			if receipts.purchases.size() > 0:
				for r in receipts.purchases:
					if r.has("purchase_state"):
						if r.purchase_state == 1:
							if r.has("is_acknowledged"):
								if r.has("products"):
									for p in r.products:
										if r.is_acknowledged:
											_log("Cataloging Receipt: " + str(_id_to_name(p.to_upper())))
											receipt_catalog.append({
												"acc_name" : _id_to_name(p.to_upper()),
												"acc_id" : p.to_upper()
											})
											resuming_billing = false
										else:
											_log("ERROR Receipt is not yet acknowledged...")
											_log("Adding Receipt to Limbo.")
											resuming_billing = true
											purchase_limbo.append({
												"token" : r.purchase_token,
												"acc_name" : _id_to_name(p.to_upper()),
												"acc_id" : p.to_upper()
											})
									if purchase_limbo.size() > 0:
										_request_acknowledgement(r.purchase_token)
										result[0] = "HALT"
										result[1] = "Completing Past Transactions."
									else:
										result[0] = "SUCCESS"
										result[1] = "Restored Purchases."
								else:
									_log("ERROR Receipt is missing Products Array.")
									result[1] = "Failure to process receipts."
							else:
								_log("ERROR Receipt is missing Acknowledgment Dictionary Key.")
								result[1] = "Failure to process receipts."
						else:
							_log("ERROR Purchase State is Incomplete.")
							result[1] = "Failure to process transactions."
					else:
						_log("ERROR Receipt is missing Purchase_State Dictionary Key.")
						result[1] = "Failure to process receipts."
			else:
				_log("ERROR Receipt Purchases Key is Empty.")
				result[1] = "Failure to process receipts."
		else:
			_log("ERROR Receipt is missing Purchases Dictionary Key.")
			result[1] = "Failure to process receipts."
	else:
		_log("ERROR Receipts recieved isn't a Dictionary.")
		result[1] = "Failure to fetch any receipts."
	if receipt_catalog.size() > 0 and get_parent().has_method("_add_accessory"):
		for r in receipt_catalog:
			get_parent()._add_accessory(r.acc_name)
	print("Sending Signal Update Purchases with Result : ", result)
	emit_signal("update_purchases", result)


func _purchase_complete(receipt) -> void:
	_log("Purchase Note Received")
	print(receipt)
	if receipt.size() > 0:
		for r in receipt:
			if r.has("is_acknowledged"):
				if !r.is_acknowledged:
					#
					#
					if r.has("purchase_state"):
						print("Purchase State : ", r.purchase_state)
						if r.purchase_state == 1:
							_log("Purchase STATE = Completed.")
							requesting_purchase = false
							$Timer.stop()
							if r.has("products"):
								if r.products.size() > 0:
									for p in r.products:
										purchase_limbo.append({
											"token" : r.purchase_token,
											"acc_name" : _id_to_name(p.to_upper()),
											"acc_id" : p.to_upper()
										})
								else:
									_log("ERROR Purchase Receipt Product Array is Empty.")
									emit_signal("purchase_complete", false)
							else:
								_log("ERROR Purchase Receipt is missing Products Array.")
								emit_signal("purchase_complete", false)
							if purchase_limbo.size() > 0:
								_request_acknowledgement(r.purchase_token)
							else:
								_log("ERROR Failed to stash Purchase into Limbo.")
								emit_signal("purchase_complete", false)
						elif r.purchase_state == 2:
							_log("Purchase STATE = Pending...")
							turtle_purchase = true
							$Timer.start(60)
							emit_signal("turtle_speed_purchase")
						else:
							_log("Purchase STATE UNKNOWN: " + str(receipt))
					else:
						_log("ERROR Purchase Receipt is missing Purchase_State Dictionary Key.")
						emit_signal("purchase_complete", false)
				else:
					_log("ERROR Purchase is already Acknowledged...")
					emit_signal("purchase_complete", false)
			else:
				_log("ERROR Purchase Receipt is missing Acknowledgement Dictionary Key.")
				emit_signal("purchase_complete", false)
	else:
		_log("ERROR Purchase Receipt is an Empty Array.")
		emit_signal("purchase_complete", false)


func _purchase_error(e_code, e_msg) -> void:
	_log("***ERROR on Purchase ...")
	_log("*** " + str(e_code) + " : " + str(e_msg))
	requesting_purchase = false
	$Timer.stop()
	emit_signal("purchase_complete", false)


func _purchase_acknowledge(token) -> void:
	_log("Recieved Acknowledgement for Token: " + str(token))
	var status = false
	acknowledging_purchase = false
	if purchase_limbo.size() > 0:
		var processed_tokens = []
		for p in purchase_limbo:
			if p.token == token:
				processed_tokens.append(p)
		if processed_tokens.size() > 0:
			for p in processed_tokens:
				receipt_catalog.append({
					"acc_name" : p.acc_name,
					"acc_id" : p.acc_id
				})
				if get_parent().has_method("_add_accessory"):
					get_parent()._add_accessory(p.acc_name)
				if purchase_limbo.has(p):
					purchase_limbo.erase(p)
			status = true
		else:
			_log("ERROR Failed to find Token Pairs.")
			status = false
	else:
		_log("ERROR There is nothing in Purchase Limbo.")
		status = false
	if resuming_billing:
		var result = ["", ""]
		if status:
			result[0] = "SUCCESS"
			result[1] = "Finished Previous Purchases and Restored."
		else:
			result[0] = "ERROR"
			result[1] = "Failed to Finish Previous Transactions."
		emit_signal("update_purchases", result)
		resuming_billing = false
		emit_signal("purchase_complete", status)
	else:
		emit_signal("purchase_complete", status)
	$Timer.stop()
#


func _purchase_acknowledge_error(e_code, e_msg, token) -> void:
	_log("ERROR Purchase Acknowledgement : " + str(e_code) + " : " + str(e_msg) + " : " + str(token))
	acknowledging_purchase = false
	emit_signal("purchase_complete", false)
	$Timer.stop()


func _billing_resume() -> void:
	_log("Pending Billing has finished.")
	resuming_billing = true
	_request_receipts()


## Tools


func _log(s) -> void:
	print(s)
	if debugging:
		log_out += "\n" + str(s)
		$Debug.text = log_out


func _id_to_name(id : String) -> String:
	var result = ""
	if products.size() > 0:
		for p in products:
			if p.prod_id == id:
				result = p.acc_name
	return result


func _connection_state() -> int:
	if playstore != null:
		print("Returning PlayStore Connection State: ", playstore.getConnectionState())
		return playstore.getConnectionState()
	else:
		return -1


func _on_timer_timeout():
	$Timer.stop()
	if requesting_sku_catalog:
		_log("ERROR Timed Out Requesting SKUS")
		requesting_sku_catalog = false
	if requesting_receipts:
		_log("ERROR Timed Out Requesting Receipts")
		requesting_receipts = false
		emit_signal("update_purchases", ["ERROR", "Request Timed Out."])
	if requesting_purchase:
		_log("ERROR Timed Out Requesting Purchases")
		if turtle_purchase:
			_log("Turtle Speed Purchase Mode, trying again")
			turtle_purchase = false
			requesting_purchase = true
			$Timer.start(60)
			emit_signal("turtle_speed_purchase")
		else:
			requesting_purchase = false
			emit_signal("purchase_complete", false)
	if acknowledging_purchase:
		_log("ERROR Timed Out Purchase Acknowledgement.")
		acknowledging_purchase = false
		emit_signal("purchase_complegte", false)
