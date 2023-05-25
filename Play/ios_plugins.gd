extends Node

class_name IOSPlugin

signal store_info_complete()
signal update_purchases(result)
signal purchase_complete(result)

@export var products : Array[PriceTag] = []

enum STATE {
	EMPTY,
	PENDING,
	COMPLETE
}

var in_app_store : Object
var store_info : Array
var store_info_state : STATE
var receipts : Array
var restore_buffer := false

var restoring := false
var purchasing := false

var hold_count := 45


func _ready():
	store_info_state = STATE.EMPTY
	if OS.has_feature("ios"):
		print("Loading iOS Receipts")
		_request_receipts(true)


func _plugin_integrated() -> bool:
	var integrated = false
	if Engine.has_singleton("InAppStore"):
		in_app_store = Engine.get_singleton("InAppStore")
		integrated = true
		print("**ios** ", in_app_store)
	else:
		print("iOS IAP plugin is not available on this platform.")
	return integrated


func _check_events() -> void:
	print("**ios** Check Events")
	while in_app_store.get_pending_event_count() > 0:
		var event = in_app_store.pop_pending_event()
		print("**ios** Received Event: ", event.type, " ", event.result)
		if event.type == "purchase":
			if purchasing:
				if event.result == "progress":
					print("***ios*** Player configuring payment and sign-in...")
				if event.result == "ok":
					_process_purchase(event)
					emit_signal("purchase_complete", true)
					purchasing = false
				if event.result == "error":
					print("***ios*** Purchase Error")
					emit_signal("purchase_complete", false)
					purchasing = false
			else:
				print("***ios*** Rogue Purchasing event ... ", event)
		if event.type == "product_info":
			if event.result == "ok":
				_align_store_info(event)
			if event.result == "error":
				store_info_state = STATE.EMPTY
				store_info.clear()
		if event.type == "restore":
			if restoring:
				if event.result == "ok":
					_process_receipt(event.product_id)
				if event.result == "completed":
					restoring = false
				if event.result == "error":
					print("***ios*** failed to restore purchases aka receipts...")
					restoring = false
					emit_signal("update_purchases", ["ERROR", "Failed to Restore Purchases."])
			else:
				print("**ios** Rogue Restoring Event ... ", event)
	if in_app_store.get_pending_event_count() <= 0:
		print("**ios** Events has nothing pending")
		if !purchasing or !restoring or store_info_state != STATE.PENDING:
			print("***ios*** Events on Hold. Purchasing = ", purchasing, " Restoring = ", restoring, " StoreInfo = ", store_info_state)
			hold_count -= 1
			if hold_count <= 0:
				print("***ios*** Timeout. On Hold for too long")
				$Timer.stop()
				if purchasing:
					emit_signal("purchase_complete", false)
					purchasing = false
				if restoring:
					restoring = false
				if store_info_state == STATE.PENDING:
					store_info_state = STATE.EMPTY
					store_info.clear()
		else:
			print("***ios*** Nothing on hold, ending Event Checks.")
			$Timer.stop()

### Aligning Store information between Local and Apple

func _request_store_info() -> void:
	if store_info_state == STATE.EMPTY:
		print("**ios** Requesting Store Info")
		for p in products:
			p.validated = false
		var prod_ids = []
		for p in products:
			prod_ids.append(str(p.prod_id))
		var request = in_app_store.request_product_info(
			{
				"product_ids" : prod_ids
			}
		)
		print("**ios** Requesting: ", request)
		store_info_state = STATE.PENDING
		hold_count = 45
		$Timer.start(1.0)


func _align_store_info(event) -> void:
	print("**ios** Alinging Store Info on data: ", event)
	store_info.clear()
	var index = 0
	for id in event.ids:
		store_info.append(
			{
				"prod_id" : id,
				"title" : event.titles[index],
				"currency_code" : event.currency_codes[index],
				"local_price" : event.localized_prices[index]
			}
		)
		index += 1
	if store_info.size() > 0:
		print("**ios** LocalPriceType is a String")
		for s in store_info:
			for p in products:
				if s.prod_id == p.prod_id:
					print("Setting ", p.prod_id, " to VALID with local price: ", s.local_price)
					p.validated = true
					p.usd_amount = s.local_price
	store_info_state = STATE.COMPLETE
	print("**ios** Store Info State is Complete!")
	emit_signal("store_info_complete")

### Receipt Loading Section

func _request_receipts(force : bool) -> void:
	if !restore_buffer or force:
		$Restore_Buffer.start()
		restore_buffer = true
		receipts.clear()
		restoring = true
		hold_count = 45
		print("***ios*** Requesting Receipts aka purchases")
		var request = in_app_store.restore_purchases()


func _process_receipt(prod_id) -> void:
	for p in products:
		if p.prod_id == prod_id:
			receipts.append({
				"acc_name" : _id_to_name(prod_id),
				"acc_id" : prod_id
			})
			print("***ios*** Added ", p.prod_id, " to receipts aka purchases")
			emit_signal("update_purchases", ["SUCCESS", "Restored Purchases."])


func _on_restore_buffer_timeout():
	restore_buffer = false
	$Restore_Buffer.stop()
	emit_signal("update_purchases", ["ERROR", "Request Timed Out."])

### Purchasing Section

func _request_purchase(prod_id : String) -> void:
	var valid = false
	for p in products:
		if p.prod_id == prod_id and !_check_ownership(prod_id):
			valid = true
	if valid:
		print("***ios*** Requesting Purchase: ", prod_id)
		purchasing = true
		hold_count = 45
		var request = in_app_store.purchase(
			{"product_id" : prod_id}
		)
		$Timer.start()
	else:
		print("***ios*** Cannot validify purchasing ", prod_id)
		print("***ios*** Must be able to prove it is a Local Product and not already owned.")
		emit_signal("purchase_complete", false)


func _check_ownership(prod_id : String) -> bool:
	var result = false
	if receipts.size() > 0:
		for r in receipts:
			if r.acc_id == prod_id:
				result = true
	return result


func _process_purchase(event) -> void:
	print("***ios*** purchase processed: ", event)
	receipts.append({
		"acc_name" : _id_to_name(event.product_id),
		"acc_id" : event.product_id
	})
	if get_parent().has_method("_add_accessory"):
		get_parent()._add_accessory(_id_to_name(event.product_id))
	in_app_store.finish_transaction(event.product_id)


### Tools


func _id_to_name(id : String) -> String:
	var result = ""
	if products.size() > 0:
		for p in products:
			if p.prod_id == id:
				result = p.acc_name
	return result


func _id_to_product(id : String) -> PriceTag:
	var product = null
	if products.size() > 0:
		for p in products:
			if p.prod_id == id:
				product = p
	return product
