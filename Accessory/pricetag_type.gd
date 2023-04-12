extends Resource
class_name PriceTag

enum ACC_TYPE {HAT, TRAIL, FLOWER}

@export var acc_name := "Name"
@export var acc_type : ACC_TYPE
@export var accessory : Resource
@export var purchase_honey := true
@export var honey_amount := 50.0
@export var purchase_usd := false
@export var usd_amount := 0.99
## Conceptual
@export var achievable := false
@export var achievement : Resource
