//
//  LabelCore.swift
//  Label Pro
//
//  Created by Anthony Gordon.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation
import SwiftyJSON

/*
 Developer Notes
 
 HERE YOU CAN CONFIG DETAILS ACROSS THE APP
 SUPPORT EMAIL - support@wooapps.uk
 VERSION - 2.0
 https://woosignal.com
 */

/* ! CONFIGURE YOUR STORE HERE ! */

struct labelCore {
    
    /*<! ------ CONFIG ------!>*/
    
    /* ! CONNECT TO WOOSIGNAL ! */
    // Visit https://woosignal.com and generate an appKey to connect your store, follow the documentation for more information
    let appKey = ""
    
    let wcUrl = "https://yourdomain.com/"
    
    let storeName:String! = "Label" // - STORE NAME
    let storeImage:String! = "LabelIcon" // - THE STORE ICON/LOGO FILENAME WHICH SHOULD BE IN THE "Assets.xcassets" folder (Left sidebar).
    let storeEmail:String! = "support@woosignal.com" // - STORE EMAIL
    let privacyPolicyUrl = URL(string: "https://www.mystore.com/privacy")! // - STORE PRIVACY URL
    let termsUrl = URL(string: "https://www.mystore.com/terms")! // - STORE TERMS URL
    
    /*<! ------ CURRENCY ------!>*/
    // https://gist.github.com/jacobbubu/1836273 // VIEW ALL LOCALES
    let appLocaleID:String! = "en_GB" // - CHANGE CURRENCY WITH appLocaleID
    
    let currencyCode:String! = "GBP" // FOR PAYPAL
    
    /*<! ------ PAYMENT PROVIDERS ENABLED ------!>*/
    
    let useStripe:Bool! = true // SET TRUE TO ENABLE / FALSE TO DISABLE - STRIPE
    let usePaypal:Bool! = false // SET TRUE TO ENABLE / FALSE TO DISABLE - PAYPAL
    let useApplePay:Bool! = false // SET TRUE TO ENABLE / FALSE TO DISABLE - APPLE PAY
    
    let labelDebug:Bool! = true // SET TRUE TO LOG OUTPUT MESSAGES IN THE XCODE LOGGER
    
    /*<! ------ LOGIN ------!>*/
    /*
     * Enable login/registration in the app, you must have the following plugins installed on WordPress for this to work:
     * Label plugin, JSON API, JSON API Auth, JSON API User
     */
    let useLabelLogin:Bool! = false // SET TRUE TO ENABLE / FALSE TO DISABLE - LABEL LOGIN FEATURE
    
    /*<! ------ ONESIGNAL ------!>*/
    /*
     CONNECT ONESIGNAL (OPTIONAL)
     Replace 'YOUR_APP_ID' with your OneSignal App ID.
     - Support link - https://onesignal.com/
     */
    let oneSignalAppId = ""
    let useNotifications:Bool! = true // SET TRUE TO ENABLE / FALSE TO DISABLE - NOTIFICATIONS
    
    /*<! ------ STRIPE ------!>*/
    /*
     CONNECT STRIPE (OPTIONAL)
     - Support link - https://stripe.com/docs/dashboard#api-keys
     */
    let stripePublishable:String! = ""
    
    /*<! ------ PAYPAL ------!>*/
    /*
     CONNECT PAYPAL (OPTIONAL)
     - Support link - https://github.com/paypal/PayPal-iOS-SDK/blob/master/README.md#credentials
     IMPORTANT! CHANGE THE CLIENT ID TO ALTER LIVE/SANDBOX ENVIRONMENT
     */
    let paypalClientID:String! = ""
    let paypalSecret:String! = ""
    
    /*<! ------ FEATURED HEADER ------!>*/
    /*
     ENABLE THE FEATURED BANNER TO SHOW HERE
     */
    let useFeaturedHeader = true
    
    /*<! ------ APPLE PAY ------!>*/
    /*
     CONNECT APPLE PAY (OPTIONAL)
     - Help setting up Apple Pay
     Support link - https://www.raywenderlich.com/87300/apple-pay-tutorial
     
     1). Create MerchantID via http://developer.apple.com
     2). Assign the value to the below variable "MerchantID"
     3). Open the Compatibilties in the workspace settings and add your merchantID to the Apple Pay setting.
     IMPORTANT! CHANGE THE CLIENT ID TO ALTER LIVE/SANDBOX ENVIRONMENT
     */
    let merchantID:String! = ""
    let applePayButtonType:PKPaymentButtonType! = .plain
    let applePayButtonStyle:PKPaymentButtonStyle! = .whiteOutline
    
    let applePayCountryCode:String! = "GB"
    // REF LINK - http://data.okfn.org/data/core/country-list
    
    let applePayCurrencyCode:String! = "GBP"
    // REF LINK - https://en.wikipedia.org/wiki/ISO_4217#Active_codes
    
    let supportedPaymentNetworks:[PKPaymentNetwork]! = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
    
    /*<! ------ MISC ------!>*/
    
    // MARK: RETURNS APP VERSION
    /**
     Returns the app version.
     */
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }
}
