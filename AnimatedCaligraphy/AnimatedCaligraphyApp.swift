//
//  AnimatedCaligraphyApp.swift
//  AnimatedCaligraphy
//
//  Created by radu on 12.08.2024.
//

import SwiftUI


import SwiftUI
import FirebaseCore
import TipKit
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)   -> Bool {
    FirebaseApp.configure()
    Analytics.setAnalyticsCollectionEnabled(true)
     // Analytics.logEvent("event_name", parameters: ["param_buttonClick" : "App started"])
    return true
  }
}



@main

struct AnimatedCaligraphyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Model.shared)
          
           
        }
    }
}
