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
signal update_purchases()
signal purchase_complete(result)

@export var products : Array[PriceTag] = []

@export var debugging := false
var log : String

var playstore : Object
var connected := false
var sku_integrated := false
var receipt_integrated := false
var purchase_integrated := false
var sku_cataloged := false
var requesting_sku_catalog := false
var sku_catalog = null
var requesting_receipts := false
var receipts_cataloged := false
var receipt_catalog = null
var requesting_purchase := false


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
		playstore.connected.connect(_connection_established)
#		print("***play*** Connection Verity Signal found and connected")
		_log("Connection Verity Signal Found")
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
				_log("Receipt Request Sent.")
			else:
				_log("ERROR Already Requesting Receipts.")
		else:
			_log("ERROR Cannot Request Receipts until SKU is Cataloged.")
	else:
		_log("ERROR Receipt Signals are not integrated.")


func _request_purchase(prod_id : String) -> void:
	_log("Requesting Purchase of prod_id: " + prod_id.to_lower())
	if purchase_integrated:
		if sku_cataloged:
			if !requesting_purchase:
				_log("Purchase Request Sent.")
				requesting_purchase = true
				playstore.purchase(prod_id.to_lower())
			else:
				_log("ERROR Already Requesting Purchase.")
		else:
			_log("ERROR Cannot Make Purchases until SKU is Cataloged.")
	else:
		_log("ERROR Purchase Signals are not integrated.")


## Signal Landing Zone


func _connection_established() -> void:
#	print("***play*** Connected to PlayStore")
	_log("Connected to PlayStore.")
	connected = true
	if playstore.has_signal("disconnected"):
		_log("*Disconnect* Signal Connected.")
		playstore.disconnected.connect(_disconnected)
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
	sku_catalog = sku_details
	for s in sku_details:
		for p in products:
			if s.id.to_upper() == p.prod_id:
				_log("Setting " + str(p.prod_id) + " to VALID with local price: " + str(s.one_time_purchase_details.formatted_price))
				p.validated = true
				p.usd_amount = s.one_time_purchase_details.formatted_price
	_request_receipts()
#	emit_signal("sku_catalog_report")


func _product_details_error(e_code, e_msg, prod_ids) -> void:
	_log("***ERROR on SKU Detail Request...")
	_log("*** " + str(e_code) + " : " + str(e_msg) + " : " + str(prod_ids))
	sku_cataloged = false
	requesting_sku_catalog = false
#	emit_signal("sku_catalog_report")


func _receipt_response(receipts) -> void:
	_log("Received Receipts " + str(receipts))
	receipts_cataloged = true
	requesting_receipts = false
	if receipts.size() > 0:
		for r in receipts:
			if r.has("purchase_state"):
				if r.purchase_state == 1:
					if r.has("products"):
						for p in r.products:
							receipt_catalog.append({
								"acc_name" : _id_to_name(p.to_upper()),
								"acc_id" : p.to_upper()
							})
	emit_signal("update_purchases")


func _purchase_complete(receipt) -> void:
	_log("Purchase Note Received.")
	if receipt.purchase_state == 1:
		_log("Purchase Completed.")
		requesting_purchase = false
		if get_parent().has_method("_add_accessory"):
			for p in receipt.products:
				receipt_catalog.append({
					"acc_name" : _id_to_name(p.to_upper()),
					"acc_id" : p.to_upper()
				})
				get_parent()._add_accessory(_id_to_name(p.to_upper()))
		emit_signal("purchase_complete", true)
	elif receipt.purchase_state == 2:
		_log("Purchase Pending...")


func _purchase_error(e_code, e_msg) -> void:
	_log("***ERROR on Purchase ...")
	_log("*** " + str(e_code) + " : " + str(e_msg))
	requesting_purchase = false
	emit_signal("purchase_complete", false)


## Tools


func _log(s) -> void:
	print(s)
	if debugging:
		log += "\n" + str(s)
		$Debug.text = log


func _id_to_name(id : String) -> String:
	var result = ""
	if products.size() > 0:
		for p in products:
			if p.prod_id == id:
				result = p.acc_name
	return result
