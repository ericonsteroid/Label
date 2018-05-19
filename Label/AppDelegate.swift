//
//  AppDelegate.swift
//  Label
//
//  Created by Anthony Gordon on 17/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import Stripe
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // STRIPE
        STPPaymentConfiguration.shared().publishableKey = labelCore().stripePublishable
        
        // PAYPAL
        PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: labelCore().paypalClientID,PayPalEnvironmentSandbox: labelCore().paypalClientID])
        
        // SET UINAVIGATION FONT
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "AmsiPro-Regular", size: 20)!
        ]
        
        // SET UIBARBUTTON FONT
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedStringKey.font : UIFont(name: "AmsiPro-Semibold", size: 18)!,
                NSAttributedStringKey.foregroundColor : UIColor.black,
                ], for: .normal
        )
        
        // ONESIGNAL
        if labelCore().useNotifications {
            
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
            
            OneSignal.initWithLaunchOptions(launchOptions,
                                            appId: labelCore().oneSignalAppId,
                                            handleNotificationAction: nil,
                                            settings: onesignalInitSettings)
            
            OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
            
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                LabelLog().output(log: "User accepted notifications: \(accepted)")
            })
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}

