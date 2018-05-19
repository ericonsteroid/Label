//
//  LabelModels.swift
//  Label
//
//  Created by Anthony Gordon on 18/10/2017.
//  Copyright © 2018 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation
import UIKit
import PMAlertController
import Alamofire
import SwiftyJSON

class labelUserNonce:Codable {
    var token:String! = String()
    init(json:JSON) {
        self.token = json["token"].string
    }
}

class LabelTaxes {
    public var id:Int! = Int()
    public var country:String! = String()
    public var state:String! = String()
    public var postcode:String! = String()
    public var city:String! = String()
    public var rate:String! = String()
    public var name:String! = String()
    public var priority:Int! = Int()
    var compound:Bool!
    var shipping:Bool!
    public var order:Int! = Int()
    public var taxClass:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].int
        self.country = json["country"].string
        self.state = json["state"].string
        self.postcode = json["postcode"].string
        self.city = json["city"].string
        self.rate = json["rate"].string
        self.name = json["name"].string
        self.priority = json["priority"].int
        self.compound = json["compound"].bool
        self.shipping = json["shipping"].bool
        self.order = json["order"].int
        self.taxClass = json["class"].string
    }
}

// MARK: WORDPRESS
struct wpUser:Codable {
    
    public var token:String! = String()
    public var id:Int! = Int()
    public var username:String! = String()
    public var nicename:String! = String()
    public var email:String! = String()
    public var url:String! = String()
    public var displayname:String! = String()
    public var firstname:String! = String()
    public var lastname:String! = String()
    public var nickname:String! = String()
    public var capabilities:[String:Bool]! = [String:Bool]()
    
    init(json:JSON) {
        self.token = json["cookie"].string
        
        guard let user = json["user"].dictionary else {
            return
        }
        
        self.id = user["id"]?.int
        self.username = user["username"]?.string
        self.nicename = user["nicename"]?.string
        self.email = user["email"]?.string
        self.url = user["url"]?.string
        self.displayname = user["displayname"]?.string
        self.firstname = user["firstname"]?.string
        self.lastname = user["lastname"]?.string
        self.nickname = user["nickname"]?.string
        self.capabilities["subscriber"] = user["capabilities"]?.bool
    }
}

class sShippingZones {
    public var id:Int! = Int()
    public var name:String! = String()
    public var order:Int! = Int()
    
    init(json:JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.order = json["order"].int
    }
}

class LabelShipping {
    
    public var parentId:Int! = Int()
    public var name:String! = String()
    public var code:String! = String()
    public var type:String! = String()
    public var methods:[LabelShippingMethod] = []
    
    init(json:JSON) {
        
        self.parentId = json["parent_id"].int
        self.name = json["name"].string
        self.code = json["code"].string
        self.type = json["type"].string
        
        guard let methods = json["method"].array else {
            return
        }
        
        for method in methods {
            self.methods.append(LabelShippingMethod(json:method))
        }
    }
}

class LabelShippingMethod {
    
    public var instanceId:Int! = Int()
    public var methodId:String = String()
    public var methodTitle:String = String()
    public var methodDescription:String = String()
    public var methodOrder:Int! = Int()
    public var flatRateShipping:LabelShippingFlatRate!
    public var localPickupShipping:LabelShippingLocalPickup!
    public var freeShippingShipping:LabelShippingFreeShipping!
    
    init(json:JSON) {
        self.instanceId = json["instance_id"].int
        self.methodId = json["method_id"].string!
        self.methodTitle = json["method_title"].string!
        self.methodDescription = json["method_description"].string!
        self.methodOrder = json["method_order"].int
        
        switch methodId {
        case "flat_rate":
            self.flatRateShipping = LabelShippingFlatRate(json:json["method"])
            break
        case "free_shipping":
            self.freeShippingShipping = LabelShippingFreeShipping(json:json["method"])
            break
        case "local_pickup":
            self.localPickupShipping = LabelShippingLocalPickup(json:json["method"])
            break
        default:
            break
        }
    }
}

class LabelShippingFlatRate {
    
