//
//  CurrentLocationApp.swift
//  CurrentLocation
//
//  Created by Joan Muñoz on 15-03-23.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct CurrentLocationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    @State var isLoggin = false
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
