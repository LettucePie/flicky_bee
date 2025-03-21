extends Resource
class_name PriceTag

enum ACC_TYPE {HAT, TRAIL, FLOWER}

@export var acc_name := "Name"
@export var acc_icon : Texture2D
@export var acc_type : ACC_TYPE
@export var accessory : Resource
@export var purchase_honey := true
@export var honey_amount : int = 50
@export var purchase_usd := false
@export var usd_amount := "String"
@export var validated := false
@export var prod_id := "PRODUCT_ID"
## Conceptual
@export var achievable := false
@export var achievement : Resource
