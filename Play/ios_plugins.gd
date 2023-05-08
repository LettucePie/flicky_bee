extends Node

class_name IOSPlugin

signal store_info_complete()
signal update_purchases()

@export var products : Array[PriceTag] = []

enum STATE {
	EMPTY,
	PENDING,
	COMPLETE
}

var in_app_store : Object
var store_info : Array
var store_info_state : STATE
var purchases : Array
var restore_buffer := false


func _ready():
	store_info_state = STATE.EMPTY


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
		print("**ios** Recieved Event: ", event)
		if event.result == "ok":
			if event.type == "product_info":
				_align_store_info(event)
			if event.type == "restore":
				_process_previous_purchase(event.product_id)
		elif event.result == "error":
			print("**ios** INAPPSTORE_ERROR: ", event.type, " ", event.product_id)
			if event.type == "product_info":
				store_info_state = STATE.EMPTY
				store_info.clear()
	if in_app_store.get_pending_event_count() <= 0:
		print("**ios** Events has nothing pending")
		$Timer.stop()


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


func _request_purchases(force : bool) -> void:
	if !restore_buffer or force:
		$Restore_Buffer.start()
		restore_buffer = true
		purchases.clear()
		var request = in_app_store.restore_purchases()


func _process_previous_purchase(prod_id) -> void:
	for p in products:
		if p.prod_id == prod_id:
			purchases.append(p)
			emit_signal("update_purchases")


func _on_restore_buffer_timeout():
	restore_buffer = false
	$Restore_Buffer.stop()
