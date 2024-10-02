
/// AFTER


import SwiftUI
import FirebaseCore
import TipKit
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)   -> Bool {
      FirebaseConfiguration.shared.setLoggerLevel(FirebaseLoggerLevel.error)
   //   FirebaseConfiguration.sharedInstance().setLoggerLevel(.Error)
    FirebaseApp.configure()
    Analytics.setAnalyticsCollectionEnabled(true)
      Analytics.logEvent("Hand_write", parameters: ["param_buttonClick" : "App started"])
    
    return true
  }
}

import RevenueCat
import RevenueCatUI

@main

struct AnimatedCaligraphyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        //Purchases.configure(withAPIKey: "appl_PNsIMlsRkQnhMvuuecfhnBewYdK") // Inky key
        //Purchases.configure(withAPIKey: "appl_DkeTZOfKtpnWLdedTjTRRLWFTZn")
        //Purchases.logLevel = .debug
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environment(Model.shared)
              //  .presentPaywallIfNeeded(requiredEntitlementIdentifier: "InkyProProductID") // Inky Identifier
               // .presentPaywallIfNeeded(requiredEntitlementIdentifier: "LipyPro")
             //
          
           
        }
    }
}