    public var settingsTitle:shippingSettingTitle!
    public var settingsCost:shippingSettingsCost!
    public var settingsTaxStatus:shippingSettingsTaxStatus!
    public var settingsNoClassCost:shippingSettingsNoClassCost!
    public var settingsType:String! = String()
    public var shippingDict:[JSON]? = []
    public var shippingTotal:String! = "0"
    
    init(json:JSON) {
        
        self.settingsTitle = shippingSettingTitle(json: json["settings_title"])
        self.settingsCost = shippingSettingsCost(json: json["settings_cost"])
        self.settingsTaxStatus = shippingSettingsTaxStatus(json: json["settings_tax_status"])
        self.settingsNoClassCost = shippingSettingsNoClassCost(json:json["settings_no_class_cost"])
        shippingDict = json["settings_methods"].array
    }
}

class LabelShippingLocalPickup {
    
    public var settingsTitle:shippingSettingTitle!
    public var settingsTax:shippingSettingsTaxStatus!
    public var settingCost:shippingSettingsCost!
    
    init(json:JSON) {
        self.settingsTitle = shippingSettingTitle(json:json["settings_title"])
        self.settingsTax = shippingSettingsTaxStatus(json:json["settings_tax_status"])
        self.settingCost = shippingSettingsCost(json:json["settings_cost"])
    }
    
}

class LabelShippingFreeShipping {

    public var settingsTitle:shippingSettingTitle!
    public var settingsRequires:shippingSettingsRequries!
    public var settingsMinAmount:shippingSettingsMinAmount!
    
    init(json:JSON) {
        
        self.settingsTitle = shippingSettingTitle(json:json["settings_title"])
        self.settingsMinAmount = shippingSettingsMinAmount(json:json["settings_min_amount"])
        self.settingsRequires = shippingSettingsRequries(json:json["settings_requires"])
    }
}

class shippingSettingsMinAmount {
    public var id:String! = String()
    public var label:String! = String()
    public var desc:String! = String()
    public var type:String! = String()
    public var value:String! = String()
    public var sDefault:String! = String()
    public var tip:String! = String()
    public var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsRequries {
    public var id:String! = String()
    public var label:String! = String()
    public var desc:String! = String()
    public var type:String! = String()
    public var value:String! = String()
    public var sDefault:String! = String()
    public var tip:String! = String()
    public var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingTitle {
    public var id:String! = String()
    public var label:String! = String()
    public var desc:String! = String()
    public var type:String! = String()
    public var value:String! = String()
    public var sDefault:String! = String()
    public var tip:String! = String()
    public var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsCost {
    public var id:String! = String()
    public var label:String! = String()
    public var desc:String! = String()
    public var type:String! = String()
    public var value:String! = String()
    public var sDefault:String! = String()
    public var tip:String! = String()
    public var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsNoClassCost {
    public var id:String! = String()
    public var label:String! = String()
    public var desc:String! = String()
    public var type:String! = String()
    public var value:String! = String()
    public var sDefault:String! = String()
    public var tip:String! = String()
    public var placeholder:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

class shippingSettingsTaxStatus {
    public var id:String! = String()
    public var label:String! = String()
    public var desc:String! = String()
    public var type:String! = String()
    public var value:String! = String()
    public var sDefault:String! = String()
    public var tip:String! = String()
    public var placeholder:String! = String()
    public var options:taxOptions!
    
    init(json:JSON) {
        self.id = json["id"].string
        self.label = json["label"].string
        self.desc = json["description"].string
        self.type = json["type"].string
        self.value = json["value"].string
        self.sDefault = json["default"].string
        self.tip = json["tip"].string
        self.placeholder = json["placeholder"].string
    }
}

struct taxOptions {
    var taxable:String! = String()
    var none:String! = String()
}

// MARK: SHIPPING ADDRESS
/**
 Shipping address which contains the following
 - line1 : String
 - city : String
 - county : String
 - postcode : String
 - country : String
 */
class labelShippingAddress:Codable {
    
    var line1:String! = String()
    var city:String! = String()
    var county:String! = String()
    var postcode:String! = String()
    var country:String! = String()
    
    init(dataDict:JSON) {
        self.line1 = dataDict["addressline"].stringValue
        self.city = dataDict["city"].stringValue
        self.county = dataDict["county"].stringValue
        self.postcode = dataDict["postcode"].stringValue
        self.country = dataDict["country"].stringValue
    }
    
    public func opFullAddress() -> String {
        var str:String! = String()
        
        if let addressLine = self.line1 { str = addressLine + ", " }
        if let addressCity = self.city { str =  str + addressCity + ", " }
        if let addressCounty = self.county { str = str + addressCounty + ", " }
        if let addressPostcode = self.postcode { str = str + addressPostcode + ", " }
        if let addressCountry = self.country { str = str + addressCountry }
        
        return str
    }
}

// MARK: BASKET
/**
 Basket item containing the following
 - storeItem : storeItem
 - qty : Int
 - variationID : Int
 */
class sBasket:Codable {
    
    public var storeItem:storeItem!
    var qty:Int! = Int()
    var variationID:Int! = Int()
    var variationTitle:String = String()
    
    init(storeItem:storeItem,qty:Int,variationID:Int = 0,variationTitle:String = "") {
        self.storeItem = storeItem
        self.qty = qty
        self.variationID = variationID
        self.variationTitle = variationTitle
    }
}

// MARK: CATEGORY IMAGE
class sCategoryImage:Codable {
    
    var id:Int! = Int()
    var date_created:String! = String()
    var date_modified:String! = String()
    var src:String! = String()
    var title:String! = String()
    var alt:String! = String()
    
    init(dataDict:JSON) {
        self.id = dataDict["id"].intValue
        self.date_created = dataDict["date_created"].string
        self.date_modified = dataDict["date_modified"].string
        self.src = dataDict["src"].string
        self.title = dataDict["title"].string
        self.alt = dataDict["alt"].string
    }
}

// MARK: STOREITEM CATEGORY
class sCategory:Codable {
    
    public var id:Int!
    var name:String! = String()
    var slug:String! = String()
    public var parent:Int!
    var desc:String! = String()
    var display:String! = String()
    public var image:sCategoryImage!
    public var menu_order:Int!
    public var count:Int!
    
    init(dataDict:JSON) {
        self.id = dataDict["id"].intValue
        self.name = dataDict["name"].string
        self.slug = dataDict["slug"].string
        self.parent = dataDict["parent"].intValue
        self.desc = dataDict["desc"].string
        self.display = dataDict["display"].string
        self.image = sCategoryImage(dataDict:dataDict["image"])
        self.menu_order = dataDict["menu_order"].intValue
        self.count = dataDict["count"].intValue
    }
}

// MARK: BILLING
class sBilling: Codable {
    var first_name:String! = String()
    var last_name:String! = String()
    var company:String! = String()
    var address_1:String! = String()
    var address_2:String! = String()
    var city:String! = String()
    var state:String! = String()
    var postcode:String! = String()
    var country:String! = String()
    var email:String! = String()
    var phone:String! = String()
    
    init(dataDict:JSON) {
        self.first_name = dataDict["first_name"].string
        self.last_name = dataDict["last_name"].string
        self.company = dataDict["company"].string
        self.address_1 = dataDict["address_1"].string
        self.address_2 = dataDict["address_2"].string
        self.city = dataDict["city"].string
        self.state = dataDict["state"].string
        self.postcode = dataDict["postcode"].string
        self.country = dataDict["country"].string
        self.email = dataDict["email"].string
        self.phone = dataDict["phone"].string
    }
}

// MARK: VARIATION
class sVariation:Codable {
    
    public var id:Int!
    var date_created:String! = String()
    var sku:String! = String()
    var price:String! = String()
    var regular_price:String! = String()
    var sale_price:String! = String()
    public var on_sale:Bool!
    public var purchasable:Bool!
    var tax_status:String! = String()
    var tax_class:String! = String()
    public var manage_stock:Bool!
    public var stock_quantity:String?
    public var in_stock:Bool!
    var backorders:String! = String()
    public var backorders_allowed:Bool!
    public var backordered:Bool!
    public var image:sImages!
    var shipping_class:String! = String()
    var shipping_class_id:Int! = Int()
    var attributes:[sVariationAttributes]! = [sVariationAttributes]()
    
    init(dataDict:JSON = dVariations) {
        
        self.id = dataDict["id"].int
        self.date_created = dataDict["date_created"].string
        self.sku = dataDict["sku"].string
        self.price = dataDict["price"].string
        self.regular_price = dataDict["regular_price"].string
        self.sale_price = dataDict["sale_price"].string
        self.on_sale = dataDict["on_sale"].bool
        self.purchasable = dataDict["purchasable"].bool
        self.tax_status = dataDict["tax_status"].string
        self.tax_class = dataDict["tax_class"].string
        self.manage_stock = dataDict["manage_stock"].bool
        self.stock_quantity = dataDict["stock_quantity"].string ?? ""
        self.in_stock = dataDict["in_stock"].bool
        self.backorders = dataDict["backorders"].string
        self.backorders_allowed = dataDict["backorders_allowed"].bool
        self.backordered = dataDict["backordered"].bool
        self.shipping_class = dataDict["shipping_class"].string
        self.shipping_class_id = dataDict["shipping_class_id"].int
        self.image = sImages(dataDict: dataDict["image"])
        
        self.attributes = []
        
        if dataDict["attributes"].array?.count != 0 && dataDict["attributes"].array != nil {
            for i in 0..<(dataDict["attributes"].array?.count)! {
                let oVariation:sVariationAttributes! = sVariationAttributes(dataDict: ((dataDict["attributes"].array)?[i])!)
                self.attributes.append(oVariation)
            }
        }
        if self.attributes.count == 0 {
            
            self.attributes = [sVariationAttributes()]
        }
    }
}

// MARK: VARIATION ATTRIBUTES
class sVariationAttributes:Codable {
    var id:Int! = Int()
    var name:String! = String()
    var option:String! = String()
    
    init(dataDict:JSON = dAttributes) {
        self.id = dataDict["id"].intValue
        self.name = dataDict["name"].stringValue
        self.option = dataDict["option"].stringValue
    }
}

// MARK: ATTRIBUTES
class sAttributes:Codable {
    var id:Int!
    var name:String! = String()
    var position:Int! = Int()
    var visible:Bool! = Bool()
    var variation:Bool! = Bool()
    var options:[String]! = [String]()
    
    init(dataDict:JSON = dAttributes) {
        
        self.id = dataDict["id"].intValue
        self.name = dataDict["name"].stringValue
        self.position = dataDict["position"].intValue
        self.visible = dataDict["visible"].boolValue
        self.variation = dataDict["variation"].boolValue
        
        self.options = []
        
        if dataDict["options"].array?.count != 0 && dataDict["options"].array != nil {
            
            for i in 0..<(dataDict["options"].array?.count)! {
                let optionVal:String! = (dataDict["options"].array)![i].string
                self.options.append(optionVal)
            }
            
        }
        if self.options.count == 0 {
            self.options = [String]()
        }
    }
}

// MARK: IMAGES
class sImages: Codable {
    
    var id:String! = String()
    var date_created:String! = String()
    var date_modified:String! = String()
    var src:String! = String()
    var name:String! = String()
    var position:String! = String()
    var variations:String! = String()
    
    init(dataDict:JSON) {
        self.id = String(dataDict["id"].intValue)
        self.date_created = dataDict["date_created"].stringValue
        self.date_modified = dataDict["date_modified"].stringValue
        self.src = dataDict["src"].stringValue
        self.name = dataDict["name"].stringValue
        self.position = String(dataDict["position"].intValue)
        self.variations = " "
    }
}

// MARK: CATEGORY ITEM
class sProductCategory:Codable {
    
    var id:Int! = Int()
    var name:String! = String()
    
    init(json:JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
    }
}

class sCoupon {
    public var id:Int! = Int()
    public var code:String! = String()
    public var amount:String! = String()
    public var date_created:String! = String()
    public var date_created_gmt:String! = String()
    public var date_modified:String! = String()
    public var date_modified_gmt:String! = String()
    public var discount_type:String! = String()
    public var description:String! = String()
    public var product_ids: [JSON]! = [JSON]()
    public var excluded_product_ids: [JSON]! = [JSON]()
    public var free_shipping:Bool! = false
    public var product_categories: [JSON]! = [JSON]()
    public var excluded_product_categories: [JSON]! = [JSON]()
    public var exclude_sale_items:Bool! = false
    public var minimum_amount:String! = String()
    public var maximum_amount:String! = String()
    
    init(json:JSON) {
        id = json["id"].int
        code = json["code"].string
        amount = json["amount"].string
        date_created = json["date_created"].string
        date_created_gmt = json["date_created_gmt"].string
        date_modified = json["date_modified"].string
        date_modified_gmt = json["date_modified_gmt"].string
        discount_type = json["discount_type"].string
        description = json["description"].string
        product_ids = json["product_ids"].array
        excluded_product_ids = json["excluded_product_ids"].array
        free_shipping = json["free_shipping"].bool
        product_categories = json["product_categories"].array
        excluded_product_categories = json["excluded_product_categories"].array
        exclude_sale_items = json["exclude_sale_items"].bool
        minimum_amount = json["minimum_amount"].string
        maximum_amount = json["maximum_amount"].string
    }
}

// MARK: STOREITEM
class storeItem: Codable {
    
    var id:String! = String()
    var sku:String! = String()
    var title:String! = String()
    var desc:String! = String()
    var image:[sImages]!
    var qty:String! = String()
    var price:String! = String()
    var regularPrice:String! = String()
    var inStock:Bool!
    var manageStock:Bool!
    var dateCreated:String! = String()
    var downloadable:Bool!
    var tax_class:String! = String()
    var shipping_class_id:Int!
    var average_rating:String! = String()
    var tax_status:String! = String()
    var shipping_class:String! = String()
    var attributes:[sAttributes]!
    var variation:[sVariation]!
    var featured:Bool! = false
    var categories:[sProductCategory]! = [sProductCategory]()
    var onSale:Bool! = Bool()
    
    init(dataDict:JSON) {
        self.id = dataDict["id"].stringValue
        self.sku = dataDict["sku"].stringValue
        self.title = dataDict["name"].stringValue
        self.desc = dataDict["description"].stringValue
        self.price = dataDict["price"].stringValue
        self.qty = dataDict["stock_quantity"].stringValue
        self.inStock = dataDict["in_stock"].boolValue
        self.manageStock = dataDict["manage_stock"].boolValue
        self.regularPrice = dataDict["regular_price"].string
        
        self.dateCreated = dataDict["date_created"].stringValue
        self.downloadable = dataDict["downloadable"].boolValue
        self.tax_class = dataDict["tax_class"].stringValue
        self.tax_status = dataDict["tax_status"].stringValue
        self.shipping_class_id = dataDict["shipping_class_id"].intValue
        self.average_rating = dataDict["average_rating"].stringValue
        self.shipping_class = dataDict["shipping_class"].stringValue
        self.featured = dataDict["featured"].boolValue
        self.onSale = dataDict["on_sale"].bool
        
        if dataDict["categories"].array?.count != 0 {
            for category in (dataDict["categories"].array ?? []) {
                self.categories.append(sProductCategory(json: category))
            }
        }
        
        self.image = []
        self.attributes = []
        self.variation = []
        
        if JSON(dataDict["images"].array ?? []).count != 0 {
            for i in 0..<JSON(dataDict["images"].array ?? []).count {
                let oImages:sImages! = sImages(dataDict: ((dataDict["images"].array)?[i])!)
                self.image.append(oImages)
            }
        }
        
        if dataDict["variations"].array?.count != 0 && dataDict["variations"].array != nil {
            
            for i in 0..<(dataDict["variations"].array?.count)! {
                let oVariation:sVariation! = sVariation(dataDict: ((dataDict["variations"].array)?[i][0]) ?? [])
                self.variation.append(oVariation)
            }
        }
        if self.variation.count == 0 {
            self.variation = [sVariation()]
        }
        
        if dataDict["attributes"].array?.count != 0 && dataDict["attributes"].array != nil {
            for i in 0..<(dataDict["attributes"].array?.count ?? [].count) {
                let oAttributes = sAttributes(dataDict: ((dataDict["attributes"].array)?[i])!)
                
                self.attributes.append(oAttributes)
            }
        }
        if self.attributes.count == 0 {
            self.attributes = [sAttributes()]
        }
    }
}

// MARK: USER MODEL
class sLabelUser: Codable {
    
    public var firstName:String! = String()
    public var lastName:String! = String()
    public var email:String! = String()
    public var userId:String! = String()
    
    init(json:[String: JSON]) {
        
        guard let firstName = json["first_name"]?.string,
            let lastName = json["last_name"]?.string,
            let email = json["email"]?.string,
            let userId = json["user_id"]?.string else {
                return
        }
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userId = userId
    }
}

// MARK: USER ADDRESS
class sAddress {
    public var addNo:String! = String()
    public var addStreet:String! = String()
    public var addCity:String! = String()
    public var addPostcode:String! = String()
    public var addCountry:String! = String()
    
    init(no:String,street:String?,city:String?,postcode:String?,country:String?) {
        self.addNo = no
        self.addStreet = street
        self.addCity = city
        self.addPostcode = postcode
        self.addCountry = country
    }
}

// MARK: USER
class sUser:Codable {
    public var first_name:String! = String()
    public var last_name:String! = String()
    public var email:String! = String()
    public var phone:String! = String()
    
    init(first_name:String! = "",last_name:String! = "",email:String! = "",phone:String! = "") {
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.phone = phone
    }
}

// MARK: ORDER
/**
 Order item from Woocommerce
 */
class sOrder: Codable {
    public var id:Int! = Int()
    public var parent_id:Int! = Int()
    public var status:String! = String()
    public var order_key:String! = String()
    public var number:Int! = Int()
    public var currency:String! = String()
    public var version:String! = String()
    public var prices_include_tax:Bool!
    public var date_created:String! = String()
    public var date_modified:String! = String()
    public var customer_id:Int!
    public var discount_total:String! = String()
    public var discount_tax:String! = String()
    public var shipping_total:String! = String()
    public var shipping_tax:String! = String()
    public var cart_tax:String! = String()
    public var total:String! = String()
    public var total_tax:String! = String()
    public var billing:sBilling!
    public var shipping:sShipping!
    public var payment_method:String! = String()
    public var payment_method_title:String! = String()
    public var transaction_id:String! = String()
    public var customer_ip_address:String! = String()
    public var customer_user_agent:String! = String()
    public var created_via:String! = String()
    public var customer_note:String! = String()
    public var date_completed:String! = String()
    public var date_paid:String! = String()
    public var cart_hash:String! = String()
    public var line_items:[sLineItem]!
    
    init(dataDict:JSON) {
        
        self.id = dataDict["id"].int
        self.parent_id = dataDict["parent_id"].intValue
        self.status = dataDict["status"].string
        self.order_key = dataDict["order_key"].string
        self.number = dataDict["number"].intValue
        self.currency = dataDict["currency"].string
        self.version = dataDict["version"].string
        self.prices_include_tax = dataDict["prices_include_tax"].bool
        self.date_created = dataDict["date_created"].string
        self.date_modified = dataDict["date_modified"].string
        self.customer_id = dataDict["customer_id"].intValue
        self.discount_total = dataDict["discount_total"].string
        self.discount_tax = dataDict["discount_tax"].string
        self.shipping_total = dataDict["shipping_total"].string
        self.shipping_tax = dataDict["shipping_tax"].string
        self.cart_tax = dataDict["cart_tax"].string
        self.total = dataDict["total"].string
        self.total_tax = dataDict["total_tax"].string
        self.payment_method = dataDict["payment_method"].string
        self.payment_method_title = dataDict["payment_method_title"].string
        self.transaction_id = dataDict["transaction_id"].string
        self.customer_ip_address = dataDict["customer_ip_address"].string
        self.customer_user_agent = dataDict["customer_user_agent"].string
        self.created_via = dataDict["created_via"].string
        self.customer_note = dataDict["customer_note"].string
        self.date_completed = dataDict["date_completed"].string
        self.date_paid = dataDict["date_paid"].string
        self.cart_hash = dataDict["cart_hash"].string
        
        self.line_items = []
        
        for i in 0..<(dataDict["line_items"].arrayValue.count) {
            let lineItem = sLineItem(dataDict: dataDict["line_items"][i])
            self.line_items.append(lineItem)
        }
        
        self.shipping = sShipping(dataDict: dataDict["shipping"])
        self.billing = sBilling(dataDict: dataDict["billing"])
    }
}

// MARK: CHECKOUT PRODUCT
class checkoutProduct {
    public var description:String! = ""
    public var image:String? = nil
    public var name:String! = ""
    public var price:Double! = 0
    public var quantity:Int! = 0
    public var shippingCost:Double! = 0
    public var sku:String! = ""
    public var trackingUrl:String! = ""
    
    public func buildDict() -> [String:Any] {
        return ["description":description, "image":image ?? "", "name":name, "price":price, "quantity":quantity, "shippingCost":shippingCost, "sku":sku, "trackingUrl":trackingUrl]
    }
}

// MARK: SHIPPING
class sShipping: Codable {
    public var first_name:String! = String()
    public var last_name:String! = String()
    public var company:String! = String()
    public var address_1:String! = String()
    public var address_2:String! = String()
    public var city:String! = String()
    public var state:String! = String()
    public var postcode:String! = String()
    public var country:String! = String()
    
    init(dataDict:JSON) {
        
        self.first_name = dataDict["first_name"].string
        self.last_name = dataDict["last_name"].string
        self.company = dataDict["company"].string
        self.address_1 = dataDict["address_1"].string
        self.address_2 = dataDict["address_2"].string
        self.city = dataDict["city"].string
        self.state = dataDict["state"].string
        self.postcode = dataDict["postcode"].string
        self.country = dataDict["country"].string
    }
}

// MARK: TAXES
class sTaxes: Codable {
    public var id:Int!
    public var total:Double!
    public var subtotal:Double!
    
    init(dataDict:JSON = dTaxes) {
        self.id = dataDict["id"].int
        self.total = dataDict["total"].double
        self.subtotal = dataDict["subtotal"].double
    }
}

// MARK: LINEITEM
class sLineItem: Codable {
    public var id:Int! = Int()
    public var name:String! = String()
    public var sku:String! = String()
    public var product_id:Int! = Int()
    public var variation_id:Int! = Int()
    public var quantity:Int! = Int()
    public var tax_class:String! = String()
    public var price:String! = String()
    public var subtotal:String! = String()
    public var subtotal_tax:String! = String()
    public var total:String! = String()
    public var total_tax:String! = String()
    public var taxes:sTaxes!
    
    init(dataDict:JSON) {
        self.id = dataDict["id"].int
        self.name = dataDict["name"].string
        self.sku = dataDict["sku"].string
        self.product_id = dataDict["product_id"].int
        self.variation_id = dataDict["variation_id"].int
        self.quantity = dataDict["quantity"].intValue
        self.tax_class = dataDict["tax_class"].string
        self.price = dataDict["price"].string
        self.subtotal = dataDict["subtotal"].string
        self.subtotal_tax = dataDict["subtotal_tax"].string
        self.total = dataDict["total"].string
        self.total_tax = dataDict["total_tax"].string
        self.taxes = sTaxes()
    }
}

// MARK: SHIPPING LINES
class sShippingLines: Codable {
    public var method_title:String! = String()
    public var method_id:String! = String()
    public var total:String! = String()
    public var eachAdditional:String! = String()
    
    init(dataDict:JSON = JSON(["method_title":"","method_id":"","total":"0","each_additional":"0"])) {
        
        self.method_title = dataDict["method_title"].string
        self.method_id = dataDict["method_id"].string
        self.total = dataDict["total"].string
        self.eachAdditional = dataDict["each_additional"].string
    }
}

// MARK: ORDER CORE
class orderCore: Codable {
    public var order:sOrder!
    public var basket:[sBasket]!
    
    init(order:JSON,basket:[sBasket]) {
        self.order = sOrder(dataDict: order)
        self.basket = basket
    }
}

// MARK: LABEL USER BUILDER
class LabelUserBuilder {
    public var firstName:String! = ""
    public var lastName:String! = ""
    public var email:String! = ""
    public var password:String! = ""
    
    init() {}
    
    public func validatePassword(password:String) -> Bool {
        let pattern:Regex! = labelRegex().password
        return pattern.matches(password)
    }
}
